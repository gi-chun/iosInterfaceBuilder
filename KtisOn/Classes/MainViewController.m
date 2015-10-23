//
//  MainViewController.m
//  ktis Mobile
//
//  Created by Hyuck on 1/24/14.
//
//

#import "MainViewController.h"
#import "LegacyViewController.h"
#import "WebLinkViewController.h"
#import "SettingViewController.h"
#import "IndicatorView.h"
#import "KeychainItemWrapper.h"
#import "UpdateChecker.h"
#import "SecurityManager.h"
#import "SSOController.h"
#import "Defines.h"
#import "SettingManager.h"
#import "LoginViewController.h"
#import "SoapInterface.h"
#import "Defines.h"

@interface MainViewController ()
{
    UIImageView             *_bgShadowImgView1;
    UIImageView             *_bgShadowImgView2;
    UIImageView             *_titleImg;
    
    UIImageView             *_userIconImg;
    UILabel                 *_userNameLabel;
    UIButton                *_settingBtn;
    
    /* 앱 업데이트 */
    UpdateView              *_updateView;       // 앱 업데이트 뷰
    
    NSDictionary            *_plistMenuDic;
    
    /* 메인 메뉴 */
    MainMenuView            *_mainMenuView;
    NSMutableArray          *_mainMenuArr;
    
    /* 링크 메뉴, 공지사항 */
    LinkMenuView            *_linkMenuView;
    
    NSString                *_employeeNumb;     // 직원 번호 (데이터 리퀘스트 시 사용)
}
- (void)readyCurrentView;
- (void)setCurrentViewByOreint:(BOOL)isLandscape;

- (void)pressOption:(id)sender;
- (void)setUpdateView;
- (void)setLinkMenu;
@end

@implementation MainViewController

#pragma mark - View Life Cycle
- (id)init
{
    self = [super init];
    if (self) {
        _mainMenuArr = [NSMutableArray array];
        
        _mainMenuView = [[MainMenuView alloc] init];
        _mainMenuView.delegate = self;
        
        _linkMenuView = [[LinkMenuView alloc] init];
        _linkMenuView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#ifdef DEV_MODE
    UILabel *modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 40, 300, 50)];
    [modeLabel setText:[NSString stringWithFormat:@"DEV / %@",
                        [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"]]];
    [self.view addSubview:modeLabel];
#endif
    
    [self readyCurrentView];
    
    // 직원 번호 조회 (데이터 요청시 사용)
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc]  initWithIdentifier:@"UserAuth" accessGroup:nil];
    _employeeNumb = [NSString decodeString:[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)]];
    keychainWrapper = nil;
    
    
    // plist 목록
    NSString *filePath  = [[NSBundle mainBundle] pathForResource:MENU_PLIST ofType:@"plist"];
    _plistMenuDic       = [NSDictionary dictionaryWithContentsOfFile:filePath];
    
    
    // 메인 메뉴
    [self.view addSubview:_mainMenuView];
    
    // 링크 메뉴
    [self.view addSubview:_linkMenuView];
    [self setLinkMenu];
}

- (void)refreshMainMenu
{
    [self setMainMenu];
    
    // 뱃지 카운트 적용
    NSDictionary *badgeDic = [[SoapInterface sharedInstance] getBadgeCount:@{@"empNo": _employeeNumb}]; // 뱃지 개수 데이터
    [_mainMenuView setMenuBadgeWithData:badgeDic];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isLandscape = (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) ? YES:NO;
    [_mainMenuView setMenuViewWithRotate:isLandscape]; // 메인 메뉴 화면 구성
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // 인디케이터 시작
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    [[IndicatorView sharedInstance] setInitFrame:mainRect];
    [[IndicatorView sharedInstance] startIndicator];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isLandscape = (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) ? YES:NO;
    
    // 첫 진입시 레이아웃 구성
    [self setCurrentViewByOreint:isLandscape];
}

