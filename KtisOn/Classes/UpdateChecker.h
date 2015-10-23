//
//  UpdateChecker.h
//  KtisOn
//
//  Created by Hyuck on 3/6/14.
//
//

#import <Foundation/Foundation.h>

@interface UpdateChecker : NSObject

@property (nonatomic) BOOL needUpdate;

- (NSArray *)getUpdateCheckResult;
@end
