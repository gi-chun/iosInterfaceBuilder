/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

//
//  AppDelegate.m
//  KtisOn
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "AppDelegate.h"
#import "SplashViewController.h"
#import "SettingManager.h"

#import "KeychainItemWrapper.h"
#import "SecurityManager.h"
#import "SoapInterface.h"
#import "SSOController.h"
#import "MainViewController.h"
#import "LoginViewController.h"

@interface AppDelegate()
{
    BOOL                    _flag;
    UINavigationController  *_navigation;
    NSString                *_pushOpenUrl;
}
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // 앱의 푸쉬 수신여부 설정
    if (IsAtLeastiOSVersion(@"8.0")) {
        UIUserNotificationType types = UIUserNotificationTypeBadge |
        UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *mySettings =
        [UIUserNotificationSettings settingsForTypes:types categories:nil];
        
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }else{
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    }
    
    // 첫 진입시 처리 (설정값 초기화, UUID 저장)
    NSString *uuid = [[SettingManager sharedInstance] getUUID];
    if (uuid == nil || [uuid isEqualToString:@""])
    {
        [[SettingManager sharedInstance] initPinCode];
        [[SettingManager sharedInstance] setUUID];
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"blockLoginFailed"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // 루트뷰 지정
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    SplashViewController *splashVC = [[SplashViewController alloc] initWithNibName:NibName(@"SplashViewController") bundle:nil];
    _navigation = [[UINavigationController alloc] initWithRootViewController:splashVC];
    [_navigation setNavigationBarHidden:YES];
    self.window.rootViewController = _navigation;
    [self.window makeKeyAndVisible];
    
    _flag = 1;
    
    
    /* drm reader check installed */
    /*
     NSString *path = [[NSBundle mainBundle] resourcePath];
     NSFileManager *fm = [NSFileManager defaultManager];
     
     NSError *error = nil;
     
     NSArray *directoryAndFileNames = [fm contentsOfDirectoryAtPath:path error:&error];
     
     NSLog(@"is in?");
     for (id obj in directoryAndFileNames) {
     NSLog(@"%@", obj);
     }
     
     
     NSString* certPath = [[NSBundle mainBundle] pathForResource:@"certificate" ofType:@"cer"];
     if (!certPath) {
     NSLog(@"nil");
     } else {
     NSLog(@"already have");
     }
     //*/
    
    /*
     NSString* certPath = [[NSBundle mainBundle] pathForResource:@"certificate" ofType:@"cer"];
     if (certPath==nil)
     {
     NSLog(@"ERROR: hane no certification path");
     }
     else
     {
     NSData* certData = [NSData dataWithContentsOfFile:certPath];
     SecCertificateRef   cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) certData);
     SecPolicyRef        policy = SecPolicyCreateBasicX509();
     SecTrustRef trust;
     OSStatus err = SecTrustCreateWithCertificates((__bridge CFArrayRef) [NSArray arrayWithObject:(__bridge id)cert], policy, &trust);
     SecTrustResultType trustResult = -1;
     err = SecTrustEvaluate(trust, &trustResult);
     
     CFRelease(trust);
     CFRelease(policy);
     CFRelease(cert);
     
     if(trustResult == kSecTrustResultUnspecified)
     NSLog(@"Profile is installed");
     else
     NSLog(@"Profile is NOT installed");
     
     }
     //*/
    
    [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:@""] forKey:RECEIVED_PUSH_URL];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // 백그라운드에서 푸쉬 수신시 처리
    if (launchOptions)
        [self receiveRemoteNotification:launchOptions withAppState:NO];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    _flag = 1;
}

#pragma mark - 앱이 백그라운드로 빠질 때 뱃지 카운트 다시 조회하여 적용
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    _flag = 2;
    
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc]  initWithIdentifier:@"UserAuth" accessGroup:nil];
    NSString *employeeNumb = [NSString decodeString:[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)]];
    NSDictionary *badgeDic = [[SoapInterface sharedInstance] getBadgeCount:@{@"empNo": employeeNumb}]; // 뱃지 개수 데이터 조회
    
    if (badgeDic) {
        NSInteger appBadgeCoutn = [[badgeDic objectForKey:@"totalBadgeCount"] integerValue];
        application.applicationIconBadgeNumber = appBadgeCoutn;
    }
    else
    {
        application.applicationIconBadgeNumber = 0;
    }
    
    keychainWrapper = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    //refreshMainMenu
    UIViewController *mainVC;
    for (id viewController in [_navigation viewControllers]) {
        if ([viewController isKindOfClass:[MainViewController class]])
            mainVC = viewController;
    }
    
    if ([[[_navigation viewControllers] lastObject] isKindOfClass:[MainViewController class]])
        [(MainViewController *)mainVC refreshMainMenu];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (_flag == 2) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            BOOL authFailed = [[SSOController sharedInstance] checkSSOFromForeground];
