//
//  SettingManager.h
//  ktis Mobile
//
//  Created by Hyuck on 2/1/14.
//
//

#import <Foundation/Foundation.h>

@interface SettingManager : NSObject

+ (SettingManager *) sharedInstance;

- (NSDictionary *)getSSOStatus;

- (BOOL)requestSSOLogout;

/* otp receive mobile number */
- (void)setOtpMobileNumber:(NSString *)otpMobileNumber;
- (NSString *)getOtpMobileNumber;

/* UUID */
- (void)setUUID;
- (NSString *)getUUID;

/* Device Token */
- (void)setDeviceToken:(NSString *)deviceToken;
- (NSString *)getDeviceToken;

/* id save */
- (void)saveIdSave:(BOOL)idSave;
-(BOOL)getIdSave;
- (void)saveIdValue:(NSString *)idValue;
-(NSString *)getIdValue;

/* otp fail count */
- (void)saveFailCount:(NSInteger)idSave;
-(NSInteger)getFaileCount;

/* Pin Code */

// 핀코드 설정 여부
- (BOOL)isPinCodeValid;

// 핀코드 설정
- (void)savePinCode:(NSString *)pinCode;

// 핀코드 삭제
- (void)initPinCode;

// 핀코드 동일 여부
- (BOOL)isMatchedPinCode:(NSString *)pinCode;

/* 푸쉬 수신 여부 설정 */
- (void)setPushStatus:(NSArray *)pushArr;
- (NSDictionary *)getPushStatus;
- (BOOL)isValidPushSwitch;
- (BOOL)allowPush:(NSInteger)pushType isValid:(BOOL)isValid;

/* 하드웨어 종류 구분 값 */
- (NSString *) getHarwarePlatform;
@end

