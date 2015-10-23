//
//  AutoResult.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 15..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"
#import "AuthToken.h"

@interface AuthResult : NSObject<NSXMLParserDelegate>

-(void)setAppError:(enum AppErrorCode)eValue;
-(enum AppErrorCode)getAppError;

-(void)setServerError:(enum ServerErrorCode)eValue;
-(enum ServerErrorCode)getServerError;

-(void)setIsAuthenticated:(Boolean)bValue;
-(Boolean)getIsAuthenticated;

-(Boolean)getIsSuccess;

-(void)setConfigRevision:(NSString *)sValue;
-(NSString *)getConfigRevision;

-(id)AuthResult:(enum AppErrorCode)appError :(enum ServerErrorCode)serverError :(Boolean)isAuth;
-(id)AuthResult;

-(void)Initialize:(NSXMLParser *)rootDoc;

-(NSString *)ToString;
@end


@interface AuthSuccessResult : AuthResult<NSXMLParserDelegate>
-(void)setToken:(id)value;
-(id)getToken;

-(void)setUserInfos:(NSMutableDictionary *)Value;  //내부에서는 private 로 값을 초기화 하지만 추후 다른곳에서 호출시 접근하기위해서 public 메서드를 구현했는데 value 값이 객체가아니라 기본자료형 값이 올수도있으니 그때 바꾼다
-(NSMutableDictionary *)getUserInfos;
-(NSString *)getUserInfos:(NSString *)key;
-(id)AuthSuccessResult;
@end



@interface AuthSuccessResultWithPwdExpired : AuthSuccessResult<NSXMLParserDelegate>

-(id)AuthSuccessResultWithPwdExpired;
-(NSDate *)getPwdExpiredDate;
-(NSInteger)getRemainDay;
@end



//.NET 에서는  AuthSuccessResultWithDuplicatedLogon 의 내부클래스로 정의 한 클래스임
@interface AccessAppWithDuplicatedLogon : NSObject

-(void)setAppID:(NSString*)sValue;
-(NSString *)getAppID;

-(void)setAccessTime:(NSDate *)value;
-(NSDate *)getAccessTime;

-(void)setAppName:(NSString *)sValue;
-(NSString *)getAppName;
@end



@interface AuthSuccessResultWithDuplicatedLogon : AuthSuccessResult<NSXMLParserDelegate>
//get만 구현하고 값 대입시에는 변수에 직접대입함 (실제 .NET 코드임)
-(NSString *)getAnotherIP;
-(NSString *)getAnotherDeviceID;
-(NSDate *)getAnotherLogonTime;
-(NSDate *)getAnotherLastCheckTime;
-(NSArray *)getAccessAppList;

-(id)AuthSuccessResultWithDuplicatedLogon;
@end



@interface AuthFailResult : AuthResult<NSXMLParserDelegate>
-(id)AuthFailResult;
-(id)AuthFailResult:(enum AppErrorCode)appError;
@end



@interface AuthFailResultWithUserLocked : AuthFailResult<NSXMLParserDelegate>

-(void)setIsAutoRelease:(Boolean)bValue;
-(Boolean)getIsAutoRelease;

-(void)setAutoReleaseTime:(NSDate *)value;
-(NSDate *)getAutoReleaseTime;

-(id)AuthFailResultWithUserLocked;
@end

@interface AuthFailResultWithPwdExpired : AuthFailResult<NSXMLParserDelegate>

-(void)setPwdExpiredDate:(NSDate *)value;
-(NSDate *)getPwdExpiredDate;

-(id)AuthFailResultWithPwdExpired;
@end



//.Net 에서는 AuthFailResultWithDuplicatedLogon 의 내부 클래스로 정의 되어 있음
@interface AccessAppWithDuplicatedLogonFail : NSObject

-(void)setAppID:(NSString *)sValue;
-(NSString *)getAppID;

-(void)setAccessTime:(NSDate *)Value;
-(NSDate *)getAccessTime;

-(void)setAppName:(NSString *)sValue;
-(NSString *)getAppName;
@end

@interface AuthFailResultWithDuplicatedLogon : AuthFailResult<NSXMLParserDelegate>
-(NSString *)getAnotherIP;
-(NSString *)getAnotherDeviceID;
-(NSDate *)getAnotherLogonTime;
-(NSDate *)getAnotherLastCheckTime;
-(NSArray *)getAccessAppList;

-(id)AuthFailResultWithDuplicatedLogon;
@end









