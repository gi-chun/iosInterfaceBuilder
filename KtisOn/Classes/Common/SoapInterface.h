//
//  SoapInterface.h
//  KtisOn
//
//  Created by Hyuck on 3/3/14.
//
//

#import <Foundation/Foundation.h>

@interface SoapInterface : NSObject

+ (SoapInterface *) sharedInstance;

// 푸쉬 토큰 등록 (푸쉬 수신 여부 리턴받음)
- (NSArray *)registPushToken:(NSDictionary *)registDic;

// 푸쉬 상태 전송
- (BOOL)setAllowPush:(NSDictionary *)pushDic;

// 앱 업데이트 정보 조회
- (NSArray *)getAppUpdateInfo:(NSDictionary *)updateDic;

// 메뉴 목록 조회
- (NSArray *)getMainMenuList:(NSDictionary *)empInfoDic;

// 롤링 공지사항 조회
- (NSArray *)getNoticeList;

// 뱃지 개수 조회
- (NSDictionary *)getBadgeCount:(NSDictionary *)empInfoDic;

// 접속 로그 전송
- (void)setLoggingInfo:(NSDictionary *)empInfoDic;

// 로그아웃시 다비아스 아이디 처리
- (BOOL)setLogoutPorg:(NSDictionary *)empInfoDic;

// OTP Show 여부
- (NSString *)getOTPisShow:(NSDictionary *)empInfoDic servicename:(NSString *)servicename;

// OTP save OTP information After OTP validation
- (BOOL)setOTPinformation:(NSDictionary *)empInfoDic;

- (NSString *)requestOTPSendSoapService:(NSString *)id;

- (BOOL)requestOTPValidateSoapService:(NSString *)id hp:(NSString *)hp otp:(NSString *)otp;

@end
