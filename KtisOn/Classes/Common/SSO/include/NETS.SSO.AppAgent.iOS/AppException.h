//
//  AppException.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 20..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"

@interface AppException : NSException


-(enum AppErrorCode)getAppError;
-(enum ServerErrorCode)getServerError;
-(id)AppException:(enum AppErrorCode)errCode;
-(id)AppException:(enum AppErrorCode)errCode :(enum ServerErrorCode)serverError;
-(NSString *)Message;


@end
