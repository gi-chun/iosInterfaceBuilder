//
//  SplashViewController.m
//  ktis Mobile
//
//  Created by Hyuck on 1/24/14.
//
//

#import "SplashViewController.h"
#import "LoginViewController.h"
#import "CrackChecker.h"

@interface SplashViewController ()
{
    IBOutlet UILabel        *_versionLabel;
    IBOutlet UIImageView    *_splashBG;
}
- (void)setSplashImage;
- (void)goToNextView;
- (void)appShutdown;
@end

@implementation SplashViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 버전 텍스트
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    [_versionLabel setText:[NSString stringWithFormat:@"version %@", appVersion]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self setSplashImage];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    
    // 탈옥 여부 체크
    CrackChecker *crackChecker = [[CrackChecker alloc] init];
    BOOL isCracked = [crackChecker isCracked];
    if (!isCracked)
    {
        [self performSelector:@selector(goToNextView) withObject:nil afterDelay:1];
    }
    else if (isCracked)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"해킹 경고" message:@"5초후에 앱을 종료합니다" delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        [self performSelector:@selector(appShutdown) withObject:nil afterDelay:6];
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setSplashImage];
}

- (void)setSplashImage
{
    // 디바이스, os 버전, 회전방향에 따라 이미지 변경
    UIImage *bgImg;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    // iPhone
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        // iPhone 4 inches
        if ([[UIScreen mainScreen] bounds].size.height == 568.0f)
        {
            if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
                bgImg = [UIImage imageNamed:@"splash_land_4_retina.png"];       // landscape
            else
                bgImg = [UIImage imageNamed:@"Default-568h@2x~iphone.png"];     // portrait
        }
        // iPhone 3.5 inches
        else
        {
            // retina 구별
            if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))
            {
                // Retina display
                if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
                    bgImg = [UIImage imageNamed:@"splash_land_3.5_retina.png"]; // landscape
                else
                    bgImg = [UIImage imageNamed:@"Default@2x~iphone.png"];      // portrait
            } else {
                // non-Retina display
                if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
                    bgImg = [UIImage imageNamed:@"splash_land_normal.png"]; // landscape
                else
                    bgImg = [UIImage imageNamed:@"Default~iphone.png"];     // portrait
            }
        }
    }
    
    // iPad
    else
    {
        // retina 구별
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))
        {
            // Retina display
            if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
                bgImg = [UIImage imageNamed:@"splash_land_3.5_retina.png"]; // landscape
            else
                bgImg = [UIImage imageNamed:@"Default@2x~iphone.png"];      // portrait
        }
        else
        {
            // non-Retina display
            if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight)
                bgImg = [UIImage imageNamed:@"Default-Landscape~ipad.png"]; // landscape
            else
                bgImg = [UIImage imageNamed:@"Default-Portrait~ipad.png"];      // portrait
        }
    }
    
    [_splashBG setImage:bgImg];
    [_splashBG setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
}


- (void)goToNextView
{
    LoginViewController *loginView = [[LoginViewController alloc] initWithNibName:NibName(@"LoginViewController") bundle:nil];
    [self.navigationController pushViewController:loginView animated:NO];
}

- (void)appShutdown
{
    exit(0);
}

@end
