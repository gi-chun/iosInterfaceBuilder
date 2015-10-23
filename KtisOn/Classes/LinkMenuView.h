//
//  LinkMenuView.h
//  KtisOn
//
//  Created by Hyuck on 3/19/14.
//
//

#import <UIKit/UIKit.h>

@protocol LinkMenuDelegate <NSObject>
- (void)pressLinkMenuBtn:(NSInteger)btnTag;
- (void)pressBottomNews:(NSString *)noticeId;
@end

@interface LinkMenuView : UIView

@property (nonatomic, strong) id <LinkMenuDelegate> delegate;

/* 링크메뉴 */
- (void)setLinkMenu:(NSArray *)btnArr;
- (void)setLinkMenuViewWithRotate:(BOOL)isLandscape;

/* 공지사항 */
- (void)setBottomNews:(NSArray *)newsArr;
- (void)startNewsRolling;
- (void)stopNewsRolling;

@end
