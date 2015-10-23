//
//  MainViewController.h
//  ktis Mobile
//
//  Created by Hyuck on 1/24/14.
//
//

#import <UIKit/UIKit.h>

#import <Cordova/CDVViewController.h>
#import <Cordova/CDVPlugin.h>
#import "Defines.h"
#import "MainMenuView.h"
#import "LinkMenuView.h"
#import "UpdateView.h"

@interface MainViewController : UIViewController<MainMenuDelegate, LinkMenuDelegate>

- (void)pushReceiveAction:(NSURL *)url;
- (void)refreshMainMenu;

@property (nonatomic, strong) IBOutlet CDVViewController* viewController;

@end