// 화면에 들어올 때 마다 데이터를 다시 불러와야 하는 구성요소들
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isLandscape = (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) ? YES:NO;
    
    // 진입시 레이아웃 구성
    [self setCurrentViewByOreint:isLandscape];
    
    // 업데이트 체크
    //[self setUpdateView];
    
    // 권한에 따른 메인 메뉴
    [self setMainMenu];
    
    // 공지사항
    NSArray *newsArr = [[SoapInterface sharedInstance] getNoticeList];  // 공지사항 데이터
    [_linkMenuView setBottomNews:newsArr];  // 공지사항 구성
    [_linkMenuView startNewsRolling];       // 롤링 시작
    
    // 뱃지 카운트 적용
    NSDictionary *badgeDic = [[SoapInterface sharedInstance] getBadgeCount:@{@"empNo": _employeeNumb}]; // 뱃지 개수 데이터
    [_mainMenuView setMenuBadgeWithData:badgeDic];
    
    [_mainMenuView setMenuViewWithRotate:isLandscape]; // 메인 메뉴 화면 구성
    
    [[IndicatorView sharedInstance] stopIndicator]; // 인디케이터 멈춤
    
    NSURL *pushUrl = [[NSUserDefaults standardUserDefaults] URLForKey:RECEIVED_PUSH_URL];
    
    if (![[NSString stringWithFormat:@"%@", pushUrl] isEqualToString:@""] && pushUrl)
        [self pressMainMenuBtn:0 url:pushUrl];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    // 뷰를 떠날 때 타이머를 멈춘다
    [_linkMenuView stopNewsRolling];
}

// 뷰 회전
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    // 뷰 회전시 업데이트 팝업 좌표 조정
    if (_updateView)
        [_updateView setUpdateViewPosition:self.view.frame];
    
    BOOL isLandscape = (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) ? YES:NO;
    
    // 회전에 따른 레이아웃 구성
    [self setCurrentViewByOreint:isLandscape];
}

// 현재뷰의 기본 화면 구성
- (void)readyCurrentView
{
    //SSO 상태 조회
    NSDictionary *ssoStatDic = [[SSOController sharedInstance] requestSSOStatus];
    if (!ssoStatDic) {
        // 인증정보가 없는 경우 로그인으로 이동
        for (id viewController in [[self navigationController] viewControllers]) {
            if ([viewController isKindOfClass:[LoginViewController class]])
                [self.navigationController popToViewController:viewController animated:YES];
        }
    }
    
    NSString *userName = (ssoStatDic) ? [ssoStatDic objectForKey:@"username"]:@"";
    
    // 백그라운 이미지
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_bg.png"]]];
    
    _bgShadowImgView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg1.png"]];
    [self.view addSubview:_bgShadowImgView1];
    
    _bgShadowImgView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]];
    [self.view addSubview:_bgShadowImgView2];
    
    // 타이틀 이미지
    _titleImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"title_main.png"]];
    [self.view addSubview:_titleImg];
    
    // 로고 이미지 (리프레시 버튼)
    UIImage *logoImg = [UIImage imageNamed:@"logo_main.png"];
    UIButton *logoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoBtn setBackgroundImage:logoImg forState:UIControlStateNormal];
    [logoBtn setFrame:CGRectMake(20, 26, logoImg.size.width, logoImg.size.height)];
    [logoBtn addTarget:self action:@selector(refreshMainMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logoBtn];
    
    // 설정 버튼
    UIImage *settingBtnImg = [UIImage imageNamed:@"btn_main_seting.png"];
    _settingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_settingBtn setTag:99];
    [_settingBtn setImage:settingBtnImg forState:UIControlStateNormal];
    [_settingBtn addTarget:self action:@selector(pressOption:) forControlEvents:UIControlEventTouchUpInside];
    [_settingBtn setFrame:CGRectMake(0, 0, settingBtnImg.size.width+20.0f, settingBtnImg.size.height+20.0f)];
    [self.view addSubview:_settingBtn];
    
    // 사용자명
    _userIconImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_main_login.png"]];
    [_userIconImg setFrame:CGRectMake(0, 0, _userIconImg.frame.size.width, _userIconImg.frame.size.height)];
    [self.view addSubview:_userIconImg];
    _userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 64.0f, _userIconImg.frame.size.height+6.0f)];
    [_userNameLabel setTextColor:[UIColor whiteColor]];
    [_userNameLabel setBackgroundColor:[UIColor clearColor]];
    [_userNameLabel setFont:[UIFont boldSystemFontOfSize:13.0f]];
    [_userNameLabel setText:[NSString stringWithFormat:@"%@ 님", userName]];
    [self.view addSubview:_userNameLabel];
}

