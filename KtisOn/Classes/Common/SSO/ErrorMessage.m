//
//  ErrorMessage.m
//  NETS.SSO.AppAgent.iOS.Simulator
//
//  Created by 김상용 on 13. 5. 7..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import "ErrorMessage.h"

@implementation ErrorMessage

+(NSString *)GetAppErrorMessage:(enum AppErrorCode)errCode
{
    switch ((enum AppErrorCode)errCode) {
        case (enum AppErrorCode)NoError:
            return @"에러가 발생하지 않았습니다.\n로그인 정보가 보이지 않을경우\n앱을 종료후 다시 실행해 주세요.";
        case (enum AppErrorCode)NetworkOffLine:
            return @"네트워크 연결이 불가능한 상황입니다. 인터넷에 연결 후 다시 시도하십시오.";
        case (enum AppErrorCode)SSOLiveCheckFail:
            return @"인증서버와 연결이 원활하지 않습니다. 잠시후 다시 시도하십시오.";
        case (enum AppErrorCode)NonExistOffLineToken:
            return @"네트워크 연결이 불가능한 상황에서 오프 라인 인증을 시도했지만, 오프라인 인증 토큰이 없습니다.";
        case (enum AppErrorCode)InvalidOffLineToken:
            return @"오프라인 인증을 시도했지만, 오프라인 인증 토큰의 유효 기간이 초과되어 인증을 수행할 수 없습니다.";
            // public const int ValidOffLineToken = 14000005; 이 오류 코드를 사용자에게 제공할 메시지가 없음.
        case (enum AppErrorCode)DecryptError:
            return @"데이터에 설정된 암호를 해독하는데 실패했습니다.";
        case (enum AppErrorCode)EncryptError:
            return @"데이터를 암호화하는데 실패했습니다.";
        case (enum AppErrorCode)InvalidLiveToken:
            return @"인증 토큰의 형식이 올바르지 않아 인증을 확인할 수 없습니다.";
        case (enum AppErrorCode)ExpiredLiveToken:
            return @"인증 토큰의 유효 기간이 초과되었습니다. 다시 인증하십시오.";
        case (enum AppErrorCode)InvalidOffLineCredential:
            return @"오프라인 인증 과정에서 사용자가 제공한 사용자 ID 또는 암호가 올바르지 않습니다.";
        case (enum AppErrorCode)FailedToSSOPolicy:
            return @"인증서버로 부터 인증 정책을 다운로드하는데 실패했습니다.";
        case (enum AppErrorCode)MismatchSSOProvider:
            return @"인증제공자를 식별하는 값이 틀립니다.";
        case (enum AppErrorCode)MismatchAppID:
            return @"실행중인 앱의 식별자와 인증서버에 등록된 앱의 식별자가 틀립니다.";
        case (enum AppErrorCode)FailedToLogon:
            return @"사용자 인증에 실패했습니다.";
        case (enum AppErrorCode)InternalError:
            return @"앱 에이전트 내부오류로 인해서 인증을 확인할 수 없습니다.";
        case (enum AppErrorCode)MissingNSSOConfig:
            return @"앱 인증을 수행하기 위해서 제공되는 환경설정 파일이 존재하지 않습니다.";
        case (enum AppErrorCode)FailedToSaveToken:
            return @"오프라인 인증을 위해서 사용할 인증 토큰을 저장하는데 실패했습니다.";
        case (enum AppErrorCode)InvalidUserCredential:
            return @"입력하신 ID 또는 패스워드가 \n올바르지 않습니다. 다시 확인해 주세요."; //사용자 ID 또는 암호가 올바르지 않습니다.
        case (enum AppErrorCode)NotUsingOffLine:
            return @"네트워크에 연결할 수 없거나, 인증 서버에 연결할 수 없지만, 현재 앱은 오프라인 인증을 사용하지 않기 때문에 인증을 수행할 수 없습니다.";
        default:
            return @"정의된 오류 코드가 아닙니다.";
    }
}

