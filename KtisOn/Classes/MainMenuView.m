//
//  MainMenuView.m
//  KtisOn
//
//  Created by Hyuck on 3/15/14.
//
//

#import "MainMenuView.h"

@interface MainMenuView()
{
    NSMutableArray  *_buttonArr;    // 버튼, 버튼 타이틀, 뱃지, 뱃지이미지 3개 등을 담는 어레이
    NSArray         *_btnDataArr;   // 버튼에 사용할 데이터를 담는 어레이

    UIScrollView    *_menuScroll;
    UIPageControl   *_pageControl;
    NSInteger       _totalPageCnt;
    NSInteger       _currentPage;
    
    UILabel         *_versionLabel;
}
- (NSArray *)getBtnLayoutArray:(BOOL)isLandscape;
@end

@implementation MainMenuView

#pragma mark - 초기화
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 스크롤뷰 init
        _menuScroll = [[UIScrollView alloc] init];  // 생성
        [_menuScroll setPagingEnabled:YES]; // 페이징함
        [_menuScroll setShowsHorizontalScrollIndicator:NO]; // 스크롤뷰 인디케이터 히든
        _menuScroll.delegate = self;        // 델리게이트 지정
        [self addSubview:_menuScroll];      // 뷰에 추가
        
        // 페이지 컨트롤 init
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        [self addSubview:_pageControl];
        
        // 메뉴 버튼 배열
        _buttonArr = [NSMutableArray array];
        
        _currentPage = 0;
    }
    return self;
}


#pragma mark - 메뉴 버튼의 위치 배열
- (NSArray *)getBtnLayoutArray:(BOOL)isLandscape
{
    NSArray *btnsPosArr = [NSArray array];
    
    CGFloat screenWidth  = 0.0f;
    CGFloat screenHeight = 0.0f;
    CGFloat screenHeightTemp = 0.0f;
    
    // iPhone
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        // 포트레이트
        if (!isLandscape)
        {
            screenWidth  = [[UIScreen mainScreen] bounds].size.width;
            screenHeight = [[UIScreen mainScreen] bounds].size.height;
            
            if ([[UIScreen mainScreen] bounds].size.height == 568)
            {
                // 4 inches
                btnsPosArr = @[@{@"posX": @39.0,  @"posY":@45.0}, //1행
                               @{@"posX": @124.0, @"posY":@45.0},
                               @{@"posX": @209.0, @"posY":@45.0},
                               @{@"posX": @39.0,  @"posY":@185.0}, //2행
                               @{@"posX": @124.0, @"posY":@185.0},
                               @{@"posX": @209.0, @"posY":@185.0}];
            }
            else
            {
                // 3.5 inches
                btnsPosArr = @[@{@"posX": @39.0,  @"posY":@20.0}, //1행
                               @{@"posX": @124.0, @"posY":@20.0},
                               @{@"posX": @209.0, @"posY":@20.0},
                               @{@"posX": @39.0,  @"posY":@133.0}, //2행
                               @{@"posX": @124.0, @"posY":@133.0},
                               @{@"posX": @209.0, @"posY":@133.0}];
            }
        }
        
        // 랜드스케이프
        else
        {
            screenWidth  = [[UIScreen mainScreen] bounds].size.height;
            screenHeight = [[UIScreen mainScreen] bounds].size.width;
            
            if (IsAtLeastiOSVersion(@"8.0")) {
               screenHeightTemp = screenHeight;
            }else{
               screenHeightTemp = [[UIScreen mainScreen] bounds].size.height;
            }
            
            if (screenHeightTemp >= 568)
            {
                // 4 inches
                btnsPosArr = @[@{@"posX": @25.0,   @"posY":@30.0}, //1행
                               @{@"posX": @114.0,   @"posY":@30.0},
                               @{@"posX": @203.0,  @"posY":@30.0},
                               @{@"posX": @292.0,  @"posY":@30.0},
                               @{@"posX": @381.0,  @"posY":@30.0},
                               @{@"posX": @470.0,  @"posY":@30.0}];
            }
            else
            {
                // 3.5 inches
                btnsPosArr = @[@{@"posX": @11.0,   @"posY":@30.0}, //1행
                               @{@"posX": @88.0,   @"posY":@30.0},
                               @{@"posX": @165.0,  @"posY":@30.0},
                               @{@"posX": @242.0,  @"posY":@30.0},
                               @{@"posX": @319.0,  @"posY":@30.0},
                               @{@"posX": @396.0,  @"posY":@30.0}];
            }
        }
    }
    // iPad
    else
    {
        // 포트레이트
        if (!isLandscape)
        {
            btnsPosArr = @[@{@"posX": @77.0,   @"posY":@181.0}, // 1행
                           @{@"posX": @311.0,   @"posY":@181.0},
                           @{@"posX": @545.0,  @"posY":@181.0},
                           
                           @{@"posX": @77.0,  @"posY":@477.0},  // 2행
                           @{@"posX": @311.0,  @"posY":@477.0},
                           @{@"posX": @545.0,  @"posY":@477.0}];
        }
        // 랜드스케이프
        else
        {
            btnsPosArr = @[@{@"posX": @195.0,  @"posY":@24.0}, // 1행
                           @{@"posX": @429.0,  @"posY":@24.0},
                           @{@"posX": @663.0,  @"posY":@24.0},
                           
                           @{@"posX": @195.0,  @"posY":@270.0},  // 2행
                           @{@"posX": @429.0,  @"posY":@270.0},
                           @{@"posX": @663.0,  @"posY":@270.0}];
        }
        
    }
    
    return btnsPosArr;
}


