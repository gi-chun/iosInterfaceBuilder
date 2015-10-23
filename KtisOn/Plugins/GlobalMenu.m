//
//  GlobalMenu.m
//  ktis Mobile
//
//  Created by Hyuck on 2/6/14.
//
//

#import "GlobalMenu.h"
#import "LegacyViewController.h"

@implementation GlobalMenu

- (void)globalMenu:(CDVInvokedUrlCommand *)command
{
//    [self.commandDelegate runInBackground:^{
//        NSString* payload = nil;
//        // Some blocking logic...
//        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
//        // The sendPluginResult method is thread-safe.
//        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
//    }];
    NSLog(@"[커스텀플러그인] 글로벌메뉴 호출! class : %@", NSStringFromClass(self.viewController.class));
    [(LegacyViewController *)self.viewController toggleGlobalMenu];
}

- (void)indicator:(CDVInvokedUrlCommand *)command
{
    NSLog(@"[커스텀플러그인] 인디케이터");
    [(LegacyViewController *)self.viewController indicator];
}

- (void)sessionClose:(CDVInvokedUrlCommand *)command
{
    NSLog(@"[커스텀플러그인] 세션클로즈");
    [(LegacyViewController *)self.viewController sessionClose];
}

- (void)home:(CDVInvokedUrlCommand *)command
{
    NSLog(@"[커스텀플러그인] 홈 들어옴");
    [(LegacyViewController *)self.viewController goHome];
}

- (void)openFile:(CDVInvokedUrlCommand *)command
{
    NSString *receivedUrl = command.arguments[0];
    NSLog(@"[커스텀플러그인] 오픈파일:%@", receivedUrl);
    [(LegacyViewController *)self.viewController openFile:receivedUrl];
}

- (void)callPhone:(CDVInvokedUrlCommand *)command
{
    NSString *phoneNumb = command.arguments[0];
    NSLog(@"[커스텀플러그인] callPhone:%@", phoneNumb);
    [(LegacyViewController *)self.viewController callPhone:phoneNumb];
}

- (void)sendSMS:(CDVInvokedUrlCommand *)command
{
    NSString *phoneNumb = command.arguments[0];
    NSLog(@"[커스텀플러그인] SMS:%@", phoneNumb);
    [(LegacyViewController *)self.viewController sendSMS:phoneNumb];
}

- (void)sendMail:(CDVInvokedUrlCommand *)command
{
    NSString *mailAddress = command.arguments[0];
    NSString *backUrl = command.arguments[1];
    [(LegacyViewController *)self.viewController sendMail:mailAddress backUrl:backUrl];
}

- (void)backSendMail:(CDVInvokedUrlCommand *)command
{
    NSLog(@"[커스텀플러그인] 메일 뒤로가기");
    [(LegacyViewController *)self.viewController backSendMail];
}

- (void)insertContact:(CDVInvokedUrlCommand *)command
{
    NSString *name = command.arguments[0];
    NSString *contact = command.arguments[1];
    NSLog(@"[커스텀플러그인] 연락처 추가:%@/%@", name, contact);
    [(LegacyViewController *)self.viewController insertContact:name contact:contact];
}

@end
