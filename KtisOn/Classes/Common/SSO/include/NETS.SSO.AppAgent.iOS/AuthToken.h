//
//  AuthToken.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 4. 11..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"
#import "SSOCrypt.h"

@interface AuthToken : NSObject

-(NSString *)getUserID;
-(NSDate *)getLogonTime;
-(NSDate *)getAuthCheckTime;
-(void)Initialize:(NSString *)encryptedToken;
-(void)Initialize:(NSString *)encryptedToken :(enum EncType)encType :(NSString *)encKey;
-(NSString *)ToStringAuthToken;

-(Boolean)IsExpired:(NSInteger)limitedHour;
-(Boolean)IsTimeOut:(NSInteger)limitedMinue;
-(void)RefreshAuthCheckTime;

-(NSString *)getResultToken;

@end
