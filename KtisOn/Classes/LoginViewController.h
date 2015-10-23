//
//  LoginViewController.h
//  ktis Mobile
//
//  Created by Hyuck on 1/27/14.
//
//

#import <UIKit/UIKit.h>
#import "LoginManager.h"
#import "SettingManager.h"

@interface LoginViewController : UIViewController <UITextFieldDelegate, LoginProtocolDelegate>

@property (strong, nonatomic) NSTimer *timer;

@end
