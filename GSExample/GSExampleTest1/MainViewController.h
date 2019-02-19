//
//  MainViewController.h
//  GSExample
//
//  Created by Giuseppe Perniola on 05/02/2016.
//  Copyright © 2016 GameSparks Technologies Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GS.h"
#import "GSAPI.h"

@interface MainViewController : UIViewController <UITextFieldDelegate>
{
    bool bConnecting;
}

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) GS *gs;

@end
