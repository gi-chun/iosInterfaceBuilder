//
//  GlobalMenuTableViewCell.h
//  KtisOn
//
//  Created by Hyuck on 3/28/14.
//
//

#import <UIKit/UIKit.h>

@interface GlobalMenuTableViewCell : UITableViewCell

@property (nonatomic, strong) UIImage   *menuIconImage;
@property (nonatomic, strong) UIImage   *menuTitleImage;

- (void)setCellView;

@end
