//
//  GlobalMenu.h
//  ktis Mobile
//
//  Created by Hyuck on 2/6/14.
//
//

#import <Cordova/CDVPlugin.h>

@interface GlobalMenu : CDVPlugin

- (void)globalMenu:(CDVInvokedUrlCommand *)command;
- (void)indicator:(CDVInvokedUrlCommand *)command;
- (void)sessionClose:(CDVInvokedUrlCommand *)command;
- (void)home:(CDVInvokedUrlCommand *)command;

// 파일뷰어 연결 (drm등)
- (void)openFile:(CDVInvokedUrlCommand *)command;
- (void)callPhone:(CDVInvokedUrlCommand *)command;
- (void)sendSMS:(CDVInvokedUrlCommand *)command;
- (void)sendMail:(CDVInvokedUrlCommand *)command;
- (void)backSendMail:(CDVInvokedUrlCommand *)command;
- (void)insertContact:(CDVInvokedUrlCommand *)command;

@end
