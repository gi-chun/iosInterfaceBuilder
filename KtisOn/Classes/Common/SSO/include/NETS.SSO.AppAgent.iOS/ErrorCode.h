//
//  ErrorCode.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 20..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"
@interface ErrorCode : NSObject
enum AppErrorCode
{
    NoError =0,
    //네트워크 단절 스마트 폰에서 데이터 통신 설정이 꺼져 있거나, 네트워크 통신이 불가능한 상태
    NetworkOffLine = 14000001,
    
    //네트워크 통신이 가능하지만, NSSO 인증 서버와 통신이 불가능한 상태
    SSOLiveCheckFail = 14000002,
    
    //네트워크 통신 불가 상태(오프라인)로 단말기에 저장되어 있는 오프라인 인증 토큰이
    //존재하지 않음. 인증 불가능 상태, 네트워크 통신이 가능한 상황에서 앱 인증을 다시
    //받아야 정상적으로 앱을 사용할 수 있음.
    NonExistOffLineToken = 14000003,
    
    //네트워크 통신 불가 상태(오프라인)로 단말기에 저장되어 있는 오프라인 인증 토큰을
    //검사한 결과, 오프라인 인증 토큰의 유효 기간이 초과되어 인증할 수 없음. 네트워크
    //통신이 가능한 상황에서 앱 인증을 다시 받아야 정상적으로 앱을 사용할 수 있음.
    InvalidOffLineToken = 14000004,
    
    //네트워크 통신 불가 상태(오프라인)로 단말기에 저장되어 있는 오프라인 인증 토큰을
    //검사한 결과, 오프라인 인증 토큰의 유효 기간이 초과되지 않아 오프라인 인증 토큰을
    //이용하여 인증할 수 있음. 4005 오류 코드를 반환받은 앱은 사용자 ID/PWD를 입력할 수
    //있는 로그온 UI를 사용자에게 제공하여 재 인증을 받아야 함.
    ValidOffLineToken = 14000005,
    
    //암호화되어 있는 인증 처리 관련 데이터의 복호화 오류.
    DecryptError = 14000006,
    
    //인증 처리 관련 데이터의 암호화 오류.
    EncryptError = 14000007,
    
    //라이브 인증 토큰 형식이 올바르지 않음.
    InvalidLiveToken = 14000008,
    
    //라이브 인증 토큰의 유효기간이 초과함. 재 인증 받아야 함.
    ExpiredLiveToken = 14000009,
    
    //오프라인 인증 처리 과정에서 제공된 사용자 자격 증명이 올바르지 않음. 사용자 ID 또는 비밀번호가 일치하지 않음
    InvalidOffLineCredential = 14000010,
    
    //앱 인증 정책을 인증서버에 요청하는 동안 오류가 발생함.
    FailedToSSOPolicy = 14000011,
    
    //App 에이전트 설정 파일에 기록되어 있는  NSSOConfig/SSOProvider/@providerDomain의 값과 인증 서버에서 다운로드
    //정책에 설정되어 있는 인증 제공자 식별자가 일치하지 않음.
    MismatchSSOProvider = 14000012,
    
    //App 에이전트 설정 파일에 기록되어 있는 NSSOConfig/@appID의 값과 인증 서버에서 다운로드한
    //정책에 설정되어 있는 앱 식별자가 일치하지 않음.
    MismatchAppID = 14000013,
    
    //알 수 없는 내부 오류. .NET Framework에서 발생한 오류
    InternalError = 14000014,
    
    //인증서버에 로그온을 요청하였지만, 인증 서버에서 반환된 결과가 인증 실패이다.
    //이 오류 코드가 반환되면, 앱은 ServerErrorCode를 확인해서 어떤 오류 인지를 확인해야 한다.
    FailedToLogon = 14000015,
    
    //앱과 함꼐 배포된 미리 정의된 SSO 환경 설정 파일이 존재하지 않음, SSO를 이용할 수 없음.
    MissingNSSOConfig = 14000016,
    
    //인증 처리 결과로 인증 토큰을 로컬 저장소에 설치하는데 실패함.
    FailedToSaveToken = 14000017,
    
    //인증 서버에서 전송된 사용자 자격증명(사용자 ID와 암호)을 이용하여 사용자 확인을 했지만.
    //사용자 ID 또는 암호가 올바르지 않음.
    InvalidUserCredential = 14000018,
    
    //인증서버와 연결할 수 없는 상황에서 등록된 App이 오프라인 인증을 사용하지 않도록 설정되어 있음.
    NotUsingOffLine = 14000021
  
};
@end
