//
//  MainViewController.m
//  GSExample
//
//  Created by Giuseppe Perniola on 05/02/2016.
//  Copyright © 2016 GameSparks Technologies Ltd. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak typeof(self) weakSelf = self;

    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 60.0f, 300.0f, 220.0f)];
    [self.view addSubview:self.textView];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(10.0f, 30.0f, 300.0f, 20.0f)];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.delegate = self;
    [self.view addSubview:self.textField];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.frame = CGRectMake(110.0f, 300.0f, 100.0f, 30.0f);
    [self.button addTarget:self action:@selector(buttonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.button setTitle:@"Connect" forState:UIControlStateNormal];
    [self.view addSubview:self.button];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(115.0f, 250.0f, 200.0f, 30.0f)];
    self.label.text = @"Disconnected";
    [self.view addSubview:self.label];
    
    bConnecting = false;
    
    self.gs = [[GS alloc] initWithApiKey:@"exampleKey12" andApiSecret:@"exampleSecret1234567890123456789" andCredential:@"" andPreviewMode:true];
    
    [self.gs setAvailabilityListener:^ (BOOL available) {
        //Your code here
        NSMutableString *oldString = [NSMutableString stringWithString:weakSelf.textView.text];
        
        [oldString appendString:[NSString stringWithFormat:@"Availability: %d\n", available]];
        
        weakSelf.textView.text = oldString;
        
        if (available)
        {
            GSDeviceAuthenticationRequest* dar = [[GSDeviceAuthenticationRequest alloc] init];
            [dar setDeviceId:@"deviceId"];
            [dar setDeviceOS:@"IOS"];
            [dar setCallback:^ (GSAuthenticationResponse* response) {
                //Your code here
                NSMutableString *oldString = [NSMutableString stringWithString:weakSelf.textView.text];
                
                [oldString appendString:[NSString stringWithFormat:@"AuthenticationResponse: %@\n", [response getDisplayName]]];
                
                weakSelf.textView.text = oldString;
                
                GSLogEventRequest *logEventRequest = [[GSLogEventRequest alloc] init];
                [logEventRequest setEventKey:@"testMessage"];
                [logEventRequest setEventAttribute:@"foo" withString:@"bar"];
                [logEventRequest setDurable:TRUE];
                [weakSelf.gs send:logEventRequest];

            }];
            [weakSelf.gs send:dar];
        }
    }];
    [self.gs setAuthenticatedListener:^(NSString* playerId) {
        //Your code here
        NSMutableString *oldString = [NSMutableString stringWithString:weakSelf.textView.text];
        
        [oldString appendString:[NSString stringWithFormat:@"Authenticated: %@\n", playerId]];
        
        weakSelf.textView.text = oldString;
    }];
    
    GSMessageListener* listener = [[GSMessageListener alloc] init];
    
    [listener onGSScriptMessage:^(GSScriptMessage* message) {
        NSLog(@"msg: %@", message.getMessageId);
    }];
    
    [self.gs setMessageListener:listener];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)buttonPressed {
    if (bConnecting)
    {
        bConnecting = false;
        
        [self.button setTitle:@"Connect" forState:UIControlStateNormal];
        
        self.label.text = @"Disconnected";
        
        [self.gs disconnect];
    }
    else
    {
        bConnecting = true;
        
        self.textView.text = @"";
        
        [self.button setTitle:@"Disconnect" forState:UIControlStateNormal];
        
        self.label.text = @"Connecting...";
    
        [self.gs connect];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return FALSE;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

@end
