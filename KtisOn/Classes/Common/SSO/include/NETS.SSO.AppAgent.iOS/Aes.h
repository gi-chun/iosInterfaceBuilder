//
//  Aes.h
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



//  AES 암호화/복호화 클래스 입니다.
@interface Aes : ICryptoBase
//  암/복호화 키 사이즈
enum KeySizeType
{
    //AES 128
    Aes128 = 0x10,
    
    //AES 192
    Aes192 = 0x18,
    
    //AES 256
    Aes256 = 0x20,

};
-(id)Aes:(enum KeySizeType)KeySize;


@end
