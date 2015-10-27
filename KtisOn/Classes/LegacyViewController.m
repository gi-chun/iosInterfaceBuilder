//
//  LegacyViewController.m
//  ktis Mobile
//
//  Created by Hyuck on 1/24/14.
//
//

#import "LegacyViewController.h"
#import "SettingViewController.h"
#import "Defines.h"
#import "IndicatorView.h"
#import "LoginViewController.h"
#import "GlobalMenuTableViewCell.h"
#import "SoapInterface.h"
#import "SSOController.h"
#import "SettingManager.h"
#import "Defines.h"

@interface LegacyViewController ()
{
    NSInteger               _menuSeq;
    NSString                *_noticeNo;
    NSURL                   *_pushUrl;
    
    IBOutlet UIView         *_globalMenuView;
    IBOutlet UITableView    *_globalMenuTable;
    NSArray                 *_globalMenuArr;
    IBOutlet UIButton       *_globalMenuCloseBtn;
    
    BOOL                    _isIndicatorRun;
    
    NSMutableData           *_receiveData;
    NSString                *_fileExtansion;
    
    NSTimer                 *_timeoutTimer;
    
    NSString                *_backUrl;
    
    BOOL                    _isMailDes;
}
- (void)goHome;
- (void)goLogin;
@end

@implementation NSURLRequest (LegacyViewController)
+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}
@end

@implementation LegacyViewController

#pragma mark - View Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menuSeq:(NSInteger)menuSeq menuArr:(NSArray *)menuArr notice:(NSString *)noticeNo pushUrl:(NSURL *)pushUrl
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _menuSeq = menuSeq;
        _noticeNo = noticeNo;
        _globalMenuArr = menuArr;
        _pushUrl = pushUrl;
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)closeGlobalMenu:(id)sender
{
    [self toggleGlobalMenu];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.webView setBackgroundColor:[UIColor whiteColor]];
    [_globalMenuTable setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_navi_list.png"]]];
    
    _isIndicatorRun = NO;   // indicator flag
    
    [self loadLegacyWebView];
    
#ifdef DEV_MODE
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goHome)];
    [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:swipe];
#endif
}

- (void)loadLegacyWebView
{
    NSDictionary *ssoStatDic = [[SSOController sharedInstance] requestSSOStatus];
    // 인증정보가 없는 경우 로그인으로 이동
    
    if (!ssoStatDic){
        [self sessionClose];
    }
    
    NSLog(@"ssoStatDic :%@", [NSString stringWithFormat:@"my dictionary is %@", ssoStatDic]);
    
    // 로깅
    NSString *credentialUrl;
    
    if (!_pushUrl || [[NSString stringWithFormat:@"%@", _pushUrl] isEqualToString:@""]) {
        if (!_noticeNo) {   // 롤링 공지사항 선택은 로깅하지 않음
            
            // 백그라운드에서 로깅
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSString *serviceCode = [[_globalMenuArr objectAtIndex:_menuSeq] objectForKey:@"serviceCode"];
                NSDictionary *userInfoDic = @{@"logType"        : LOG_TYPE_SERVICE,  //접속 로그 타입 (LT01 : 접속 로그, LT02 : 서비스 접근 로그)
                                              @"code"           : serviceCode,  //서비스코드
                                              @"empNo"          : [ssoStatDic objectForKey:@"sabun"],  //사번
                                              @"dvcId"          : [[SettingManager sharedInstance] getUUID],  //기기구분값
                                              @"packageName"    : PACKAGE_NAME,  //패키지명
                                              @"platformCode"   : PLATFORM_CODE}; //플렛폼코드
                [[SoapInterface sharedInstance] setLoggingInfo:userInfoDic];
            });
            
            
            NSString *legacyUrl = [[_globalMenuArr objectAtIndex:_menuSeq] objectForKey:@"url"];
            credentialUrl = [[SSOController sharedInstance] requestCredentialUrl:[NSString stringWithFormat:@"%@", legacyUrl]];
        }
        else
        {
             NSLog(@"nomal URL and no sso login again");
            
            credentialUrl = [[SSOController sharedInstance] requestCredentialUrl:[NSString stringWithFormat:@"%@%@", NOTICE_URL, _noticeNo]];
        }
    }
    else
    {
        // _pushUrl
        [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:@""] forKey:RECEIVED_PUSH_URL];
        [[NSUserDefaults standardUserDefaults] synchronize];
        credentialUrl = [[SSOController sharedInstance] requestCredentialUrl:[NSString stringWithFormat:@"%@", _pushUrl]];
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:credentialUrl]];
    
    [self.webView loadRequest:request];
}

