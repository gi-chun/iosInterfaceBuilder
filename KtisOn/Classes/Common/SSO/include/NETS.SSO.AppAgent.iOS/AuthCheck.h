//
//  NETS_SSO_AppAgent_iOS.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 14..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CFNetwork/CFNetwork.h>
#import "Aes.h"
#import "CryptUtil.h"
#import "Des.h"
#import "ICryptoBase.h"
#import "Md5.h"
#import "Sha.h"
#import "TripleDES.h"

#import "AppException.h"
#import "AuthResult.h"
#import "AuthToken.h"
#import "ErrorCode.h"
#import "ServerErrorCode.h"
#import "SSOConfig.h"
#import "SSOCrypt.h"
#import "SSOUtility.h"
#import "TokenStore.h"
#import "NetworkInterface.h"

#import "AppService.h"

//광고식별자 키 관련 프레임워크
#import <AdSupport/ASIdentifierManager.h>


enum SSOStatus
{
    SSOFail = 0,
    SSOSuccess = 1
};

#pragma mark SSO에 참여하는 App이 사용자 인증을 위해서 사용자가 요청한 사용자 자격 증며의 종류를 식별한다.
enum UserCredentialType
{
    Unknown = 0,

    // 일반적인 평문 형태의 사용자 ID와 비밀번호를 사용함.
    BasicCredential = 1,
    
    // 암호화된 사용자 ID와 비밀번호를 사용함.
    EncrypteBasicCredential = 2,
    
    // PKI 공인 인증서를 통해서 PKI CA에서 인증을 완료한 후에
    // 인증받은 공인 인증서와 연결된 사용자 식별자(Distinguished Name)를 이용함.
    // 이때 사용자의 DN은 암호화된 값이다.
    PKICertCredential = 3,
    
    // 평문 : (ID, OTP) / 암호화 :(PWD, HP)
    OTPCombined = 6,
    
    // 도메인에 인증(window 통합인증)된 계정정보(name)와 SID값을 가지고 인증
    // DomainEnctype에 따라 암호화 되어 전달됨
    DirectoryServiceTokenCredential = 7,
    
    // WebApp To App 인증 연동을 위해서 App 전송된 중앙 인증 도메인 토큰
    WebAppToken = 8
};

@interface AuthCheck : NSObject<NSXMLParserDelegate>
-(NSString *)getDeviceID;
-(NSString *)getDeviceIP;

-(id)getResult;
-(id)AuthCheck;
-(NSString *)getAppToken;
-(NSString *)getAppID;
-(void)setAppID:(NSString *)sValue;

-(Boolean)networkCondition;
-(enum SSOStatus)CheckLogon;
-(enum SSOStatus)CheckLogonFromForeground;
-(enum SSOStatus)Logon:(enum UserCredentialType)credType :(NSString *)userid :(NSString *)password;
-(enum SSOStatus)Logoff;
-(enum SSOStatus)LogonFromWebToken:(NSString *)domain :(NSString *)webToken;


@end