#pragma mark - 데이터로 메뉴 뷰 화면 구성
- (void)setScrollMenu:(NSArray *)btnArr
{
    if (!btnArr || [btnArr count] <1)
        return;
    
    NSArray *btnPositionArr = [self getBtnLayoutArray:NO];  // 버튼 위치 어레이
    
    [_menuScroll.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];  // 스크롤 위의 서브뷰들을 제거
    
    [_buttonArr removeAllObjects];  // 이전에 저장된 버튼들을 삭제
    
    _btnDataArr = btnArr;
    
    
    // 버튼을 생성하여 배열에 담고 스크롤뷰에 올린다
    for (int i = 0; i < [btnArr count]; i++)
    {
        // 버튼
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *btnImg;    // 버튼 이미지
        UIFont  *btnFont;   // 버튼 타이틀
        UIImage *badgeL;    // 뱃지 왼쪽 이미지
        UIImage *badgeR;    // 뱃지 오른쪽 이미지
        UIImage *badgeC;    // 뱃지 가운데 이미지
        UIFont  *badgeFont; // 뱃지 텍스트 폰트

        if ([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
            btnImg      = [UIImage imageNamed:[[btnArr objectAtIndex:i] objectForKey:@"img"]];
            btnFont     =[UIFont systemFontOfSize:16.0f];
            badgeL      = [UIImage imageNamed:@"ios_badge_left.png"];
            badgeR      = [UIImage imageNamed:@"ios_badge_right.png"];
            badgeC      = [UIImage imageNamed:@"ios_badge_center.png"];
            badgeFont   = [UIFont systemFontOfSize:12.0f];
        } else {
            btnImg      = [UIImage imageNamed:[[btnArr objectAtIndex:i] objectForKey:@"iPadImg"]];
            btnFont     = [UIFont systemFontOfSize:24.0f];
            badgeL      = [UIImage imageNamed:@"ios_ipad_badge_left.png"];
            badgeR      = [UIImage imageNamed:@"ios_ipad_badge_right.png"];
            badgeC      = [UIImage imageNamed:@"ios_ipad_badge_center.png"];
            badgeFont   = [UIFont systemFontOfSize:23.0f];
        }
        
        [btn setBackgroundImage:btnImg forState:UIControlStateNormal];
        [btn setFrame:CGRectMake(0, 0, btnImg.size.width, btnImg.size.height)];
        [btn addTarget:self action:@selector(pressScrollBtn:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTag:i];
        [_menuScroll addSubview:btn];
        
        // 버튼 타이틀
        UILabel *btnTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, btnImg.size.width, 20)];
        [btnTitleLabel setTextColor:[UIColor blackColor]];
        [btnTitleLabel setText:[[btnArr objectAtIndex:i] objectForKey:@"title"]];
        [btnTitleLabel setBackgroundColor:[UIColor clearColor]];
        [btnTitleLabel setTextAlignment:NSTextAlignmentCenter];
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad)
            [btnTitleLabel setFrame:CGRectMake(0, 0, btnImg.size.width, 40.0f)];
        
        [btnTitleLabel setFont:btnFont];
        [_menuScroll addSubview:btnTitleLabel];
        
        // 배지 이미지
        UIImageView *badgeLeftImg   = [[UIImageView alloc] initWithImage:badgeL];
        UIImageView *badgeRightImg  = [[UIImageView alloc] initWithImage:badgeR];
        UIImageView *badgeCenterImg = [[UIImageView alloc] initWithImage:badgeC];
        [badgeLeftImg   setFrame:CGRectMake(0, 0, badgeLeftImg.frame.size.width, badgeLeftImg.frame.size.height)];
        [badgeRightImg  setFrame:CGRectMake(0, 0, badgeRightImg.frame.size.width, badgeRightImg.frame.size.height)];
        [badgeCenterImg setFrame:CGRectMake(0, 0, badgeCenterImg.frame.size.width, badgeCenterImg.frame.size.height)];
        badgeLeftImg.hidden = YES;
        badgeRightImg.hidden = YES;
        badgeCenterImg.hidden = YES;
        
        // 배지 레이블
        UILabel *badgeLabel = [[UILabel alloc] init];
        [badgeLabel setTextAlignment:NSTextAlignmentCenter];
        [badgeLabel setFont:badgeFont];
        [badgeLabel setTextColor:[UIColor whiteColor]];
        [badgeLabel setBackgroundColor:[UIColor clearColor]];
        badgeLabel.hidden = YES;
        
        NSDictionary *dic = @{@"btn": btn, @"btnTitle": btnTitleLabel,  // 버튼
                              @"badgeLbl": badgeLabel, @"badgeL": badgeLeftImg, @"badgeR": badgeRightImg, @"badgeM": badgeCenterImg};   // 뱃지
        
        // 메뉴 버튼 배열에 추가
        [_buttonArr addObject:dic];
    }
    
    // 뱃지와 버튼의 겹침을 방지하기 위해 버튼이미지를 add 한 후 스크롤뷰에 붙인다
    for (int i = 0; i < [btnArr count]; i++) {
        [_menuScroll addSubview:[[_buttonArr objectAtIndex:i] objectForKey:@"badgeM"]];
        [_menuScroll addSubview:[[_buttonArr objectAtIndex:i] objectForKey:@"badgeR"]];
        [_menuScroll addSubview:[[_buttonArr objectAtIndex:i] objectForKey:@"badgeL"]];
        [_menuScroll addSubview:[[_buttonArr objectAtIndex:i] objectForKey:@"badgeLbl"]];
    }
    
    // 전체 페이지 수 지정
    _totalPageCnt  = (([btnArr count]-1)/[btnPositionArr count])+1;
}