// 화면 방향에 따라 화면 구성
- (void)setCurrentViewByOreint:(BOOL)isLandscape
{
    // 메인 메뉴 화면 구성
    [_mainMenuView setMenuViewWithRotate:isLandscape];
    
    // 링크 메뉴 화면 구성
    [_linkMenuView setLinkMenuViewWithRotate:isLandscape];
    
    CGFloat titleYPos = (isLandscape) ? 50:71;
    
    // 백그라운드 이미지
    [_bgShadowImgView1 setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [_bgShadowImgView2 setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    // 타이틀 이미지 위치
    [_titleImg setFrame:CGRectMake((self.view.frame.size.width-_titleImg.frame.size.width)/2, titleYPos,
                                   _titleImg.frame.size.width, _titleImg.frame.size.height)];
    
    // 설정 버튼 위치
    [_settingBtn setFrame:CGRectMake(self.view.frame.size.width - 60, 20, _settingBtn.frame.size.width, _settingBtn.frame.size.height)];
    
    // 사용자명
    [_userIconImg setFrame:CGRectMake(_settingBtn.frame.origin.x - 85, 33.0f, _userIconImg.frame.size.width, _userIconImg.frame.size.height)];
    [_userNameLabel setFrame:CGRectMake(_userIconImg.frame.origin.x+24.0f, 30.0f, 72.0f, _userIconImg.frame.size.height+6.0f)];
}


#pragma mark - 앱 업데이트
- (void)setUpdateView
{
    // 업데이트 필요 유무 체크
    UpdateChecker *updateChecker = [[UpdateChecker alloc] init];
    NSArray *updateInfoArr = [updateChecker getUpdateCheckResult];
    
    // 업데이트 내역이 있는지 확인 있으면 업데이트 뷰 노출
    // ** 업데이트 뷰 히든 설정
    if (updateChecker.needUpdate)
    {
        // 앱 업데이트 화면 구성
        _updateView = [[UpdateView alloc] initWithFrame:self.view.frame withData:updateInfoArr];
        [self.navigationController.view addSubview:_updateView];
        [self.navigationController setNavigationBarHidden:YES];
        
    }
}


#pragma mark - 메인메뉴
- (void)setMainMenu
{
    // 권한별 메뉴 목록 구성
    NSDictionary *requestDic = @{@"empNo"       : _employeeNumb,  //사번
                                 @"dvcId"       : [[SettingManager sharedInstance] getUUID],  //기기구분값
                                 @"packageName" : PACKAGE_NAME,  //패키지명
                                 @"platformCode": PLATFORM_CODE}; //플렛폼코드
    
    NSArray *receiveMenuArr = [[SoapInterface sharedInstance] getMainMenuList:requestDic];  // 서버에서 받아온 메뉴 목록
    NSArray *plistMenuArr  = [_plistMenuDic objectForKey:@"mainMenu"];  // menuList.plist의 메뉴 목록
    
    [_mainMenuArr removeAllObjects];
    for (id plistObj in plistMenuArr) {
        NSString *svcCode = [plistObj objectForKey:@"serviceCode"];
        for (id obj in receiveMenuArr) {
            if ([[obj objectForKey:@"serviceCode"] isEqualToString:svcCode])
                [_mainMenuArr addObject:plistObj];
        }
    }
    // ** 메뉴 강제 노출 (삭제할 것)
//    _mainMenuArr = [NSMutableArray arrayWithArray:plistMenuArr];
    [_mainMenuView setScrollMenu:_mainMenuArr];
}


// 메인 메뉴 클릭 델리게이트
- (void)pressMainMenuBtn:(NSInteger)btnTag url:(NSURL *)pushUrl
{
    // 푸쉬 수신시 메인으로 와서 레거시로 이동한다
    NSLog(@"[timestamp] 레거시 호출 버튼 누름 :%@", pushUrl);
    // btnTag, menuArr
    
    LegacyViewController *LegacyVC = [[LegacyViewController alloc] initWithNibName:NibName(@"LegacyViewController")bundle:nil menuSeq:btnTag menuArr:_mainMenuArr notice:nil pushUrl:pushUrl];
    [self.navigationController pushViewController:LegacyVC animated:YES];
}
- (void)pushReceiveAction:(NSURL *)url
{
    [self pressMainMenuBtn:9998 url:url];
}

#pragma mark - 링크 메뉴
- (void)setLinkMenu
{
    NSArray *linkMenu = [_plistMenuDic objectForKey:@"linkMenu"];
    [_linkMenuView setLinkMenu:linkMenu];
}

- (void)pressLinkMenuBtn:(NSInteger)btnTag
{
    NSDictionary *linkMenu  = [[_plistMenuDic objectForKey:@"linkMenu"] objectAtIndex:btnTag];
    
    NSString *linkUrl;
    if ([[linkMenu objectForKey:@"seq"] integerValue] == 1 || [[linkMenu objectForKey:@"seq"] integerValue] == 3)
        linkUrl = [NSString stringWithFormat:@"%@%@", [linkMenu objectForKey:@"link"], _employeeNumb];
    else
        linkUrl = [linkMenu objectForKey:@"link"];
    
    NSString *linkTitle = [linkMenu objectForKey:@"title"];
    
    WebLinkViewController *webLinkVC = [[WebLinkViewController alloc] initWithNibName:NibName(@"WebLinkViewController")
                                                                               bundle:nil withURL:linkUrl withTitle:linkTitle];
    [self.navigationController pushViewController:webLinkVC animated:YES];
}

#pragma mark - 공지사항 선택시 프로토콜 델리게이트 액션
- (void)pressBottomNews:(NSString *)noticeId
{
//    NSString *url = [NSString stringWithFormat:@"%@%@", NOTICE_URL, noticeId];
//    NSLog(@"[롤링공지]호출:%@", url);
    
    //url을 가지고 레거시로 간다
    LegacyViewController *LegacyVC = [[LegacyViewController alloc] initWithNibName:NibName(@"LegacyViewController")bundle:nil menuSeq:9999 menuArr:_mainMenuArr notice:noticeId pushUrl:[NSURL URLWithString:@""]];
    [self.navigationController pushViewController:LegacyVC animated:YES];
}

#pragma mark - 설정 버튼 액션
- (void)pressOption:(id)sender
{
    SettingViewController *settingVC = [[SettingViewController alloc] initWithNibName:NibName(@"SettingViewController") bundle:nil];
    [self.navigationController pushViewController:settingVC animated:YES];
}



#pragma mark - 코르도바 관련 Methods (기본값)
// 코르도바 쿠키 사용 설정
- (void)setCordovaUsingCookie
{
    NSHTTPCookieStorage* cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    int cacheSizeMemory = 8 * 1024 * 1024; // 8MB
    int cacheSizeDisk = 32 * 1024 * 1024; // 32MB
    NSURLCache* sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"nsurlcache"];
    [NSURLCache setSharedURLCache:sharedCache];
}

// this happens while we are running ( in the background, or from within our own app )
// only valid if ktis Mobile-Info.plist specifies a protocol to handle
- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url
{
    if (!url)
        return NO;
    
    // calls into javascript global function 'handleOpenURL'
    NSString* jsString = [NSString stringWithFormat:@"handleOpenURL(\"%@\");", url];
    [self.viewController.webView stringByEvaluatingJavaScriptFromString:jsString];
    
    // all plugins will get the notification, and their handlers will be called
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginHandleOpenURLNotification object:url]];
    
    return YES;
}

// repost the localnotification using the default NSNotificationCenter so multiple plugins may respond
- (void) application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
    // re-post ( broadcast )
    [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];
}

- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    // iPhone doesn't support upside down by default, while the iPad does.  Override to allow all orientations always, and let the root view controller decide what's allowed (the supported orientations mask gets intersected).
    NSUInteger supportedInterfaceOrientations =
    (1 << UIInterfaceOrientationPortrait)       | (1 << UIInterfaceOrientationLandscapeLeft) |
    (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationPortraitUpsideDown);
    
    return supportedInterfaceOrientations;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
