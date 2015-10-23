//
//  IndicatorView.m
//  KtisOn
//
//  Created by Hyuck on 3/9/14.
//
//

#import "IndicatorView.h"

@interface IndicatorView()
{
    UIActivityIndicatorView *_indicator;
    UIView                  *_blockView;
}

- (void)delIndicator;
@end

@implementation IndicatorView

static dispatch_once_t once;
static IndicatorView *_sharedInstance = nil;
+ (IndicatorView *) sharedInstance
{
    if (!_sharedInstance)
    {
        dispatch_once(&once, ^{
            _sharedInstance = [[IndicatorView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        });
    }
    return _sharedInstance;
}

+ (IndicatorView *) sharedInstance:(CGRect)frame
{
    dispatch_once(&once, ^{
        _sharedInstance = [[IndicatorView alloc] initWithFrame:frame];
    });
    return _sharedInstance;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _blockView = [[UIView alloc] initWithFrame:self.frame];
        
        UIImageView *_bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
        [_bgImgView setFrame:frame];
        [_blockView addSubview:_bgImgView];
        
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_indicator setFrame:CGRectMake(0, 0, 300, 300)];
        [_blockView addSubview:_indicator];
        [_indicator setCenter:self.center];
    }
    return self;
}

- (void)startIndicator
{
    if (![_indicator isAnimating]) {
        [[[UIApplication sharedApplication] keyWindow] addSubview:_blockView];
        [_indicator startAnimating];
    }
}

- (void)stopIndicator
{
    if ([_indicator isAnimating]) {
        [_indicator stopAnimating];
        [_blockView removeFromSuperview];
    }
}

- (void)delIndicator
{
    if ([_indicator isAnimating]) {
        [_indicator stopAnimating];
        [_blockView removeFromSuperview];
    }
}

- (void)setInitFrame:(CGRect)frame
{
    [self stopIndicator];
    
    _blockView = [[UIView alloc] initWithFrame:frame];
    
    UIImageView *_bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
    [_bgImgView setFrame:frame];
    [_blockView addSubview:_bgImgView];
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [_indicator setFrame:CGRectMake(0, 0, 300, 300)];
    [_blockView addSubview:_indicator];
    [_indicator setCenter:_blockView.center];
    
}

@end
