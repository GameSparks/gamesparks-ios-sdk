//
//  GSExampleTests.m
//  GSExampleTests
//
//  Created by Gabriel Page on 09/06/2015.
//  Copyright (c) 2015 GameSparks Technologies Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "GS+Tests.h"
#import "GSAPI.h"

@interface GSExampleTests : XCTestCase

@end

@implementation GSExampleTests

BOOL success;

- (void)setUp {
    success = false;
    [super setUp];
}

- (GS*) getGS {
    return [[GS alloc] initWithApiKey:@"exampleKey12" andApiSecret:@"exampleSecret1234567890123456789" andCredential:@"" andPreviewMode:true];
}

- (void)tearDown {
    [super tearDown];
}

- (void) connectAndwaitForSuccess:(NSString*) message withGS:(GS*)gs {
    [gs connect];
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:10];
    while (success == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }
    XCTAssert(success, @"%@ Passed!", message);
    [gs disconnect];
    [gs reset];
}

- (void) testDates {
    __weak GS* gs = [self getGS];
    GSDeviceAuthenticationRequest* dar = [[GSDeviceAuthenticationRequest alloc] init];
    
    NSTimeInterval timeSince1970 = [[NSDate date] timeIntervalSince1970];
    
    timeSince1970 -= fmod(timeSince1970, 60); // subtract away any extra seconds
    
    __weak NSDate* endDate = [[NSDate dateWithTimeIntervalSince1970:timeSince1970] dateByAddingTimeInterval:60*60*24];
    
    [dar setDeviceId:@"deviceId"];
    [dar setDeviceOS:@"IOS"];
    [dar setCallback:^ (GSAuthenticationResponse* response) {

        if(!response.getErrors){
            GSCreateChallengeRequest* ccr = [[GSCreateChallengeRequest alloc] init];
            [ccr setChallengeShortCode:@"Challenge"];
            [ccr setEndTime:endDate];
            [ccr setUsersToChallenge:@[@"exampleUserId12345678901"]];
            [ccr setCallback:^ (GSCreateChallengeResponse* ccrResponse) {

                NSString* challengeId = ccrResponse.getChallengeInstanceId;
                GSGetChallengeRequest* gcr = [[GSGetChallengeRequest alloc] init];
                [gcr setChallengeInstanceId:challengeId];
                [gcr setCallback:^ (GSGetChallengeResponse* gcrResponse) {
                    
                    NSDate* date = [gcrResponse.getChallenge getEndDate ];
                    if([date isEqualToDate:endDate]){
                        success = true;
                    }
                }];
                [gs send:gcr];
            }];
            
            [gs send:ccr];
        }
    }];
    
    [gs send:dar];
    
    [self connectAndwaitForSuccess:@"testSendBeforeConnect" withGS:gs];

    
}


- (void) testDurable {
    __weak GS* gs = [self getGS];

    [gs setUserId:@"exampleUserId12345678901"];
    [[gs getDurableQueue ] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [gs removeFromDurableQueue:obj];
    }];
    XCTAssert([[gs getDurableQueue] count] == 0, @"Durable Queue for \"exampleUserId12345678901\" did not have zero entries!");

    [gs setUserId:@""];
    [[gs getDurableQueue ] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [gs removeFromDurableQueue:obj];
    }];
    XCTAssert([[gs getDurableQueue] count] == 0, @"Durable Queue for \"\" did not have zero entries!");
    
    [gs setUserId:@""];
    //Put some stuff in it
    GSDeviceAuthenticationRequest* dar = [[GSDeviceAuthenticationRequest alloc]init];
    [dar setDurable:true];
    [dar setDisplayName:@"test empty userId"];
    [dar setTimeout:1];
    [gs send:dar];
    //At this point, the queue for userd "" should have a single item in it
    XCTAssert([[gs getDurableQueue] count] == 1, @"Durable Queue for \"\" did not have one entry!");
    
    [gs setUserId:@"exampleUserId12345678901"];
    //Put some stuff in it
    GSDeviceAuthenticationRequest* dar1 = [[GSDeviceAuthenticationRequest alloc]init];
    [dar1 setDisplayName:@"test populated userId"];
    [dar1 setDurable:true];
    [dar1 setTimeout:1];
    [gs send:dar1];
    
    //At this point, the queue for userd "" should have a single item in it
    XCTAssert([[gs getDurableQueue] count] == 1, @"Durable Queue for \"exampleUserId12345678901\" did not have one entry!");
    
    [gs reset];

    gs = [self getGS];

    [gs setAuthenticatedListener:^(NSString * userId) {
        [[gs getDurableQueue ] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            XCTAssert(![obj hasCallback], @"Durable Queue item had a callback after loading");
            [obj setCallback:^ (GSAuthenticationResponse* response) {
                success = true;
            }];
        }];
    }];
    
    [gs setUserId:@""];
    XCTAssert([[gs getDurableQueue] count] == 1, @"Durable Queue for \"exampleUserId12345678901\" did not have one entry!");
    [self connectAndwaitForSuccess:@"Durable item sent" withGS:gs];
    
    success = false;
    [gs setUserId:@"exampleUserId12345678901"];
    XCTAssert([[gs getDurableQueue] count] == 1, @"Durable Queue for \"exampleUserId12345678901\" did not have one entry!");
    [self connectAndwaitForSuccess:@"Durable item sent" withGS:gs];
    

}