#pragma mark - 회전 방향에 따라 메뉴 뷰 화면 구성
- (void)setMenuViewWithRotate:(BOOL)isLandscape
{
    NSInteger currPage = _currentPage;
    
    // 셀프뷰 프레임
    CGFloat menuViewPosY = 0.0f;
    CGFloat menuViewWidth = 0.0f;
    CGFloat menuViewHeight = 0.0f;
    
    CGFloat screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    // iPhone
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        if (IsAtLeastiOSVersion(@"8.0")) {
            // 포트레이트
            if (!isLandscape) {
                menuViewWidth   = screenWidth;
                menuViewHeight  = 250.0f;
                menuViewPosY    = 137.0f;
                
                // 4인치인 경우 메인 메뉴뷰의 크기를 늘린다
                if (screenHeight == 568.0f)
                    menuViewHeight  = menuViewHeight+75.0f;
            }
            
            // 랜드스케이프
            else {
                // iPhone4
                menuViewWidth   = screenWidth;
                menuViewHeight  = 140.0f;
                menuViewPosY    = 92.0f;
            }

        }else{
            // 포트레이트
            if (!isLandscape) {
                menuViewWidth   = [[UIScreen mainScreen]bounds].size.width;;
                menuViewHeight  = 250.0f;
                menuViewPosY    = 137.0f;
                
                // 4인치인 경우 메인 메뉴뷰의 크기를 늘린다
                if (screenHeight == 568.0f)
                    menuViewHeight  = [[UIScreen mainScreen]bounds].size.height+75.0f;
            }
            
            // 랜드스케이프
            else {
                // iPhone4
                menuViewWidth   = [[UIScreen mainScreen]bounds].size.width;
                menuViewHeight  = 140.0f;
                menuViewPosY    = 92.0f;
            }

            
        }
            }
    // iPad
    else
    {
        if (IsAtLeastiOSVersion(@"8.0")) {
            
            // 포트레이트
            if (!isLandscape) {
                menuViewWidth   = screenWidth;
                menuViewHeight  = screenHeight;
                menuViewPosY    = 100.0f;
            }
            // 랜드스케이프
            else {
                menuViewWidth   = screenWidth;
                menuViewHeight  = screenHeight-250.0f;
                menuViewPosY    = 137.0f;
            }

        }else{
            // 포트레이트
            if (!isLandscape) {
                menuViewWidth   = [[UIScreen mainScreen]bounds].size.width;
                menuViewHeight  = [[UIScreen mainScreen]bounds].size.height;
                menuViewPosY    = 100.0f;
            }
            // 랜드스케이프
            else {
                menuViewWidth   = [[UIScreen mainScreen]bounds].size.width;
                menuViewHeight  = [[UIScreen mainScreen]bounds].size.height-250.0f;
                menuViewPosY    = 137.0f;
            }

        }
        
    }
    
    
    [self setFrame:CGRectMake(0.0f, menuViewPosY, menuViewWidth, menuViewHeight)]; // 셀프뷰 프레임 조정
    
    // 스크롤뷰
    [_menuScroll setFrame:CGRectMake(0.0f, 0.0f, menuViewWidth, menuViewHeight)];                 // 메뉴 스크롤뷰 프레임 조정
    [_menuScroll setContentSize:CGSizeMake(menuViewWidth*_totalPageCnt, menuViewHeight)];   // 메뉴 스크롤뷰 컨텐츠 사이즈 조정
    [_menuScroll setContentOffset:CGPointMake(_menuScroll.frame.size.width*currPage, 0.0f)];   // 메뉴 스크롤의 페이지를 유지
    
    // 위치 재조정
    NSArray *posArr = [self getBtnLayoutArray:isLandscape];
    for (int i = 0; i < [_buttonArr count]; i++)
    {
        // 버튼
        UIButton *aBtn = [[_buttonArr objectAtIndex:i] objectForKey:@"btn"];
        CGFloat extendPosX = _menuScroll.frame.size.width * (i/[posArr count]);
        CGFloat posX = [[[posArr objectAtIndex:i%[posArr count]] objectForKey:@"posX"] floatValue] + extendPosX;
        CGFloat posY = [[[posArr objectAtIndex:i%[posArr count]] objectForKey:@"posY"] floatValue];
        [aBtn setFrame:CGRectMake(posX, posY, aBtn.frame.size.width, aBtn.frame.size.height)];
        
        // 버튼 타이틀
        UILabel *btnTitle = [[_buttonArr objectAtIndex:i] objectForKey:@"btnTitle"];
        [btnTitle setFrame:CGRectMake(posX, posY+aBtn.frame.size.height, aBtn.frame.size.width, btnTitle.frame.size.height)];
        
        // 뱃지 레이블 위치지정
        CGFloat bdgY = posY - 6.0f;
        UILabel *bdgLbl = [[_buttonArr objectAtIndex:i] objectForKey:@"badgeLbl"];
        [bdgLbl setFrame:CGRectMake(posX+aBtn.frame.size.width - bdgLbl.frame.size.width, bdgY, bdgLbl.frame.size.width, bdgLbl.frame.size.height)];
        
        // 뱃지 이미지
        UIImageView *bdgImgL = [[_buttonArr objectAtIndex:i] objectForKey:@"badgeL"];
        UIImageView *bdgImgM = [[_buttonArr objectAtIndex:i] objectForKey:@"badgeM"];
        UIImageView *bdgImgR = [[_buttonArr objectAtIndex:i] objectForKey:@"badgeR"];
        [bdgImgL setFrame:CGRectMake(bdgLbl.frame.origin.x-bdgImgL.frame.size.width+1.0f, bdgY, bdgImgL.frame.size.width, bdgImgL.frame.size.height)];
        [bdgImgM setFrame:CGRectMake(bdgLbl.frame.origin.x+1.0f, bdgY, bdgLbl.frame.size.width-2.0f, bdgImgM.frame.size.height)];
        [bdgImgR setFrame:CGRectMake(bdgLbl.frame.origin.x+bdgImgM.frame.size.width, bdgY, bdgImgR.frame.size.width, bdgImgR.frame.size.height)];
    }
    
    
    // 페이지 컨트롤 위치 조정 (스크롤뷰 아래에 위치함)
    [_pageControl setFrame:CGRectMake(0.0f, menuViewHeight-8.0f, menuViewWidth, 20.0f)];
    [_pageControl setNumberOfPages:_totalPageCnt];
    
    // 페이지가 하나뿐인경우 페이지 컨트롤 숨김
    _pageControl.hidden = (_totalPageCnt <= 1);
}