//            NSLog(@"authFailed?:%d", authFailed);
//            if (authFailed) {
//                // 포그라운드로 올라올 때 인증실패하면 로그인으로 이동
//                for (id viewController in [_navigation viewControllers]) {
//                    if ([viewController isKindOfClass:[LoginViewController class]])
//                        [_navigation popToViewController:viewController animated:YES];
//                }
//            }
//            });
        
        
        dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^(void) {
            BOOL authFailed = [[SSOController sharedInstance] checkSSOFromForeground];
            NSLog(@"authFailed?:%d", authFailed);
            dispatch_async( dispatch_get_main_queue(), ^(void) {
                if (authFailed) {
                    // 포그라운드로 올라올 때 인증실패하면 로그인으로 이동
                    for (id viewController in [_navigation viewControllers]) {
                        if ([viewController isKindOfClass:[LoginViewController class]])
                            [_navigation popToViewController:viewController animated:YES];
                    }
                }
            });
        });
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - APNS Notification Regist Results
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSLog(@"APNS 디바이스 토큰 등록 성공 : %@", deviceToken);
    [[SettingManager sharedInstance] setDeviceToken:[NSString stringWithFormat:@"%@", deviceToken]];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"APNS 디바이스 토큰 등록 실패 : %@", error);
}

#pragma mark - Recieve Push Notifications
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // 포그라운드에서의 푸쉬 처리
    [self receiveRemoteNotification:userInfo withAppState:YES];
}

- (void)receiveRemoteNotification:(NSDictionary *)info withAppState:(BOOL)onForeground
{
    NSLog(@"푸쉬 들어옴 %@", info);
    // 데이터가 없는 경우는 처리하지 않는다
    if (!info)
        return;
    
    _pushOpenUrl = @"";
    
    // 앱 실행중일 떄
    if (onForeground) {
        
        _pushOpenUrl = [info objectForKey:@"linkUrl"];
        
//        if ([_pushOpenUrl rangeOfString:@"mail."].location != NSNotFound) {
//            
//            _pushOpenUrl = [_pushOpenUrl stringByReplacingOccurrencesOfString:@"mail."
//                                                 withString:@"mmail."];
//            
//        }
        
        // url이 없는 경우
        if ([_pushOpenUrl isEqualToString:@""] || !_pushOpenUrl) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[info objectForKey:@"aps"] objectForKey:@"alert"]
                                                           delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        // url이 있는 경우
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[[info objectForKey:@"aps"] objectForKey:@"alert"]
                                                           delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:@"열기", nil];
            [alert show];
            
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:_pushOpenUrl
//                                                           delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:@"열기", nil];
//            [alert show];

            
        }
    }
    
    // 앱 실행중이 아닐 때
    else {
        _pushOpenUrl = [[info objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"] objectForKey:@"linkUrl"];
        
//        if ([_pushOpenUrl rangeOfString:@"mail."].location != NSNotFound) {
//            
//            _pushOpenUrl = [_pushOpenUrl stringByReplacingOccurrencesOfString:@"mail."
//                                                                   withString:@"mmail."];
//            
//        }
        
        [self pushAction];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self pushAction];
}

- (void)pushAction
{
    BOOL haveMain = NO;
    MainViewController *mainVC;
    for (id viewController in [_navigation viewControllers]) {
        if ([viewController isKindOfClass:[MainViewController class]])
        {
            haveMain = YES;
            mainVC = viewController;
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:_pushOpenUrl] forKey:RECEIVED_PUSH_URL];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[[_navigation viewControllers] lastObject] isKindOfClass:[MainViewController class]]) {
        // 메인뷰에 있는 경우
        [(MainViewController *)mainVC pushReceiveAction:[NSURL URLWithString:_pushOpenUrl]];
    }
    else
    {
        if (haveMain) {
            // 메인뷰가 스택에 있는 경우 메인으로 팝 시킨다
            for (id viewController in [_navigation viewControllers]) {
                if ([viewController isKindOfClass:[MainViewController class]])
                    [_navigation popToViewController:viewController animated:YES];
            }
        }
        // 메인뷰가 스택에 없는 경우 메인 진입시 처리한다
    }
}



@end
