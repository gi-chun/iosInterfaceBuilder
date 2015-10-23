//
//  SSOUtility.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 18..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"
@interface SSOUtility : NSObject

-(void)setDeviceIP:(NSString *)sValue;
-(NSString *)getDeviceIP;

-(void)setMacaddr:(NSString *)sValue;
-(NSString *)getMacaddr;

+(Boolean)GetNetworkInformation;
+(void)SaveDataFile:(NSString *)filePath :(NSString *)fileName :(NSString *)textData;
+(NSString *)ReadDataFile:(NSString *)filePath :(NSString *)fileName;
+(void)DeleteDataFile:(NSString *)filePath :(NSString *)fileName;

@end
