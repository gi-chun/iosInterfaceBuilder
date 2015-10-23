//
//  IndicatorView.h
//  KtisOn
//
//  Created by Hyuck on 3/9/14.
//
//

#import <UIKit/UIKit.h>

@interface IndicatorView : UIView

- (void)startIndicator;
- (void)stopIndicator;
- (void)setInitFrame:(CGRect)frame;

+ (IndicatorView *) sharedInstance;
+ (IndicatorView *) sharedInstance:(CGRect)frame;

@end