#pragma mark - 
#pragma mark 뱃지 관련 메소드
- (void)setMenuBadgeWithData:(NSDictionary *)badgeDic
{
    if ([badgeDic count] > 0 && badgeDic != nil)
    {
        // 뱃지 텍스트 지정
        for (int i = 0; i < [_buttonArr count]; i++) {
            NSString *badgeSeq = [[_btnDataArr objectAtIndex:i] objectForKey:@"badgeSeq"];
            NSInteger badgeCnt = [[badgeDic objectForKey:badgeSeq] intValue];
            if (badgeCnt > 0) {
                UILabel *badgeLbl = [[_buttonArr objectAtIndex:i] objectForKey:@"badgeLbl"];
                [badgeLbl setText:(badgeCnt > 99)? @"99+":[NSString stringWithFormat:@"%d", badgeCnt]];
                
                CGSize size = [badgeLbl.text sizeWithFont:badgeLbl.font constrainedToSize:CGSizeMake(60.0f, 18.0f)];
                
                [badgeLbl setFrame:CGRectMake(0, 0, size.width, size.height)];
                
                UIImageView *bdgImgL = [[_buttonArr objectAtIndex:i] objectForKey:@"badgeL"];
                UIImageView *bdgImgM = [[_buttonArr objectAtIndex:i] objectForKey:@"badgeM"];
                UIImageView *bdgImgR = [[_buttonArr objectAtIndex:i] objectForKey:@"badgeR"];
                
                // 뱃지 카운트가 0이면 뱃지 표시 않함
                BOOL isBadgeHidden = (badgeCnt <= 0) ? YES:NO;
                badgeLbl.hidden = isBadgeHidden;
                bdgImgL.hidden  = isBadgeHidden;
                bdgImgM.hidden  = isBadgeHidden;
                bdgImgR.hidden  = isBadgeHidden;
            }
        }
    }
}



#pragma mark - Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _currentPage = [[NSNumber numberWithFloat:scrollView.contentOffset.x/scrollView.frame.size.width] intValue];
    _pageControl.currentPage = _currentPage;
}


#pragma mark - Menu Button Click Action
- (void)pressScrollBtn:(id)btnTag
{
    [self.delegate pressMainMenuBtn:((UIButton *)btnTag).tag url:nil];
}

@end
