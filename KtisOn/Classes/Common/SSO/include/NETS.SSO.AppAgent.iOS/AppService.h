//
//  AppService.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 4. 8..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AuthCheck.h"
@interface AppService : NSObject<NSURLConnectionDelegate,NSXMLParserDelegate>

-(id)AppService;

-(void)setUrl:(NSString *)url;
-(NSString *)getUrl;

-(void)setTimeOut:(NSInteger)WebServiceCallTimeOut;
-(float)getTimeOut;

-(NSString *)RequestSSOPolicy:(NSString *)ssoProvider :(NSString *)appID;

-(NSString *)CheckLogon:(NSString *)appID :(NSString *)deviceID :(NSString *)ssoProvider;

-(NSString *)LogonUser:(NSString *)appID :(NSString *)deviceID :(NSString *)ssoProvider :(NSString *)deviceIP :(NSString *)credType :(NSString *)userID :(NSString *)pwd;

-(NSString *)LogonUserFromWebAppToken:(NSString *)appID :(NSString *)deviceID :(NSString *)ssoDomain :(NSString *)deviceIP :(NSString *)webAppToken;

-(NSString *)UpdateToken:(NSString *)appID :(NSString *)deviceID :(NSString *)ssoProvider :(NSString *)token;

-(NSString *)LogoffUser:(NSString *)appID :(NSString *)deviceID :(NSString *)ssoProvider :(NSString *)token;

@end
