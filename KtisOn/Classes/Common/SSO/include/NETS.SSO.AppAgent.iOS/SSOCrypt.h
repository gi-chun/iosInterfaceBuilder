//
//  SSOCrypt.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 19..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"


enum EncType
{
    Invalid = 1000,
    DES = 1001,
    TDES = 1002,
    AES128 = 1003,
    AES192 = 1004,
    AES256 = 1005,
    //SEED128 = 1006,
    MD5 = 1007,
    SHA256 = 1008,
    SHA384 = 1009,
    SHA512 = 1010,
    SHA1 = 1011
};

@interface SSOCrypt : NSObject
+(SSOCrypt *)GetInstance;
-(NSString *)Encrypt:(enum EncType)type :(NSString *)sKey :(NSString *)sValue;
-(NSString *)Decrypt:(enum EncType)type :(NSString *)sKey :(NSString*)sValue;
-(NSString *)EncryptToken:(NSString *)sValue;
-(NSString *)DecryptToken:(NSString *)sValue;
-(NSString *)EncryptCookie:(NSString *)sValue;
-(NSString *)DecryptCookie:(NSString *)sValue;
-(NSString *)EncryptConfig:(NSString *)sValue;
-(NSString *)DecryptConfig:(NSString *)sValue;

@end
