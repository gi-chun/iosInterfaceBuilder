//
//  GlobalMenuTableViewCell.m
//  KtisOn
//
//  Created by Hyuck on 3/28/14.
//
//

#import "GlobalMenuTableViewCell.h"

@interface GlobalMenuTableViewCell()
{
    UIImageView *_bgImg;
    UIImageView *_borderImg;
}
@end

@implementation GlobalMenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // 셀 bg, 보더
        UIImage *bgImg      = [UIImage imageNamed:@"bg_navi_list.png"];
        UIImage *borderImg  = [UIImage imageNamed:@"line_navi.png"];
        _bgImg =     [[UIImageView alloc] initWithImage:bgImg];
        _borderImg = [[UIImageView alloc] initWithImage:borderImg];
        [_bgImg setFrame:CGRectMake(0, 0, bgImg.size.width, bgImg.size.height)];
        [_borderImg setFrame:CGRectMake(0, self.frame.size.height, borderImg.size.width, borderImg.size.height)];
        [self addSubview:_bgImg];
        [self addSubview:_borderImg];
    }
    return self;
}

- (void)setCellView
{
    // 아이콘, 타이틀
    UIImageView *menuIcon = [[UIImageView alloc] initWithImage:self.menuIconImage];
    UIImageView *titleImg = [[UIImageView alloc] initWithImage:self.menuTitleImage];
    [menuIcon setFrame:CGRectMake(10.0f, (self.frame.size.height-menuIcon.frame.size.height)/2,
                                  menuIcon.frame.size.width, menuIcon.frame.size.height)];
    [titleImg setFrame:CGRectMake(46.0f, (self.frame.size.height-titleImg.frame.size.height)/2,
                                  titleImg.frame.size.width, titleImg.frame.size.height)];
    [self addSubview:menuIcon];
    [self addSubview:titleImg];
}

@end
