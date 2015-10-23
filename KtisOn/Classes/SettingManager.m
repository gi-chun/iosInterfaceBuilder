//
//  SettingManager.m
//  ktis Mobile
//
//  Created by Hyuck on 2/1/14.
//
//

#import "SettingManager.h"
#import "SecurityManager.h"
#include <sys/types.h>
#include <sys/sysctl.h>
#import "SoapInterface.h"
#import "KeychainItemWrapper.h"
#import "SSOController.h"
#import "Defines.h"

@interface SettingManager()
{
    BOOL _isValidPushSwitch;
}
@end

@implementation SettingManager

static NSString * const kUUID              = @"currentUUID";        // UUID
static NSString * const kUserDeviceToken   = @"userDeviceToken";    // 디바이스 토큰
static NSString * const kUserPinCode       = @"usrPinCode";         // 핀코드
static NSString * const kOtpDate           = @"otpDate";            // OTP 인증날짜 day
static NSString * const kIdSave            = @"idSave";             // id save 여부
static NSString * const kIdValue            = @"idValue";           // id value
static NSString * const kOtpFail            = @"otpFailCount";      // otp fail count
static NSString * const kOtpMobileNumber            = @"otpMobileNumber";      // otp receive mobile number

static dispatch_once_t once;
static SettingManager *_sharedInstance = nil;
+ (SettingManager *) sharedInstance
{
    if (!_sharedInstance)
    {
        dispatch_once(&once, ^{
            _sharedInstance = [[SettingManager alloc] init];
        });
    }
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _isValidPushSwitch  = NO;
    }
    return self;
}

- (NSDictionary *)getSSOStatus
{
    NSDictionary *ssoDic = [[SSOController sharedInstance] requestSSOStatus];
    return ssoDic;
}

- (BOOL)requestSSOLogout
{
    //NSString *deviceToken = [self getDeviceToken];
    NSString *uuid = [self getUUID];
    //getUUID
    if (!uuid) {
        return 0;
    }
    else
    {
        BOOL logoutSuccess = YES;
        logoutSuccess = [[SoapInterface sharedInstance] setLogoutPorg:@{@"dvcId": uuid}];
        
        if (!logoutSuccess) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"로그아웃에 실패하였습니다" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
//            [alert show];
        }
        else
        {
            // 프로바이더에 저장된 디바이스 토큰을 삭제한 경우에만 로그아웃 시킨다
            logoutSuccess = [[SSOController sharedInstance] requestLogoff];
        }
        
        return logoutSuccess;
    }
}

#pragma mark - UUID
// UUID 저장
- (void)setUUID
{
    //NSString *uuid = [[NSUUID UUID]UUIDString];
    NSString* uniqueIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"UDID:: %@", uniqueIdentifier);
    
    [[NSUserDefaults standardUserDefaults] setObject:uniqueIdentifier forKey:kUUID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// UUID 출력
- (NSString *)getUUID
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUUID];
}

#pragma mark - otp mobile number
// otp receive mobile number 저장
- (void)setOtpMobileNumber:(NSString *)otpMobileNumber
{
    [[NSUserDefaults standardUserDefaults] setObject:otpMobileNumber forKey:kOtpMobileNumber];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// otp receive mobile number 출력
- (NSString *)getOtpMobileNumber
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kOtpMobileNumber];
}

#pragma mark - Device Token
// 디바이스 토큰 저장
- (void)setDeviceToken:(NSString *)deviceToken
{
    // 디바이스 토큰의 불필요한 문자열 제거
    NSString *deviceTokens = [[[[deviceToken description]
                                stringByReplacingOccurrencesOfString:@"<" withString:@""]
                               stringByReplacingOccurrencesOfString:@">" withString:@""]
                              stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // 디바이스 토큰을 user defaults에 저장
    [[NSUserDefaults standardUserDefaults] setObject:deviceTokens forKey:kUserDeviceToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 디바이스 토큰 출력
- (NSString *)getDeviceToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserDeviceToken];
}

#pragma mark - OTP
// OTP
- (void)saveOtpDate:(NSDate *)OtpDate
{
    [[NSUserDefaults standardUserDefaults] setObject:OtpDate forKey:kOtpDate];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSDate *)getOtpDate
{
    NSDate *returnDate = [[NSUserDefaults standardUserDefaults] objectForKey:kOtpDate];
    
    return returnDate;
}

#pragma mark - otp fail count
- (void)saveFailCount:(NSInteger)idSave
{
    [[NSUserDefaults standardUserDefaults] setInteger:idSave forKey:kOtpFail];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSInteger)getFaileCount
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kOtpFail];
}

#pragma mark - ID save
- (void)saveIdSave:(BOOL)idSave
{
    [[NSUserDefaults standardUserDefaults] setBool:idSave forKey:kIdSave];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)getIdSave
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kIdSave];
}

- (void)saveIdValue:(NSString *)idValue
{
    [[NSUserDefaults standardUserDefaults] setObject:idValue forKey:kIdValue];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString *)getIdValue
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kIdValue];
}


#pragma mark - Pin Code
// 핀코드 설정되어 있는지 여부
- (BOOL)isPinCodeValid
{
    NSString *savedPinCode = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPinCode];
    
    if (savedPinCode == nil || [savedPinCode isEqualToString:@""])
        return NO;
    else
        return YES;
}

