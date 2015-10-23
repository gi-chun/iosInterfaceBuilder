//
//  LinkMenuView.m
//  KtisOn
//
//  Created by Hyuck on 3/19/14.
//
//

#import "LinkMenuView.h"

static CGFloat kLinkMenuBtnWidth    = 91.0f;
static CGFloat kLinkMenuBtnHeight   = 48.0f;

@interface LinkMenuView()
{
    /* 링크 메뉴 */
    UIScrollView    *_linkMenuScroll;   // 링크 메뉴 스크롤 뷰
    UIImageView     *_gradationLeft;    // 스크롤뷰 좌우 그라데이션 이미지 (좌)
    UIImageView     *_gradationRight;   // 스크롤뷰 좌우 그라데이션 이미지 (우)
    
    /* 공지사항 */
    UIView          *_newsView;         // 공지사항 뷰
    UILabel         *_newsLabel;        // 공지사항 레이블
    NSArray         *_newsArr;          // 공지사항 배열
    NSTimer         *_newsTimer;        // 공지사항 롤링타이머
    NSInteger       _newsSeq;           // 공지사항 롤링을 돌리기 위한 공지사항 번호
    CATransition    * transition;       // 롤링 에니메이션
}
- (void)setNewsRolling;
- (void)pressNews;
@end