+(NSString *)GetServerErrorMessage:(enum ServerErrorCode)errCode
{
    switch ((enum ServerErrorCode)errCode) {
        case (enum ServerErrorCode)NOError:
            return @"에러가 발생하지 않았습니다.";
        case (enum ServerErrorCode)InvalidParameter:
            return @"인증 서버에서 제공하는 공용함수에\n전달된 입력 매개 변수가 누락되었거나\n값이 올바르지 않음";
        case (enum ServerErrorCode)RaisediOS:
            return @"SSO 오류가 아닌 iOS 에서 발생한 오류일 경우 사용함";
        case (enum ServerErrorCode)MissingSSOProvider:
            return @"중앙인증 도메인 정보가 전달되지 않음";
        case (enum ServerErrorCode)MissingUserID:
            return @"사용자 아이디 정보가 전달되지 않음.";
        case (enum ServerErrorCode)MissingPwd:
            return @"비밀번호 정보가 전달되지 않음";
        case (enum ServerErrorCode)MissingCredType:
            return @"Cred 정보가 전달되지 않음";
        case (enum ServerErrorCode)MissingIP:
            return @"IP 정보가 전달되지 않음";
        case (enum ServerErrorCode)MissingWebToken:
            return @"도메인 인증토큰 정보가 전돨되지 않음";
        case (enum ServerErrorCode)MissingAppID :
            return @"App ID 정보가 전달되지 않음.";
        case (enum ServerErrorCode)MissingDeviceID:
            return @"Device ID 정보가 전달되지 않음.";
        case (enum ServerErrorCode)MissingAppToken:
            return @"App 토큰 정보가 전달되지 않음.";
        case (enum ServerErrorCode)MissingUserCookie:
            return @"사용자 정보 항목이 값이 전달되지 않음.";
        case (enum ServerErrorCode)DEcryptError:
            return @"웹 서비스 실행 시 입력값이 복호화 되지 않음.";
        case (enum ServerErrorCode)ENcryptError:
            return @"웹 서비스 실행 시 리턴 값의 암호화 시 오류가 발생함.";
        case (enum ServerErrorCode) NullPolicyRule:
            return @"인증정책엔진을 load했지만 (nil)null이어서 실행하지 못함.";
        case (enum ServerErrorCode)NotExistUserID:
            return @"인증 저장소에 사용자 아이디가 존재 하지 않음.";
        case (enum ServerErrorCode)NotSamePwd:
            return @"입력 받은 사용자의 비밀번호가 틀림.";
        case (enum ServerErrorCode)NotSetCredentialHandler:
            return @"Policy에 UserCredentialType에 맞는\nHandler가 설정되지 않았습니다. nil(NULL 값입니다.)";
        case (enum ServerErrorCode)FailToProviderAuthCookie:
            return @"중앙인증토큰 정보 확인(복호화) 시 오류 발생.";
        case (enum ServerErrorCode)FailToSSODomainAuthCookie:
            return @"도메인인증토큰 생성 시 오류 발생함.";
        case (enum ServerErrorCode)FailToSSODomainCustomCookie:
            return @"참여 도메인을 위한 Custom 쿠키를 생성하는데 실패 했음";
        case (enum ServerErrorCode)NotSetTokenHandler:
            return @"Policy에 Token Handler가 설정되지 않았습니다.";
        case (enum ServerErrorCode)TokenIdleTimeout:
            return @"Token의 idle 타임아웃이 발생하였습니다.";
        case (enum ServerErrorCode)TokenExpired:
            return @"Token의 인증만료 시간이 지났습니다.";
        case (enum ServerErrorCode)FailCreateMainAppSession:
            return @"MainAppSession 정보 생성 시 오류 발생";
        case (enum ServerErrorCode)FailUpdateMainAppSession:
            return @"MainAppSession 정보 수정 시 오류 발생";
        case (enum ServerErrorCode)FailCreateAppSession:
            return @"AppSession 정보 생성 시 오류 발생";
        case (enum ServerErrorCode)FailUpdateAppSession:
            return @"AppSession 정보 수정 시 오류 발생.";
        case (enum ServerErrorCode)FailDeleteMainAppSession:
            return @"MainAppSession 정보 삭제 시 오류 발생.";
        case (enum ServerErrorCode)FailDeleteAppSession:
            return @"AppSession 정보 삭제 시 오류 발생.";
        case (enum ServerErrorCode)NoExistUserIDSessionValue:
            return @"MainAppSession에 입력한 userid && sessionValue가 없음.";
        case (enum ServerErrorCode)NoExistDeviceID:
            return @"MainAppSession에 입력한 deviceID가 없음.";
        case (enum ServerErrorCode)SameDeviceIDNotSameUserID:
            return @"인증확인을 요청한 사용자 ID가\n다른 기기를 사용하여 로그인 되어 있습니다.";
        case (enum ServerErrorCode)NotSetUserLockHandler:
            return @"UserLock 핸들러가 설정되지 않았습니다.";
        case (enum ServerErrorCode)UserLocked:
            return @"잠긴 사용자 입니다.";
        case (enum ServerErrorCode)AlreadyLogonSession:
            return @"선입자 우선인 경우\n이미 로그인한 사용자 입니다.";
        case (enum ServerErrorCode)NotifyLogonSession:
            return @"후입자 우선인 경우\n이미 로그인한 사용자 입니다.";
        case (enum ServerErrorCode)NotSetPwdExpireHandler:
            return @"비밀번호 만료 핸들러가 설정되지 않았습니다.";
        case (enum ServerErrorCode)UserPwdExpired:
            return @"사용자의 비밀번호가 만료되었습니다.";
        case (enum ServerErrorCode)UserPwdExpiredNotify:
            return @"비밀번호 만료 알림기간 입니다.";
        case (enum ServerErrorCode)NotSetAclHandler:
            return @"Acl 핸들러가 설정되지 않았습니다.";
        case (enum ServerErrorCode)UserAccessDenied:
            return @"사용자의 접근이 거부되었습니다.";
        case (enum ServerErrorCode)UserPasswordModifyKtis:
            return @"초기 비밀번호 사용자 입니다. 비밀번호를 변경하여 주시기 바랍니다.";
        case (enum ServerErrorCode)UserPasswordNullKtis:
            return @"비정상 사용자 입니다. 관리자에게 문의 하세요.";
        case (enum ServerErrorCode)UserBirthNullKtis:
            return @"비정상 사용자 입니다. 관리자에게 문의 하세요.";
        case (enum ServerErrorCode)InvalidSSOProvider:
            return @"전송된 인증 제공자(중앙인증 도메인)가 올바르지 않음.";
        case (enum ServerErrorCode)InvalidAppID:
            return @"서비스를 요청한 App이 유효한 앱이 아님.";
        case (enum ServerErrorCode)InvalidSSODomain:
            return @"참여 도메인 정보가 유효하지 않음. (등록되지 않음)";
        case (enum ServerErrorCode)InvalidSSOSite:
            return @"사이트 도메인 정보가 유효하지 않음";
        case (enum ServerErrorCode)InvalidSSOSiteServerIP:
            return @"사이트 도메인 서버 IP 정보가 유효하지 않음.";
        case (enum ServerErrorCode)InvalidSSOIPSiteSystemID:
            return @"시스템ID 정보가 유효하지 않음.";
        case (enum ServerErrorCode)InvalidSSOProviderServerIP:
            return @"중앙인증서버 배포를 등록되지 않은 중앙인증 서비스 서버에서 호출하였다.";
        default:
            return @"정의된 오류 코드가 아닙니다.";

    }
}

@end