// 핀코드를 암호화하여 user default에 저장
- (void)savePinCode:(NSString *)pinCode
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString encodeString:pinCode] forKey:kUserPinCode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 핀코드 초기화
- (void)initPinCode
{
    // 저장된 핀코드를 공백값으로 수정
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kUserPinCode];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// 핀코드 일치 여부
- (BOOL)isMatchedPinCode:(NSString *)pinCode
{
    NSString *savedPinCode = [[NSUserDefaults standardUserDefaults] objectForKey:kUserPinCode];
    return ([savedPinCode isEqualToString:[NSString encodeString:pinCode]]);
}




#pragma mark - Push Allows Statement
// 푸쉬 여부를 현재 클래스에 담는다
- (void)setPushStatus:(NSArray *)pushArr
{
    for (id obj in pushArr) {
        // 푸쉬 수신 여부 user defaults에 저장
        NSString *pushCode  = [obj objectForKey:@"code"];
        BOOL receiveYn      = ([[obj objectForKey:@"rcvYn"] isEqualToString:@"Y"])? YES:NO;  // 푸쉬 수신 여부
        
        if ([pushCode isEqualToString:@"PS01"])         // PS01 영업지원
            [[NSUserDefaults standardUserDefaults] setBool:receiveYn forKey:ALLOW_PUSH_SAILS];
        else if ([pushCode isEqualToString:@"PS02"])    // PS02 전자결재
            [[NSUserDefaults standardUserDefaults] setBool:receiveYn forKey:ALLOW_PUSH_DECISION];
        else if ([pushCode isEqualToString:@"PS03"])    // PS03 ktis메일
            [[NSUserDefaults standardUserDefaults] setBool:receiveYn forKey:ALLOW_PUSH_MAIL];
        else if ([pushCode isEqualToString:@"PS04"])    // PS04 hr
            [[NSUserDefaults standardUserDefaults] setBool:receiveYn forKey:ALLOW_PUSH_HR];
        else if ([pushCode isEqualToString:@"PS05"])    // PS05 조직도
            [[NSUserDefaults standardUserDefaults] setBool:receiveYn forKey:ALLOW_PUSH_CORPMAP];
        else if ([pushCode isEqualToString:@"PS06"])    // PS06 공지사항
            [[NSUserDefaults standardUserDefaults] setBool:receiveYn forKey:ALLOW_PUSH_NOTICE];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // 디바이스 토큰 등록 성공, 실패
        _isValidPushSwitch = [[obj objectForKey:@"registRegIdYn"] boolValue];
    }
}

// 푸쉬 수신 여부 리턴 (설정화면에서 사용)
- (NSDictionary *)getPushStatus
{
    NSDictionary *resultDic = @{@"hr"         : @([[NSUserDefaults standardUserDefaults] boolForKey:ALLOW_PUSH_HR]),        // PS01 영업지원
                                @"decision"   : @([[NSUserDefaults standardUserDefaults] boolForKey:ALLOW_PUSH_DECISION]),  // PS02 전자결재
                                @"mail"       : @([[NSUserDefaults standardUserDefaults] boolForKey:ALLOW_PUSH_MAIL]),      // PS03 ktis메일
                                @"sails"      : @([[NSUserDefaults standardUserDefaults] boolForKey:ALLOW_PUSH_SAILS]),   // PS04 hr
                                @"corpMap"    : @([[NSUserDefaults standardUserDefaults] boolForKey:ALLOW_PUSH_CORPMAP]),   // PS05 조직도
                                @"notice"     : @([[NSUserDefaults standardUserDefaults] boolForKey:ALLOW_PUSH_NOTICE])};   // PS06 공지사항
    return resultDic;
}

- (BOOL)isValidPushSwitch
{
    return _isValidPushSwitch;
}

- (BOOL)allowPush:(NSInteger)pushType isValid:(BOOL)isValid
{
    // 사번
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc]  initWithIdentifier:@"UserAuth" accessGroup:nil];
    NSString *employeeNumb = [NSString decodeString:[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)]];
    
    // UUID
//    NSString *uuid = [self getUUID];
    
    // 서비스 타입
    NSString *serviceType;
    // ktis메일 (PS03)
    if (pushType == 1)
        serviceType = @"PS03";
    // 전자결재 (PS02)
    else if (pushType == 2)
        serviceType = @"PS02";
    // hr (PS04)
    else if (pushType == 3)
        serviceType = @"PS04";
    // 공지사항 (PS06)
    else if (pushType == 4)
        serviceType = @"PS01";
    
    
    // 대사원서비스 (PS04)
    // 조직도 (PS05)
    NSString *uuid = [[SettingManager sharedInstance] getUUID];
    
    NSString *receiveYn = (isValid) ? @"Y":@"N";
    // 넘겨야 할 데이터 : 사번, UUID, 서비스타입, 사용여부 (uuid가 디바이스 토큰으로 대체됨)
//    NSDictionary *dic = @{@"empNo": employeeNumb, @"dvcId": [self getDeviceToken], @"code" : serviceType, @"rcvYn": receiveYn};
//    NSDictionary *dic = @{@"empNo": employeeNumb, @"regId": [self getDeviceToken], @"code" : serviceType, @"rcvYn": receiveYn};
        NSDictionary *dic = @{@"empNo": employeeNumb, @"dvcId": (uuid)?uuid:@"", @"code" : serviceType, @"rcvYn": receiveYn};
    BOOL isSuccess = [[SoapInterface sharedInstance] setAllowPush:dic];
    if (!isSuccess) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"푸쉬 설정에 실패하였습니다" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [alert show];
    }
    
    keychainWrapper = nil;
    
    return isSuccess;
}


#pragma mark - Hardware Version
// 하드웨어 버전 리턴 (프로바이더에 디바이스 토큰 등록시 파라미터로 사용)
- (NSString *) getHarwarePlatform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    
    return platform;
}

@end