@implementation LinkMenuView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // 링크 메뉴
        _linkMenuScroll = [[UIScrollView alloc] init];
        [_linkMenuScroll setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_main_link.png"]]];
        [_linkMenuScroll setShowsHorizontalScrollIndicator:NO]; // 스크롤뷰 인디케이터 히든
        [self addSubview:_linkMenuScroll];
        
        // 공지사항 뷰
        _newsView = [[UIView alloc] init];
        [_newsView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_notice_bar.png"]]];
        [_newsView setClipsToBounds:YES];   //에니메이션 처리 시 뷰 영역을 넘어가는것을 방지
        [self addSubview:_newsView];
        
        // 공지사항 레이블
        _newsLabel = [[UILabel alloc] init];
        [_newsLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [_newsLabel setTextColor:[UIColor whiteColor]];
        [_newsLabel setBackgroundColor:[UIColor clearColor]];
        [_newsView addSubview:_newsLabel];
        
        _newsSeq = 0;   // 공지사항 롤링 시퀀스
        
        // 공지사항 롤링 에니메이션
        transition = [CATransition animation];
        [transition setDuration:0.7];
        [transition setType:kCATransitionPush];
        [transition setSubtype:kCATransitionFromTop];
        [transition setFillMode:kCAFillModeBoth];
        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    return self;
}


#pragma mark - 링크 메뉴 데이터 설정 (viewDidLoad에서 호출)
- (void)setLinkMenu:(NSArray *)btnArr
{
    for (int i = 0; i < [btnArr count]; i++)
    {
        // 링크 메뉴 버튼 생성
        NSString *fileName = [[btnArr objectAtIndex:i] objectForKey:@"img"];
        UIImage *btnImg = [UIImage imageNamed:fileName];
        UIButton *linkBtn = [UIButton buttonWithType:UIButtonTypeCustom];   // 버튼 생성
        [linkBtn setImage:btnImg forState:UIControlStateNormal];    // 버튼 이미지 설정
        [linkBtn setFrame:CGRectMake(kLinkMenuBtnWidth * i, 0, kLinkMenuBtnWidth, kLinkMenuBtnHeight)]; // 버튼 크기 지정 (버튼뷰와 같은 크기)
        [linkBtn addTarget:self action:@selector(pressLinkBtn:) forControlEvents:UIControlEventTouchUpInside];  // 액션 지정
        [linkBtn setTag:i]; // 버튼의 테그 지정
        [_linkMenuScroll addSubview:linkBtn];   // 버튼 부착
        
        // 버튼간 경계 이미지 뷰에 부착
        if (i < [btnArr count] && i > 0)
        {
            UIImageView *btnBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_main_link.png"]];
            [btnBorder setFrame:CGRectMake(linkBtn.frame.size.width*i, 3, btnBorder.frame.size.width, btnBorder.frame.size.height)];
            [_linkMenuScroll addSubview:btnBorder];
        }
    }
    
    // 스크롤뷰 컨텐츠 크기 지정
    [_linkMenuScroll setContentSize:CGSizeMake(kLinkMenuBtnWidth*[btnArr count], kLinkMenuBtnHeight)];
    
    // 좌우 그라데이션 이미지 부착
    _gradationLeft = [[UIImageView alloc]  initWithImage:[UIImage imageNamed:@"fade_left.png"]];
    _gradationRight = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fade_right.png"]];
    [self addSubview:_gradationLeft];
    [self addSubview:_gradationRight];
}


#pragma mark - 링크 메뉴 뷰 설정 (viewDidLoad, 화면 회전 시 호출)
- (void)setLinkMenuViewWithRotate:(BOOL)isLandscape
{
    CGFloat scrollMenuPosY;
    CGFloat scrollWidth;
    
    CGFloat screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if (!isLandscape) {
        scrollWidth = screenWidth;
        scrollMenuPosY = screenHeight-77;
    }
    else{
        scrollWidth = screenWidth;
        scrollMenuPosY = screenHeight-77.0f;
    }
    
    // 링크 메뉴 뷰의 위치 및 크기 지정
    [self setFrame:CGRectMake(0, scrollMenuPosY, scrollWidth, kLinkMenuBtnHeight+29)];
    
    // 스크롤뷰 크기 지정
    [_linkMenuScroll setFrame:CGRectMake(0, 0, self.frame.size.width, kLinkMenuBtnHeight)];
    
    // 스크롤뷰 좌우 그라데이션 이미지 위치 지정
    [_gradationLeft setFrame:CGRectMake(0, 0, _gradationLeft.frame.size.width, _gradationLeft.frame.size.height)];
    [_gradationRight setFrame:CGRectMake(self.frame.size.width-_gradationRight.frame.size.width, 0,
                                         _gradationRight.frame.size.width, _gradationRight.frame.size.height)];
    
    // 공지사항 뷰
    [_newsView setFrame:CGRectMake(0, _linkMenuScroll.frame.origin.y+_linkMenuScroll.frame.size.height, self.frame.size.width, 29)];
    [_newsLabel setFrame:CGRectMake(15, 0, self.frame.size.width-30, 29)];
}


#pragma mark - 링크 메뉴 버튼 클릭
- (void)pressLinkBtn:(UIButton *)sender
{
    NSInteger btnTag = ((UIButton *) sender).tag;
    [self.delegate pressLinkMenuBtn:btnTag];
}


#pragma mark -
#pragma mark - 공지사항 롤링 (뷰에 들어올때마다 매번 다시 데이터 요청)
- (void)setBottomNews:(NSArray *)newsArr    // 공지사항 준비
{
    _newsArr = [NSArray arrayWithArray:newsArr];
 
    if (!_newsArr || [_newsArr count] < 1) {
        [_newsLabel setText:@"공지사항이 없습니다."];
        return;
    }
    
    NSDictionary *currDic = [newsArr objectAtIndex:_newsSeq%[_newsArr count]];
    [_newsLabel setText:[NSString stringWithFormat:@"%@", [currDic objectForKey:@"title"]]];
    
    // 공지사항 터치 이벤트
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pressNews)];
    [_newsView addGestureRecognizer:tap];
}

- (void)startNewsRolling    // 타이머 시작
{
    // 공지사항 롤링 타이머
    if (_newsTimer) {
        [_newsTimer invalidate];
        _newsTimer = nil;
    }
    
    _newsTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(setNewsRolling) userInfo:nil repeats:YES];
}

- (void)stopNewsRolling     // 타이머 중지
{
    if (_newsTimer) {
        [_newsTimer invalidate];
        _newsTimer = nil;
    }
}

- (void)setNewsRolling      // 공지사항 메세지 세팅
{
    if (_newsArr && [_newsArr count] > 1) {
        _newsSeq++;
        
        NSDictionary *currDic = [_newsArr objectAtIndex:_newsSeq%[_newsArr count]];
        
        [_newsLabel.layer addAnimation:transition forKey:kCATransition];
        
        [_newsLabel setText:[NSString stringWithFormat:@"%@", [currDic objectForKey:@"title"]]];
    }
}

- (void)pressNews
{
    if (_newsArr || [_newsArr count] > 0) {
        NSString *currNotiNo = [[_newsArr objectAtIndex:_newsSeq%[_newsArr count]] objectForKey:@"notiId"];
        [self.delegate pressBottomNews:currNotiNo];
    }
}

@end
