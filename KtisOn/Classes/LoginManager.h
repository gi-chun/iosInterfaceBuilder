//
//  LoginManager.h
//  KtisOn
//
//  Created by Hyuck on 2/25/14.
//
//

#import <Foundation/Foundation.h>

@protocol LoginProtocolDelegate <NSObject>
- (void)startedLogin;
- (void)endedLogin:(NSInteger)loginResult;
@end


@interface LoginManager : NSObject

@property (nonatomic, strong) id<LoginProtocolDelegate> delegate;

- (BOOL)getSSOStatusValid;

- (void)saveLoginInfoToKeychain:(NSDictionary *)loginDic;   // 핀코드 로그인을 위한 계정정보 저장
- (NSDictionary *)getLoginInfoFromKeychain;                 // 핀코드 로그인시 사용할 계정정보 호출

- (void)removeLoginInfo;    // 로그아웃시 계정정보 제거
- (void)requestLogin:(NSDictionary *)loginDic withPinCode:(BOOL)isPinLogin;
@end
