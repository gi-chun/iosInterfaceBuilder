//
//  LoginManager.m
//  KtisOn
//
//  Created by Hyuck on 2/25/14.
//
//

#import "LoginManager.h"
#import "SecurityManager.h"
#import "KeychainItemWrapper.h"
#import "SettingManager.h"
#import "SSOController.h"

@interface LoginManager()
{
    KeychainItemWrapper *_keychainWrapper;
}
@end

@implementation LoginManager

#pragma mark - Life Cycle
- (id)init
{
    self = [super init];
    if (self) {
        _keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuth" accessGroup:nil];
//        [[SSOController sharedInstance] requestSSOStatus];
    }
    return self;
}

// SSO 인증상태 유효한지 검사
- (BOOL)getSSOStatusValid
{
    NSDictionary *ssoDic = [[SSOController sharedInstance] requestSSOStatus];
//    for (NSString *key in ssoDic)
//        NSLog(@"상태결과:%@/%@", key, [ssoDic objectForKey:key]);
    
    // 결과가 있으면 YES
    return (ssoDic)? YES:NO;
}

#pragma mark - Manage Login Informations in Keychain
// 키체인에 로그인 정보 저장
- (void)saveLoginInfoToKeychain:(NSDictionary *)loginDic
{
    [_keychainWrapper setObject:[NSString encodeString:[loginDic objectForKey:@"id"]] forKey:(__bridge id)(kSecAttrAccount)];
    [_keychainWrapper setObject:[NSString encodeString:[loginDic objectForKey:@"pw"]] forKey:(__bridge id)(kSecValueData)];
}

// 키체인에서 로그인 정보 가져옴
- (NSDictionary *)getLoginInfoFromKeychain
{
    // 키체인에서 암호화된 id, pw를 가져와 디코딩
    NSString *savedId = [NSString decodeString:[_keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)]];
    NSString *savedPw = [NSString decodeString:[_keychainWrapper objectForKey:(__bridge id)(kSecValueData)]];
    
    NSDictionary *tempDic = @{@"id":savedId, @"pw":savedPw};
    
    return tempDic;
}

// 로그인 정보 삭제
- (void)removeLoginInfo
{
    // 키체인에 저장된 로그인 정보를 지운다.
    NSLog(@"키체인에 저장된 로그인 정보 삭제!");
    [_keychainWrapper resetKeychainItem];
}


#pragma mark - Log In
- (void)requestLogin:(NSDictionary *)loginDic withPinCode:(BOOL)isPinLogin
{
    [self.delegate startedLogin];   // 인디케이터 구동
    
    NSDictionary *tmpLoginDic = @{};
    if (!isPinLogin)    //  일반 로그인 (텍스트 필드 입력값으로 로그인)
        tmpLoginDic = loginDic;
    else    // 핀코드 로그인 (키체인의 로그인 정보로 로그인)
        tmpLoginDic = [self getLoginInfoFromKeychain];
    
    // 인디케이터 종료 및 로그인 결과 표시
    NSInteger logonResultCode = [[SSOController sharedInstance] requestLogon:tmpLoginDic];
    [self.delegate endedLogin:logonResultCode];
}

-(NSInteger)daysFromDate:(NSDate *)startDate
                  toDate:(NSDate *)endDate
{
    NSCalendar *currentCalendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    
    NSCalendarUnit units = NSEraCalendarUnit|NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
    NSDateComponents *cp1, *cp2;
    
    cp1 = [currentCalendar components:units fromDate:startDate];
    cp2 = [currentCalendar components:units fromDate:endDate];
    cp1.hour = 12;
    cp2.hour = 12;

    NSDate *date1 = [currentCalendar dateFromComponents:cp1];
    NSDate *date2 = [currentCalendar dateFromComponents:cp2];
    return [[currentCalendar components:NSDayCalendarUnit
                               fromDate:date1
                                 toDate:date2
                                options:0] day];
}

@end