// 첨부파일 선택시 해당 파일을 다운받아 도큐먼트 인터렉션을 연다
- (void)openFile:(NSString *)fileUrl
{
    [[IndicatorView sharedInstance] startIndicator];

    // 다운로드할 파일의 확장자 지정
    _fileExtansion = [[fileUrl componentsSeparatedByString:@"."] lastObject];
    
    // 파일 다운로드 준비
    _receiveData = [NSMutableData data];
    self.interactionController.delegate = self;
    
    // 다운로드 준비
    NSString *url = [fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLConnection *downloadConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // 다운로드 시작
    [downloadConnection start];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    _globalMenuCloseBtn.hidden = YES;
    [_globalMenuView setFrame:CGRectMake(self.view.frame.size.width, 0, _globalMenuView.frame.size.width, _globalMenuView.frame.size.height)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    if (_timeoutTimer) {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}


#pragma mark - Custom Methods
- (void)toggleGlobalMenu
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         float menuWidth = _globalMenuView.frame.size.width;
                         if (_globalMenuCloseBtn.hidden) // open
                         {
                             [_globalMenuView setFrame:CGRectMake(self.view.frame.size.width-menuWidth, 0, _globalMenuView.frame.size.width, _globalMenuView.frame.size.height)];
                             _globalMenuCloseBtn.hidden = NO;
                         }
                         else    // close
                         {
                            [_globalMenuView setFrame:CGRectMake(self.view.frame.size.width, 0, _globalMenuView.frame.size.width, _globalMenuView.frame.size.height)];
                             _globalMenuCloseBtn.hidden = YES;
                         }
                     }
                     completion:^(BOOL finished){
                         // 바운스 에니메이션 막음
//                         CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.x"];
//                         animation.duration = 0.15;
//                         animation.fromValue = [NSNumber numberWithInt:0];
//                         animation.toValue = (_globalMenuCloseBtn.hidden)?[NSNumber numberWithInt:-20]:[NSNumber numberWithInt:20];
//                         animation.repeatCount = 1;
//                         animation.autoreverses = YES;
//                         animation.fillMode = kCAFillModeForwards;
//                         animation.removedOnCompletion = NO;
//                         animation.additive = YES;
//                         [_globalMenuView.layer addAnimation:animation forKey:@"bounceAnimation"];
                     }
     ];
}

- (void)indicator
{
    if (!_isIndicatorRun)
        [[IndicatorView sharedInstance] startIndicator];
    else
        [[IndicatorView sharedInstance] stopIndicator];

    _isIndicatorRun = !_isIndicatorRun;
}

- (void)sessionClose
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"인증이 만료되었습니다.\n로그인으로 이동합니다." delegate:self cancelButtonTitle:nil otherButtonTitles:@"done", nil];
    alert.tag = 1;
    [alert show];
    
    // 인증 만료시 로그인 페이지로 이동
    [self goLogin];
}

- (void)goHome
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)goLogin
{
    // 로그인 페이지로 이동
    for (id viewController in [[self navigationController] viewControllers]) {
        if ([viewController isKindOfClass:[LoginViewController class]])
            [self.navigationController popToViewController:viewController animated:YES];
    }
}

- (void)callPhone:(NSString *)phoneNumb
{
    NSString *pn = [NSString stringWithFormat:@"tel:%@", phoneNumb];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pn]];
}

