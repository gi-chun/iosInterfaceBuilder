//
//  SSOController.m
//  SSOTest
//
//  Created by Hyuck on 3/10/14.
//  Copyright (c) 2014 hyuck. All rights reserved.
//

#import "SSOController.h"
#import "AuthCheck.h"
#import "ErrorMessage.h"
#import "Defines.h"

@interface SSOController()
{
    NSInteger _loginFailCount;
}
@end

@implementation SSOController

@synthesize authCheck = _authCheck;

#pragma mark - Life Cycle
static dispatch_once_t once;
static SSOController *_sharedInstance = nil;

+ (SSOController *) sharedInstance
{
    if (!_sharedInstance)
    {
        dispatch_once(&once, ^{
            _sharedInstance = [[SSOController alloc] init];
        });
    }
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _authCheck = [[AuthCheck alloc] AuthCheck];
        _loginFailCount = 0;
    }
    return self;
}


#pragma mark -
#pragma mark 인증상태 조회 (결과를 문자열로 반환해서 뷰에서 얼럿처리하도록 해야 함)
- (NSDictionary *)requestSSOStatus
{
    NSLog(@"***[SSO] 인증상태조회 시작***");
    
    BOOL _isSSOSuccess = NO;
    
    @try
    {
        //1. NSSO가 제공하는 App 인증 에이전트 객체를 생성한다.
        //authCheck 객체생성은 delegate 에 선언함
        
        //2. NSSO에 인증 확인을 요청한다.
        enum SSOStatus status = [_authCheck CheckLogon];
        
        if(status == (enum SSOStatus)SSOFail) //3. 인증 체크 결과 인증 실패이다.
        {
            // 사용자에게 인증을 위한 사용자 ID/비밀번호를 요청하여 인증을 수행한다.
            [self processLogonFailed:(AuthFailResult *)[_authCheck getResult]];
        }
        
        if(status == (enum SSOStatus)SSOSuccess) //4.인증 체크 결과 인증 성공이다.
        {
            //인증 성공 처리한다.
            [self processCheckLogonSuccess:(AuthSuccessResult *)[_authCheck getResult]];
            
            _isSSOSuccess = YES;
        }
        
    }
    @catch (NSException *exception)
    {
        AppException *appEx = (AppException *)exception;
        NSString *appErrorMsg = [ErrorMessage GetAppErrorMessage:[appEx getAppError]];
        NSString *serverErrorMsg = [ErrorMessage GetServerErrorMessage:[appEx getServerError]];
        NSString *msg = [NSString stringWithFormat:@"App 에이전트 결과\n%@\n 인증서버 결과\n%@", appErrorMsg, serverErrorMsg];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
    NSDictionary *dicUserInfos = nil;
    if (_isSSOSuccess) {
        AuthSuccessResult *ssoResult = (AuthSuccessResult *)[_authCheck getResult];
        dicUserInfos = [ssoResult getUserInfos];
    }
    
    return dicUserInfos;
}

#pragma mark 로그온 (마찬가지로 결과를 문자열로 리턴해서 로그인 결과를 보내서 처리하도록 해야한다)
- (NSInteger)requestLogon:(NSDictionary *)loginInfoDic
{
    NSLog(@"[timestamp] SSO 로그인 시작");
    NSInteger logonResultCode = 0;
    
    NSString *userId = [loginInfoDic objectForKey:@"id"];
    NSString *userPw = [loginInfoDic objectForKey:@"pw"];
    
    //본 App이 실행되는 device에 할당된 IP 주소를 구한다
    enum SSOStatus status= [_authCheck Logon:(enum UserCredentialType)BasicCredential :userId :userPw]; //중복로그인후 후입자 우선일때 serverErrorCode NoError 문제
    NSLog(@"[SSO] 로그온 ERROR_CODE/%@", [NSString stringWithFormat:@"%d",status]);
    //인증 결과에 따라서 적절한 사용자 시나리오를 처리한다.
    if(status == (enum SSOStatus)SSOSuccess) //인증 성공에 대해서 처리한다.
    {
        NSLog(@"[SSO] 로그온 저장된 토큰값: %@",[_authCheck getAppToken]);
        
        AuthSuccessResult *ssoResult = (AuthSuccessResult *)[_authCheck getResult];
        
        NSDictionary *dicUserInfos = [ssoResult getUserInfos];
        NSLog(@"[SSO] 로그온 유저정보:%@",dicUserInfos);
        
        // 이제 서버 오류 코드를 확인한다.
        // 인증에 성공했지만, 사용자 비밀번호 만료 정책 관련된 경고가 발생하거나
        // 중복로그온 정책에 따라서, 후입자 우선일 경우에 중복 로그온에 대한 추가적인 정보를 이용하여 사용자에게 알려야 한다.
        if([[_authCheck getResult] getServerError] != (enum ServerErrorCode)NoError)
        {
            [self processLogonWarning:ssoResult];
        }
    }
    else if(status == (enum SSOStatus)SSOFail)
    {
        AuthFailResult *ssoResult = (AuthFailResult *)[_authCheck getResult];
        [self processLogonFailed:ssoResult];
        
        logonResultCode = 1;
        
        // 핀로그인 실패시
        if ([ssoResult getAppError] == (enum AppErrorCode)InvalidUserCredential)
        {
            NSLog(@"핀로그인 실패");
            logonResultCode = 2;
        }
    }
    
    NSLog(@"[timestamp] SSO 로그인 끝");
    return logonResultCode;
}

#pragma mark 로그오프 (결과를 문자열로 반환해서 뷰에서 얼럿처리하도록 해야 함)
- (BOOL)requestLogoff
{
    NSLog(@"[timestamp] SSO 로그오프 시작");
    
    BOOL isLogoffSuccess = NO;
    
    enum SSOStatus status = [_authCheck Logoff];
    
    if(status ==(enum SSOStatus)SSOFail)
    {
        NSLog(@"[SSO] 로그오프 저장된 토큰값: %@",[_authCheck getAppToken]);
        isLogoffSuccess = YES;
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"성공" message:@"성공적으로 로그아웃되었습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
//        [alert show];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"로그오프하는 동안 오류가 발생했습니다. \n %@", [ErrorMessage GetAppErrorMessage:[[_authCheck getResult]getAppError]]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    NSLog(@"[timestamp] SSO 로그오프 끝");
    return isLogoffSuccess;
}

#pragma mark 인증된 리퀘스트 URL 조회
- (NSString *)requestCredentialUrl:(NSString *)targetUrl
{
    NSLog(@"***[SSO] 인증된 URL 조회 시작***");
    
    // appId
    NSString *AppID = [_authCheck getAppID];
    NSLog(@"[SSO] 인증된url조회 앱아이디: %@", AppID);
    
    // token result
    OfflineAuthData *authData   = [TokenStore GetOfflineAuthData];
    AuthToken *authToken        = (AuthToken *)[authData getOfflineToken];
    NSString *token_res         = [authToken ToStringAuthToken];
    
    // credential
    NSString *cred = @"APPTOKEN";
    
    // return url
    NSString *returnUrl = [targetUrl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    returnUrl = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)returnUrl,
                                                                                      NULL, (CFStringRef)@"!*’();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8));
    
    //gclee
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:targetUrl                                             delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
//    [alert show];
    
    
    NSString *ssoSiteTmp    = [[[[targetUrl componentsSeparatedByString:@"//"]objectAtIndex:1]componentsSeparatedByString:@":"] firstObject];
    NSString *ssoSite       = [[[[ssoSiteTmp componentsSeparatedByString:@"/"] firstObject] componentsSeparatedByString:@"?"] firstObject];
    NSLog(@"[SSO] ssoSite::%@", ssoSite);
    
    // complete url
    NSString *tokenUrl = [NSString stringWithFormat:@"%@appid=%@&apptoken=%@&credType=%@&returnURL=%@&ssosite=%@",
                          SSO_AUTH_SITE, AppID, token_res, cred, returnUrl, ssoSite];
    
    //gclee
//    UIAlertView *alert_ = [[UIAlertView alloc] initWithTitle:nil message:tokenUrl                                             delegate:self cancelButtonTitle:@"닫기" otherButtonTitles:nil, nil];
//    [alert_ show];
    
    
    return tokenUrl;
}



#pragma mark - 결과 처리
#pragma mark - 인증실패시 alert 처리
// 인증확인 실패 시 alert 메시지를 표시한다.
-(void)processLogonFailed:(AuthFailResult *)ssoResult
{
    NSLog(@"***[SSO] 인증실패처리 시작***");
    NSString *msg ;
    //날짜 포멧
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"]; //NSDate to NSString 변환
    
    //요일 포멧
    NSDateFormatter *day = [[NSDateFormatter alloc] init];
    [day setDateFormat:@"yyyy-MM-dd EEEE"];
    [day setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"ko_KR"]];
    
    if([ssoResult getAppError] == (enum AppErrorCode)FailedToLogon)
    {
        if ([ssoResult getAppError] == (enum AppErrorCode)InvalidUserCredential) {
            _loginFailCount++;
            if (_loginFailCount >= 4) {
                _loginFailCount = 0;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"blockLoginFailed"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        if([ssoResult getServerError] == (enum ServerErrorCode)UserLocked)
        {
            AuthFailResultWithUserLocked *result = (AuthFailResultWithUserLocked *)ssoResult; //.ET 에서는 as 로 접근
            if(![result getIsAutoRelease])
            {
                msg = @"인증 요청한 사용자 ID는 잠겨 있습니다. 현재 계정 잠금을 자동을 해제할 수 없습니다. 관리자에게 문의하십시오";
            }
            else
            {
//                NSString *autoReleaseTime = [dateFormat stringFromDate:[result getAutoReleaseTime]]; //날짜
                NSString *autoReleaseDay = [day stringFromDate:[result getAutoReleaseTime]];         //요일
                msg = [NSString stringWithFormat:@"인증 요청한 사용자 ID는 잠겨 있습니다. %@에 자동으로 잠금이 해제 됩니다",autoReleaseDay];
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            alert.tag = 2;
            [alert show];
        }
        
        else if([ssoResult getServerError] == (enum ServerErrorCode)UserPwdExpired)
        {
            AuthFailResultWithPwdExpired *result = (AuthFailResultWithPwdExpired *)ssoResult;
            
            NSString *pwdExpiredDate = [dateFormat stringFromDate:[result getPwdExpiredDate]];  //날짜
//            NSString *pwdExpiredDay = [day stringFromDate:[result getPwdExpiredDate]];          //요일
            
            msg = [NSString stringWithFormat:@"비밀번호 만료일은 %@로 이미 만료된 비밀번호를 사용하고 있습니다. 비밀번호를 변경해 주세요",pwdExpiredDate];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            alert.tag = 2;
            [alert show];
        }
        
        else if([ssoResult getServerError] == (enum ServerErrorCode)AlreadyLogonSession)
        {
            AuthFailResultWithDuplicatedLogon *result = (AuthFailResultWithDuplicatedLogon *)ssoResult;
            NSString *anotherLogonTime = [dateFormat stringFromDate:[result getAnotherLogonTime]];
            NSString *anotherLastCheckTime = [dateFormat stringFromDate:[result getAnotherLastCheckTime]];
            
            msg = @"다른 사용자가 당신의 ID를 이용하여 다음과 같은 장비에서 로그온되어 있어, 사용자 인증을 수행할 수 없습니다.\n";
            msg = [msg stringByAppendingString:@"접속 IP = %@\n"];
            msg = [msg stringByAppendingString:@"접속 장비 식별자 = %@\n"];
            msg = [msg stringByAppendingString:@"로그온 시간 = %@\n"];
            msg = [msg stringByAppendingString:@"마지막 접속 시간 \n= %@"];
//            NSDate *anotherLogonTime = [result getAnotherLogonTime];
//            NSDate *anotherLastCheckTime = [result getAnotherLastCheckTime]
            
            msg = [NSString stringWithFormat:msg,[result getAnotherIP],[result getAnotherDeviceID],anotherLogonTime,anotherLastCheckTime];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            alert.tag = 2;
            [alert show];
        }
        
        else if([ssoResult getServerError] == (enum ServerErrorCode)NoExistDeviceID)
        {
            msg = @"다른 App을 사용하여 현재 인증되어 있는지 확인하였지만, 인증 기록이 없습니다.\n지금 로그온 하시겠습니까?";
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"아니오" otherButtonTitles:@"예", nil];
            alert.tag = 2;
            [alert show];
//            viewLogonForm =false;
        }
        else if([ssoResult getServerError] == (enum ServerErrorCode)SameDeviceIDNotSameUserID)
        {
            msg = [msg stringByAppendingString:@"다른 아이디로 로그인 해 주십시오."];
            msg = [NSString stringWithFormat:@"%@",[ErrorMessage GetServerErrorMessage:[ssoResult getServerError]]];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            alert.tag = 2;
            [alert show];
        }
        else
        {
            msg = @"인증확인에 실패 했습니다.";
            msg = [msg stringByAppendingFormat:@"%@",[ErrorMessage GetServerErrorMessage:[ssoResult getServerError]]];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            alert.tag = 2;
            [alert show];
        }
    }
    else //if failtologon
    {
        _loginFailCount++;
        if (_loginFailCount >= 4) {
            _loginFailCount = 0;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"blockLoginFailed"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"경고" message:[ErrorMessage GetAppErrorMessage:[ssoResult getAppError]] delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        alert.tag = 2;
        [alert show];
//        viewLogonForm =false;
    }
}

#pragma mark - 인증확인 (결과를 델리게이트 프로토콜로 알릴것인지 고민해봐야 한다)
// 인증확인 성공 후, 인증확인 시간 및 사용자 정보를 표시한다.
- (void)processCheckLogonSuccess:(AuthSuccessResult *)ssoResult
{
    NSDictionary *dicUserInfos = [ssoResult getUserInfos];
    NSLog(@"***[SSO] 인증성공결과처리 시작*** 저장된 토큰값: %@\n유저정보:%@",[_authCheck getAppToken], dicUserInfos);
}

#pragma mark - 인증성공 후 인증유효 체크
// 인증확인에 성공은 했지만 비밀번호가 만료되었지만 인증한 경우, 중복로그인 정책을 사용하고, 후입자 우선인 경우, 인증확인 요청한 사용자에게 정보를 표시하기 위해 사용한다.
- (void)processLogonWarning:(AuthSuccessResult *)ssoResult
{
    NSLog(@"***[SSO] 인증성공 후 인증유효체크 시작***");
    
    //날짜 포멧
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
    //요일 포멧
    NSDateFormatter *day = [[NSDateFormatter alloc] init];
    [day setDateFormat:@"yyyy-MM-dd EEEE"];
    [day setLocale:[[NSLocale alloc]initWithLocaleIdentifier:@"ko_KR"]];
    
    //비밀번호 만료가 압박했음을 인증 서버가 알려 왔음으로 이에 대해서 사용자에 통보해야 한다.
    if([ssoResult getServerError] == (enum ServerErrorCode)UserPwdExpiredNotify) {
        AuthSuccessResultWithPwdExpired *result = (AuthSuccessResultWithPwdExpired *)ssoResult;
        NSString *msg = [NSString new];
        
        NSString *pwdExpiredDate = [dateFormat stringFromDate:[result getPwdExpiredDate]];  //날짜
//        NSString *pwdExpiredDay = [day stringFromDate:[result getPwdExpiredDate]];          //요일
        
        if([result getRemainDay] > 0)
            msg = [NSString stringWithFormat:@"비밀번호 만료일은 %@로 %ld일 남았습니다. 비밀번호를 변경 주세요", pwdExpiredDate,(long)[result getRemainDay]];
        else
            msg = [NSString stringWithFormat:@"비밀번호 만료일은 0일 입니다. 비밀번호를 변경해 주세요."];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if([ssoResult getServerError] == (enum ServerErrorCode)UserPwdExpired) {
        AuthSuccessResultWithPwdExpired *result = (AuthSuccessResultWithPwdExpired *)ssoResult;
        NSString *pwdExpiredDate = [dateFormat stringFromDate:[result getPwdExpiredDate]]; //날짜
//        NSString *pwdExpiredDay = [day stringFromDate:[result getPwdExpiredDate]];         //요일
        NSString *msg =[NSString stringWithFormat:@"비밀번호 만료일은 %@로 이미 만료된 비밀번호를 사용하고 있습니다. 비밀번호를 변경해 주세요", pwdExpiredDate];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    else if([ssoResult getServerError] == (enum ServerErrorCode)NotifyLogonSession) {
        AuthSuccessResultWithDuplicatedLogon *result = (AuthSuccessResultWithDuplicatedLogon *)ssoResult;
        NSString *anotherLogonTime = [dateFormat stringFromDate:[result getAnotherLogonTime]];
        NSString *anotherLastCheckTime = [dateFormat stringFromDate:[result getAnotherLastCheckTime]];
        
        NSString *msg =@"다른 사용자가 당신의 ID를 이용하여 다음과 같은 장비에서 로그인되어 있습니다.\n";
        msg = [msg stringByAppendingString:@"접속 IP = %@\n"];
        msg = [msg stringByAppendingString:@"접속 장비 식별자 = %@\n"];
        msg = [msg stringByAppendingString:@"로그온 시간 = %@\n"];
        msg = [msg stringByAppendingString:@"마지막 접속 시간 \n= %@\n"];
        msg = [NSString stringWithFormat:msg,[result getAnotherIP],[result getAnotherDeviceID], anotherLogonTime, anotherLastCheckTime];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - 포그라운드로 올라올 때 인증체크
- (BOOL)checkSSOFromForeground
{
    BOOL authFailed = NO;
    @try
    {
        //1. NSSO가 제공하는 App 인증 에이전트 객체를 생성한다.
        //authCheck 객체생성은 delegate 에 선언함
        
        //2. NSSO에 인증 확인을 요청한다.
        //enum SSOStatus status = [dele.authCheck CheckLogon];
        enum SSOStatus status = [self.authCheck CheckLogonFromForeground];
        
        //통신 완료후 애니메이션 종료
//        [indicatorview stopAnimating];
        [[UIApplication sharedApplication]endIgnoringInteractionEvents];
        
        if(status == (enum SSOStatus)SSOFail) //3. 인증 체크 결과 인증 실패이다.
        {
            // 사용자에게 인증을 위한 사용자 ID/비밀번호를 요청하여 인증을 수행한다.
            [self processLogonFailed:(AuthFailResult *)[self.authCheck getResult]];
        }
        
        if(status == (enum SSOStatus)SSOSuccess) //4.인증 체크 결과 인증 성공이다.
        {
            //인증 성공 처리한다.
            [self processCheckLogonSuccess:(AuthSuccessResult *)[self.authCheck getResult]];
        }
        
    }
    @catch (NSException *exception)
    {
        AppException *appEx = (AppException *)exception;
        NSString *msg = [NSString stringWithFormat:@"App 에이전트 결과\n%@\n 인증서버 결과\n%@",
                         [ErrorMessage GetAppErrorMessage:[appEx getAppError]],[ErrorMessage GetServerErrorMessage:[appEx getServerError]]];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"경고" message:msg delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alert show];
        
        authFailed = YES;
    }
    
    return authFailed;
}

@end
