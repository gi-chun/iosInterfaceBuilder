//
//  ServerErrorCode.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 15..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"
@interface ServerErrorCode : NSObject
enum ServerErrorCode
{
#pragma mark NoError 오류가 발생하지 않음
    //오류가 발생하지 않음
    NOError = 0,
    
#pragma mark [1000xxxx]공통 오류 코드 정의
    // 인증 서버에서 제공하는 공용함수에 전달된 입력 매개 변수가 누락되었거나, 값이 올바르지 않음
    InvalidParameter = 10000001,
    
    // SSO 오류가 아닌 iOS 에서 발생한 오류일 경우 사용함.
    RaisediOS = 10000002,
    
    // 중앙인증 도메인 정보가 전달되지 않음
    MissingSSOProvider = 10000003,
    
    // 사용자 아이디 정보가 전달되지 않음.
    MissingUserID = 10000006,
    
    // 비밀번호 정보가 전달되지 않음.
    MissingPwd = 10000007,
    
    // CredType 정보가 전달되지 않음.
    MissingCredType = 10000009,
    
    // IP 정보가 전달되지 않음.
    MissingIP = 10000010,
    
    // 도메인 인증토큰 정보가 전달되지 않음.
    MissingWebToken = 10000011,
    
    // App ID 정보가 전달되지 않음.
    MissingAppID = 10000012,
    
    // Device ID 정보가 전달되지 않음.
    MissingDeviceID = 10000013,
    
    // App 토큰 정보가 전달되지 않음.
    MissingAppToken = 10000014,
    
    // 사용자 정보 항목이 값이 전달되지 않음.
    MissingUserCookie = 10000015,
    
    // 웹 서비스 실행 시 입력값이 복호화 되지 않음.
    DEcryptError = 10000016,
    
    // 웹 서비스 실행 시 리턴 값의 암호화 시 오류가 발생함.
    ENcryptError = 10000017,
    
    // 인증정책엔진을 load했지만 (nil)null이어서 실행하지 못함.
    NullPolicyRule = 10000019,

#pragma mark [11xxxxxx] 인증 서버 오류 코드 정의
    
    #pragma mark [1101xxxx] ConfigCachManager 오류코드
        
        //전송된 인증 제공자(중앙인증 도메인)가 올바르지 않음.
        InvalidSSOProvider = 11010001,
        
        //서비스를 요청한 App이 유효한 앱이 아님.
        InvalidAppID = 11010002,
        
        
        //참여 도메인 정보가 유효하지 않음. (등록되지 않음)
        InvalidSSODomain = 11010003,
        
        
        //사이트 도메인 정보가 유효하지 않음
        InvalidSSOSite = 11010004,
        
        
        //사이트 도메인 서버 IP 정보가 유효하지 않음.
        InvalidSSOSiteServerIP = 11010005,
        
        //시스템ID 정보가 유효하지 않음.
        InvalidSSOIPSiteSystemID = 11010006,
        
        //중앙인증서버 배포를 등록되지 않은 중앙인증 서비스 서버에서 호출하였다.
        InvalidSSOProviderServerIP = 11010007,
    
    
    #pragma mark [1102xxxx] 자격증명(Credential) 오류코드
        // 인증 저장소에 사용자 아이디가 존재 하지 않음.
        NotExistUserID = 11020003,
    
        // 입력 받은 사용자의 비밀번호가 틀림.
        NotSamePwd = 11020004,
    
        // Policy에 UserCredentialType에 맞는 Handler가 설정되지 않았습니다. nil(NULL 값입니다.)
        NotSetCredentialHandler = 11020007,
    
    #pragma mark [1103xxxx] Token 정책 오류 코드.
        // 중앙인증토큰 정보 확인(복호화) 시 오류 발생.
        FailToProviderAuthCookie = 11030001,
    
        // 도메인인증토큰 생성 시 오류 발생함.
        FailToSSODomainAuthCookie = 11030002,
    
        // 참여 도메인을 위한 Custom 쿠키를 생성하는데 실패 했음
        FailToSSODomainCustomCookie = 11030003,
    
        // Policy에 Token Handler가 설정되지 않았습니다.
        NotSetTokenHandler = 11030004,
    
        // Token의 idle 타임아웃이 발생하였습니다.
        TokenIdleTimeout = 11030005,
    
        // Token의 인증만료 시간이 지났습니다.
        TokenExpired = 11030006,
    
    #pragma mark [1104xxxx] Session 정책 오류코드.
        // MainAppSession 정보 생성 시 오류 발생
        FailCreateMainAppSession = 11040001,
    
        // MainAppSession 정보 수정 시 오류 발생
        FailUpdateMainAppSession = 11040002,
    
        // AppSession 정보 생성 시 오류 발생
        FailCreateAppSession = 11040003,
    
        // AppSession 정보 수정 시 오류 발생.
        FailUpdateAppSession = 11040004,
    
        // MainAppSession 정보 삭제 시 오류 발생.
        FailDeleteMainAppSession = 11040005,
    
        // AppSession 정보 삭제 시 오류 발생.
        FailDeleteAppSession = 11040006,
    
        // MainAppSession에 입력한 userid && sessionValue가 없음.
        NoExistUserIDSessionValue = 11040007,
    
        // MainAppSession에 입력한 deviceID가 없음.
        NoExistDeviceID = 11040008,
    
        SameDeviceIDNotSameUserID = 11040009,
    
    #pragma mark [1105xxxx] UserLock 정책 오류코드.
        // UserLock 핸들러가 설정되지 않았습니다.
        NotSetUserLockHandler = 11050001,
    
        // 잠긴 사용자 입니다.
        UserLocked =  11050002,
    
    #pragma mark [1106xxxx] 중복로그인 정책 오류코드.
        // 선입자 우선인 경우, 이미 로그인한 사용자 입니다.
        AlreadyLogonSession = 11060001,
    
        // 후입자 우선인 경우
        NotifyLogonSession = 11060002,
    
    #pragma mark [1107xxxx] 비밀번호만료 정책 오류코드.
        // 비밀번호 만료 핸들러가 설정되지 않았습니다.
        NotSetPwdExpireHandler = 11070001,
    
        //사용자의 비밀번호가 만료되었습니다.
        UserPwdExpired = 11070002,
    
        //비밀번호 만료 알림기간 입니다.
        UserPwdExpiredNotify = 1107003,
    
    #pragma mark [1108xxxx] ACL 정책 오류코드
        //Acl 핸들러가 설정되지 않았습니다.
        NotSetAclHandler = 11080001,
    
        // 사용자의 접근이 거부되었습니다.
        UserAccessDenied = 11080002,
    
    /**
     * KTIS용 초기 사용자 패스워드 변경
     * 초기 패스워드 변경 사용자 입니다.
     */
    UserPasswordModifyKtis = 50000001,
    
    /**
     * KTIS 용 PWD가 Null 인경우 비정상 사용자
     * 비정상 사용자 입니다. 관리자에게 문의 하세요.
     */
    UserPasswordNullKtis = 50000002,
    
    /**
     * KTIS 용 초기 PWD확인용 생년월일이 Null 인경우 비정상 사용자
     * 비정상 사용자 입니다. 관리자에게 문의 하세요.
     */
    UserBirthNullKtis = 50000003
};

@end