- (void)sendSMS:(NSString *)phoneNumb
{
    NSString *pn = [NSString stringWithFormat:@"sms:%@", phoneNumb];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:pn]];
}

- (void)sendMail:(NSString *)mailAddress backUrl:(NSString *)backUrl
{
    _backUrl = backUrl;

    NSString *mailUrl = [NSString stringWithFormat:@"%@%@&fromhr=1", SEND_MAIL_URL, mailAddress];
    NSString *credentialUrl = [[SSOController sharedInstance] requestCredentialUrl:mailUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:credentialUrl]];
    [self.webView loadRequest:request];
}

- (void)backSendMail
{
    NSString *credentialUrl = [[SSOController sharedInstance] requestCredentialUrl:_backUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:credentialUrl]];
    [self.webView loadRequest:request];
}

- (void)insertContact:(NSString *)name contact:(NSString *)contact
{
#warning 연락처 추가
    NSLog(@"전달받은 연락처 :%@/%@", name, contact);
    
    CFErrorRef error = NULL;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(nil, &error);
    ABRecordRef record = ABPersonCreate();      // create an ABRecordRef
    ABMutableMultiValueRef multi = ABMultiValueCreateMutable(kABStringPropertyType);   // kABMultiStringPropertyType
    ABRecordSetValue(record, kABPersonLastNameProperty, (__bridge CFTypeRef)(name), &error);                    // add the last name
    ABMultiValueAddValueAndLabel(multi, (__bridge CFTypeRef)(contact), kABPersonPhoneMobileLabel, NULL);        // phone
    ABRecordSetValue(record, kABPersonPhoneProperty, multi, &error);                                            // add the phone number
    ABAddressBookAddRecord(addressBook, record, NULL);      // add the record
    ABAddressBookSave(addressBook, NULL);                   // save the addresss book
    CFRelease(addressBook);                                 // release
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"저장됨" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Done", nil];
    [alert show];
}

#pragma mark -  NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[IndicatorView sharedInstance] startIndicator];
    // 받은 데이터를 뮤터블 데이터에 추가
    [_receiveData appendData:data];
    
    NSLog(@"첨부파일 받는 중:%d", [_receiveData length]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [[IndicatorView sharedInstance] stopIndicator];
    
    // 파일쓰기
    NSError *error = nil;
    NSString *fileName  = [NSString stringWithFormat:@"ktisonDoc.%@", _fileExtansion];
    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    [_receiveData writeToFile:[NSString stringWithFormat:@"%@/%@", docsDir, fileName] options:NSDataWritingAtomic error:&error];
    
    if (!error) {
        // 다운로드 종료가 되면 도큐먼트 인터렉션을 열어야 한다
        
        NSString *path = [docsDir stringByAppendingPathComponent:fileName];
        NSLog(@"첨부파일 저장경로:%@", path);
        
        // 경로에 파일이 있는지 확인한 후 UIDocumentInteractionCOntroller로 파일을 연다
        if ([[NSFileManager defaultManager] fileExistsAtPath: path])
        {
            NSURL *fileUrl  = [NSURL fileURLWithPath:[docsDir stringByAppendingPathComponent:fileName]];
            if (fileUrl) {
                self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:fileUrl];
                CGRect docMenuRect = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/2, 0, 0);
                [self.interactionController presentOptionsMenuFromRect:docMenuRect inView:self.view animated:YES];
            }
        }
    } else {
        NSLog(@"첨부파일 저장실패 %@", error);
    }
    
    _receiveData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[IndicatorView sharedInstance] stopIndicator];
    NSLog(@"커넥션 에러: %@", [error localizedDescription]);
    
    [self networkTimeout];
}

# pragma mark - Web View Delegate Methods for Using Cordova

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    return [super webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
}

- (void) webViewDidStartLoad:(UIWebView*)theWebView
{
    //if(_isMailDes != true)
    [[IndicatorView sharedInstance] startIndicator];
    
    [_commandQueue resetRequestId];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CDVPluginResetNotification object:self.webView]];
    
    // ** 로딩 타임아웃
