//
//  SSOController.h
//  SSOTest
//
//  Created by Hyuck on 3/10/14.
//  Copyright (c) 2014 hyuck. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"

@interface SSOController : NSObject

@property (nonatomic, strong) AuthCheck *authCheck;

+ (SSOController *) sharedInstance;

- (NSInteger)requestLogon:(NSDictionary *)loginInfoDic;
- (BOOL)requestLogoff;
- (NSDictionary *)requestSSOStatus;
- (NSString *)requestCredentialUrl:(NSString *)targetUrl;
- (BOOL)checkSSOFromForeground;

@end
