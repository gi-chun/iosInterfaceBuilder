//
//  TokenStore.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 4. 24..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"
@interface OfflineAuthData :NSObject

-(void)setOfflineToken:(id)object;
-(id)getOfflineToken;

-(void)setLiveToken:(id)object;
-(id)getLiveToken;

-(void)setUserInfos:(NSDictionary *)dicObject;
-(NSDictionary *)getUserInfos;

-(void)setUserCredentialHash:(NSString *)sValue;
-(NSString *)getUserCredentialHash;

-(void)setTokenEncType:(enum EncType)value;
-(enum EncType)getTokenEncType;

-(void)setTokenEncKey:(NSString *)sValue;
-(NSString *)getTokenEncKey;

-(void)setCredHashType:(enum EncType)value;
-(enum EncType)getCredHashType;

-(Boolean)isSameOffLineUser:(NSString *)userID :(NSString *)pwd;

-(void)UpdateLiveToken;
@end


@interface TokenStore : NSObject

+(void)GetfmtToken;
+(void)GetfmtCryptInfo;

+(void)SaveResult:(id)authResult :(NSString *)userID :(NSString *)userPwd;
+(void)SaveResult:(id)updateTokenResult;

+(OfflineAuthData *)GetOfflineAuthData;
+(void)DeleteOfflineAuthData;
+(void)SaveOfflineAuthData:(OfflineAuthData *)authData;
@end
