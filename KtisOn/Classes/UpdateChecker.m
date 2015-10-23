//
//  UpdateChecker.m
//  KtisOn
//
//  Created by Hyuck on 3/6/14.
//
//

#import "UpdateChecker.h"
#import "SoapInterface.h"
#import "Defines.h"

@implementation UpdateChecker

@synthesize needUpdate;

- (NSArray *)getUpdateCheckResult
{
    self.needUpdate = NO;
    
    NSString *currentAppVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSDictionary *updateRequestDic = @{@"appVersion": currentAppVersion,
                                       @"packageName": PACKAGE_NAME,
                                       @"platformCode": PLATFORM_CODE};
    
    NSArray *resultArr = [[SoapInterface sharedInstance] getAppUpdateInfo:updateRequestDic];
    
    if([resultArr count] != 0){
        for (id obj in resultArr)
        {
            if ([[obj objectForKey:@"deployYn"] isEqualToString:@"Y"]) {
                NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
                NSLog(@"현재버전:%@/최신버전:%@", appVersion, [obj objectForKey:@"appVer"]);
                if (![appVersion isEqualToString:[obj objectForKey:@"appVer"]])
                    self.needUpdate = YES;
            }
        }
    }
    
    return resultArr;
}

@end
