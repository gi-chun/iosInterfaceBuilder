//
//  ErrorMessage.h
//  NETS.SSO.AppAgent.iOS.Simulator
//
//  Created by 김상용 on 13. 5. 7..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "App_configAppDelegate.h"
#import "SSOController.h"
@interface ErrorMessage : NSObject

+(NSString *)GetAppErrorMessage:(enum AppErrorCode)errCode;
+(NSString *)GetServerErrorMessage:(enum ServerErrorCode)errCode;
@end
