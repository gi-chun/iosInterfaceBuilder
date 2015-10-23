//
//  Sha.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 26..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import "ICryptoBase.h"


@interface Sha1 : ICryptoBase
-(id)Sha1;
@end

@interface Sha256 : ICryptoBase
-(id)Sha256;
@end

@interface Sha384 : ICryptoBase
-(id)Sha384;
@end

@interface Sha512 : ICryptoBase
-(id)Sha512;
@end
