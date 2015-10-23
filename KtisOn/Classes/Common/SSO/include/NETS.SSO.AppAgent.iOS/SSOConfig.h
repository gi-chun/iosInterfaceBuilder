//
//  SSOConfig.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 19..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"



//중앙인증 도메인 설정이 세션관리로 설정되어 있을 때, 즉 중복 로그인 방지 기능이 켜져있을 때,
//이미 로그인한 사용자와 후 순위로 로그인 요청한 사용자의 처리를 어떻게 할 것인가를 식별한다.
enum DuplicatedLogonOption
{
    UnusedSession = 1000,
    //중복 로그인이 요청되었을 때, 선 순위로 로그인을 완료한 사용자가 우선 순위를 갖는다.
    //즉 후순위 로그인 요청자는 결코 인증 받을 수 없다.
    FirstPriority = 1001,
    
    //중복 로그인이 요청되었을 때, 후순위 로그인 요청자가 우선 순위를 갖는다.
    //즉 선순위로 로그인 완료한 사용자가 존재하는 상황에서, 후순위 로그인 요청이 있을 경우에,
    //먼저 로그인한 사용자를 로그아웃 처리하고, 나중에 로그인 기본 설정값이다.
    LastPriority = 1002
};

@interface SSOConfig : NSObject<NSXMLParserDelegate>
-(const NSString *)getDataSeperator;
// public-method
// nssoconfig.xml 메서드 선언
-(Boolean)getUsingSSL;
-(NSString *)getAppID;
-(void)setDeviceID:(NSString *)sValue;
-(NSString *)getDeviceID;
-(NSInteger)getWebServiceCallTimeOut;
-(NSString *)getSSOProvider;
-(NSString *)getAppServiceURL;
-(enum EncType)getConfigCryptoType;
-(NSString *)getConfigCryptoKey;
-(enum EncType)getConfigHashType;
// SSO 서버 정책 메서드 선언
-(NSInteger)getIdleTimeOut;
-(Boolean)getUsingDuplicatedLogon;
-(enum DuplicatedLogonOption)getDuplicatedLogonCheckOption;
-(NSInteger)getDuplicatedLogonCheckPeriod;
-(Boolean)getUsingACLCheck;
-(Boolean)getUsingTokenExpire;
-(NSInteger)getTokenExpireTimeOut;
-(Boolean)getUsingOffLine;
-(NSInteger)getOffLineTokenTimeOut;
-(Boolean)getUsingSSO;
-(NSString *)getConfigRevision;
-(NSString *)getAppTokenName;
-(enum EncType)getAppTokenEncType;
-(NSString *)getAppTokenEncKey;
-(NSString *)getAppCookieName;
-(enum EncType)getAppCookieEncType;
-(NSString *)getAppCookieEncKey;
-(NSMutableArray*)getAppUserInfoNameList;
//static mathod
+(SSOConfig*)GetInstance;
-(void)InitializeConfig:(Boolean)startUp;


@end
