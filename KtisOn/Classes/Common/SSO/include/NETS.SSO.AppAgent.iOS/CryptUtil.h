//
//  CryptUtil.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 26..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"
@interface CryptUtil : NSObject
-(id)CryptUtil;

////iOS 버전에서 추가한 메서드
//// 문자열 값으로 보여지는 iOS < > 헥사값을 순수 문자열로 바꿈
//-(NSString *)GetStringFromHex:(NSData *)dHex;
//// 순수 문자열로 보여지는 헥사값을  iOS < > 형태의 헥사값으로 바꿈
//-(NSData *)GetHexFromString:(NSString *)sHex;
//// Encrypt 에서 패딩규칙을 추가한 byte 값 반환. plan Test -> byte data
//-(NSData *)GetByteFromString:(NSString *)sOrg;

@end