//    if(_isMailDes != true){
//        if (!_timeoutTimer)
//            _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(networkTimeout) userInfo:nil repeats:NO];
//    }else{
//        [self performSelector:@selector(forceIndicatorStop) withObject:nil afterDelay:1];
//    }
    
    if (!_timeoutTimer)
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(networkTimeout) userInfo:nil repeats:NO];
    
    NSLog(@"[timestamp] 레거시 로드 시작 / %@", [theWebView.request URL]);
    
    return [super webViewDidStartLoad:theWebView];
}

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{    
    NSLog(@"[웹뷰 로드 실패] %@", error);
    
    return [super webView:theWebView didFailLoadWithError:error];
}

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    NSLog(@"[timestamp] 레거시 로드 끝 / %@", [theWebView.request URL]);
    if (_timeoutTimer) {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    [[IndicatorView sharedInstance] stopIndicator];
    return [super webViewDidFinishLoad:theWebView];
}

- (void)forceIndicatorStop
{
    [[IndicatorView sharedInstance] stopIndicator];
}

- (void)networkTimeout
{
    if (_timeoutTimer) {
        [_timeoutTimer invalidate];
        _timeoutTimer = nil;
    }
    [self.webView stopLoading];
    [[IndicatorView sharedInstance] stopIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"네트워크 상태를 확인 해주세요." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
    alert.tag = 2;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1)
        [self goLogin];
    else
        [self goHome];
}


#pragma mark - Table View Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 홈과 설정 로우를 넣기위해 2행 추가
    return [_globalMenuArr count]+2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    GlobalMenuTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[GlobalMenuTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if (indexPath.row == 0) {
            // 홈
            cell.menuIconImage  = [UIImage imageNamed:@"icon_navi_home.png"];
            cell.menuTitleImage = [UIImage imageNamed:@"txt_navi_home.png"];
        } else if (indexPath.row == [_globalMenuArr count]+1) {
            // 설정
            cell.menuIconImage  = [UIImage imageNamed:@"icon_navi_setting.png"];
            cell.menuTitleImage = [UIImage imageNamed:@"txt_navi_setting.png"];
        }
        else {
            cell.menuIconImage  = [UIImage imageNamed:[[_globalMenuArr objectAtIndex:indexPath.row-1] objectForKey:@"thumbImg"]];
//                                   @"icon_navi_notice.png"];
            cell.menuTitleImage = [UIImage imageNamed:[[_globalMenuArr objectAtIndex:indexPath.row-1] objectForKey:@"titleImg"]];
//                                   @"txt_navi_hr.png"];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setCellView];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        // 홈
        [self goHome];
    } else if (indexPath.row == [_globalMenuArr count]+1) {
        // 설정
        SettingViewController *settingView = [[SettingViewController alloc] initWithNibName:NibName(@"SettingViewController") bundle:nil];
        [self.navigationController pushViewController:settingView animated:YES];
    }
    else
    {
        [self toggleGlobalMenu];
//        if (_menuSeq != indexPath.row-1) {    // 동일한 메뉴 선택시 리로드 하지 않음
            NSString *legacyUrl = [[_globalMenuArr objectAtIndex:indexPath.row-1] objectForKey:@"url"];
            NSString *credentialUrl = [[SSOController sharedInstance] requestCredentialUrl:legacyUrl];
            [self.webView loadRequest: [NSURLRequest requestWithURL:[NSURL URLWithString:credentialUrl]]];
            _menuSeq = indexPath.row-1;
//        }
    }
}

@end



@implementation MainCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
 in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

/*
 NOTE: this will only inspect execute calls coming explicitly from native plugins,
 not the commandQueue (from JavaScript). To see execute calls from JavaScript, see
 MainCommandQueue below
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

- (NSString*)pathForResource:(NSString*)resourcepath;
{
    return [super pathForResource:resourcepath];
}

@end

@implementation MainCommandQueue

/* To override, uncomment the line in the init function(s)
 in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