-(void) sleep:(int) seconds {
    NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:seconds];
    while (success == NO && [loopUntil timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:loopUntil];
    }
    
}

- (void)testWaitForInitialisation {
    GS* gs = [self getGS];
    [gs setAvailabilityListener:^ (BOOL available) {
        success = true;
        if(available){
            NSLog(@"%@", @"AVAILABLE");
        } else {
            NSLog(@"%@", @"NOTAVAILABLE");
        }
    }];
    [gs connect];
    
    [self connectAndwaitForSuccess:@"testWaitForInitialisation" withGS:gs];
    
}

- (void)testSendBeforeConnect {
    
    GSDeviceAuthenticationRequest* dar = [[GSDeviceAuthenticationRequest alloc] init];
    [dar setDeviceId:@"deviceId"];
    [dar setDeviceOS:@"IOS"];
    [dar setCallback:^ (GSAuthenticationResponse* response) {
        if(!response.getErrors){
            success = true;
        }
    }];
    GS* gs = [self getGS];
    [gs send:dar];
    
    [self connectAndwaitForSuccess:@"testSendBeforeConnect" withGS:gs];
}

- (void)testSimpleResponseRecieved {
    __weak GS* gs = [self getGS];
    [gs setAvailabilityListener:^ (BOOL available) {
        if(available){
            GSDeviceAuthenticationRequest* dar = [[GSDeviceAuthenticationRequest alloc] init];
            [dar setDeviceId:@"deviceId"];
            [dar setDeviceOS:@"IOS"];
            [dar setCallback:^ (GSAuthenticationResponse* response) {
                if(!response.getErrors){
                    success = true;
                }
            }];
            [gs send:dar];
        }
    }];
    [self connectAndwaitForSuccess:@"testSimpleResponseRecieved" withGS:gs];
}

- (void)testResponseTimeout {
    __weak GS* gs = [self getGS];
    [gs setAvailabilityListener:^ (BOOL available) {
        if(available){
            GSDeviceAuthenticationRequest* dar = [[GSDeviceAuthenticationRequest alloc] init];
            [dar setDeviceId:@"deviceId"];
            [dar setDeviceOS:@"IOS"];
            [dar setTimeout:0];
            [dar setCallback:^ (GSAuthenticationResponse* response) {
                if(response.getErrors){
                    success = true;
                }
            }];
            [gs send:dar];
        }
    }];
    [self connectAndwaitForSuccess:@"testResponseTimeout" withGS:gs];
}

- (void)testScriptMessageRecieved {
    
    GSMessageListener* listener = [[GSMessageListener alloc] init];
    
    [listener onGSScriptMessage:^(GSScriptMessage* message) {
        NSLog(@"%@", message.getMessageId);
        success = true;
    }];
    __weak GS* gs = [self getGS];
    [gs setMessageListener:listener];
    
    [gs setAvailabilityListener:^ (BOOL available) {
        if(available){
            GSDeviceAuthenticationRequest* dar = [[GSDeviceAuthenticationRequest alloc] init];
            [dar setDeviceId:@"deviceId"];
            [dar setDeviceOS:@"IOS"];
            [dar setCallback:^ (GSAuthenticationResponse* response) {
                GSLogEventRequest* lev = [[GSLogEventRequest alloc] init];
                [lev setEventKey:@"Send_Message"];
                [lev._data setObject:@"THEMESSAGE" forKey:@"message"];
                [gs send:lev];
            }];
            [gs send:dar];
            
        }
    }];

    [self connectAndwaitForSuccess:@"testScriptMessageRecieved" withGS:gs];
}

- (void) testLeaderboardDataResponse {
    __weak GS* gs = [self getGS];
    [gs setAvailabilityListener:^ (BOOL available) {
        if(available){
            GSDeviceAuthenticationRequest* dar = [[GSDeviceAuthenticationRequest alloc] init];
            [dar setDeviceId:@"deviceId"];
            [dar setDeviceOS:@"IOS"];
            [dar setCallback:^ (GSAuthenticationResponse* response) {
                GSLeaderboardDataRequest* request = [[GSLeaderboardDataRequest alloc] init];
                [request setLeaderboardShortCode:@"Scores_LB"];
                [request setEntryCount:[[NSNumber alloc] initWithInt:10]];
                [request setCallback:^ (GSLeaderboardDataResponse* response) {
                    NSArray * data = [response getData];
                    if(data){
                        for(GSLeaderboardData* leaderboardData in data){
                            NSString* city = [leaderboardData getCity];
                            NSNumber* score = [leaderboardData getAttribute:@"SCORE"];
                            success = true;
                        }
                    }
                }];
                [gs send:request];
                
            }];
            
            [gs send:dar];
        }
    }];
    [self connectAndwaitForSuccess:@"testLeaderboardDataResponse" withGS:gs];
    
}

@end
