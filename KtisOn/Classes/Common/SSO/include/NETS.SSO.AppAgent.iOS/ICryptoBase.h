//
//  ICryptoBase.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 21..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>


//abstract class iOS 에서는 명시적으로  abstract 를 선언할 키워드가 없다 또한 다른 abstract class 와는 다르게 인스턴스화도 할수있다
@interface ICryptoBase : NSObject

//abstract method
-(NSString *)Decrypt:(NSString *)sInput;
-(NSString *)Decrypt:(NSString *)sKey :(NSString *)sValue;
-(NSString *)Encrypt:(NSString *)sInput;
-(NSString *)Encrypt:(NSString *)sKey :(NSString *)sValue;
-(NSString *)GetKey;
-(void)SetKey:(NSString *)key;



@end
