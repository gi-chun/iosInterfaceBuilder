//
//  Md5.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 26..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "ICryptoBase.h"


@interface Md5 : ICryptoBase

-(id)Md5;
@end
