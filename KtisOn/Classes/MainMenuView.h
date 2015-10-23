//
//  MainMenuView.h
//  KtisOn
//
//  Created by Hyuck on 3/15/14.
//
//

#import <UIKit/UIKit.h>

#define IsAtLeastiOSVersion(X) ([[[UIDevice currentDevice] systemVersion] compare:X options:NSNumericSearch] != NSOrderedAscending)

@protocol MainMenuDelegate <NSObject>
- (void)pressMainMenuBtn:(NSInteger)btnTag url:(NSURL *)pushUrl;
@end


@interface MainMenuView : UIView <UIScrollViewDelegate>

@property (nonatomic, strong) id <MainMenuDelegate> delegate;

- (void)setScrollMenu:(NSArray *)btnArr;
- (void)setMenuViewWithRotate:(BOOL)isLandscape;

- (void)setMenuBadgeWithData:(NSDictionary *)badgeDic;

@end
