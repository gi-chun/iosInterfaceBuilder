//
//  TripleDES.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 25..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "ICryptoBase.h"
#import "CryptUtil.h"

@interface TripleDES : ICryptoBase

-(id)TripleDES;

@end
