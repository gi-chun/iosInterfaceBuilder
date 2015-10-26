//
//  LoginViewController.m
//  ktis Mobile
//
//  Created by Hyuck on 1/27/14.
//
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "IndicatorView.h"
#import "KeychainItemWrapper.h"
#import "SecurityManager.h"
#import "SoapInterface.h"
#import "UpdateChecker.h"


typedef enum {
    LoginState_LOGIN,
    LoginState_REGIST_PIN_CODE,
    LoginState_PIN_CODE_LOGIN,
    LoginState_OTP_LOGIN
}LoginState;

@interface LoginViewController ()
{
    IBOutlet UIScrollView   *_scrollView;
    NSDictionary            *_loginInfoDic;
    NSInteger               _progressFlag;
    LoginManager            *_loginManager;
    
    IBOutlet UILabel        *_titleLabel;
    IBOutlet UITextField    *_inputText1;
    IBOutlet UITextField    *_inputText2;
    IBOutlet UIButton       *_nextBtn;
    
    // 정보이용약관동의
    IBOutlet UIView         *_policyView;
    BOOL                    _agreeFlag;
    IBOutlet UIButton       *_agreeOff;
    
    IBOutlet UIButton *_otpSendButton;
    IBOutlet UIView *_idInputView;
    IBOutlet UILabel *otpTimeOut;
    
    IBOutlet UIView *KeyboardView;
    IBOutlet UIButton *keyPadBtn;
    BOOL               keyPadViewFlag;
    
    IBOutlet UIView *headerView;
    
    IBOutlet UILabel *idSaveLabel;
    IBOutlet UIButton *idSaveBtnOff;
    IBOutlet UIButton *idSaveBtnOn;
    BOOL                    _idSaveFlag;
    
    IBOutlet UIButton *arrowUp;
    IBOutlet UIButton *arrowDown;
    IBOutlet UITextView *_otpDesc;
    
    NSInteger               _pinCodeFailtCount;
    
    NSTimer         *_otpTimer;
    NSInteger               _otpInputMinute;
    NSInteger               _otpInputSecond;
    NSString *_employeeNumber;
    NSString *_otpNumber;
    NSString *_mobileNumber;
    NSInteger               _otpFailCount;
    
    UpdateView              *_updateView;       // 앱 업데이트 뷰
}

- (void)readyStandardLogin:(BOOL)paramKeyPadViewFlag orientFlag:(NSInteger)orientFlag;
- (void)readyRegistOTP:(NSInteger)orientFlag;
- (void)readyRegistPinCode;
- (void)readyPinCodeLogin;
- (IBAction)pressNextBtn:(id)sender;
- (void)standardLogin;
- (void)registPinCode;
- (void)pinCodeLogin;

- (void)showAlertWithMessage:(NSString *)message;

- (NSInteger)setUpdateView;
@end


@implementation LoginViewController


#pragma mark - ID save
- (IBAction)idSaveOffBtnClick:(id)sender {
    
    _idSaveFlag = (_idSaveFlag == false)?TRUE:false;
    
    if(_idSaveFlag){
        idSaveBtnOn.hidden = false;
        idSaveBtnOff.hidden = true;
        [[SettingManager sharedInstance] saveIdSave:true];
    }else{
        idSaveBtnOn.hidden = true;
        idSaveBtnOff.hidden = false;
        [[SettingManager sharedInstance] saveIdSave:false];
    }
}

- (IBAction)keyPadBtnClick:(id)sender {
    keyPadViewFlag = (keyPadViewFlag == false)?TRUE:false;
    [self readyStandardLogin:keyPadViewFlag orientFlag:1];
}

#pragma mark - OTP
double timerInterval = 1.0f;

- (void)startOtpTimer    // 타이머 시작
{
    if (_otpTimer) {
        [_otpTimer invalidate];
        _otpTimer = nil;
    }
    
    //scheduledTimerWithTimeInterval:3
    //timerWithTimeInterval:timerInterval
    _otpTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTick) userInfo:nil repeats:YES];
}

- (void)stopOtpTimer     // 타이머 중지
{
    if (_otpTimer) {
        [_otpTimer invalidate];
        _otpTimer = nil;
    }
}

-(void)onTick
{
    NSLog(@"Tick...");

    if(_otpInputSecond == 0 && _otpInputMinute > 0){
        _otpInputSecond = 59;
        _otpInputMinute--;
        
    }else if(_otpInputSecond > 0){
        _otpInputSecond--;
        if(_otpInputSecond == 0 && _otpInputMinute == 0){
            NSLog(@"OTP input time 3minute Time Out !");
            
            //@"OTP 보안 인증"
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"입력시간이 초과하였습니다." delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alert show];
            
            [_nextBtn setEnabled:false];
            [_inputText2 setEnabled:false];
            [_otpSendButton setEnabled:true];
        }
    }
    
    NSString *strValue = [NSString stringWithFormat:@"입력시간 %02d:%02d", _otpInputMinute, _otpInputSecond];
    
    //draw value
    [otpTimeOut setText:strValue];

}

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _loginManager = [[LoginManager alloc] init];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"wood_bg.png"]]];
    
    _agreeFlag = YES;   // 정보이용약관 동의 여부
    _pinCodeFailtCount = 0;
    
    keyPadViewFlag = false;
    _idSaveFlag = false;
    
    _inputText1.delegate = self;
    _inputText2.delegate = self;
    
    //otp
    _otpInputMinute = 3;
    _otpInputSecond = 0;
    _otpFailCount = 0;
    
    // 가상 키보드를 닫기 위한 제스쳐
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToResignKeyboard)];
    [self.view addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [_loginManager setDelegate:self];
    
    [_loginManager removeLoginInfo];    // 키체인에 저장된 id, pw를 삭제
    [self readyStandardLogin:keyPadViewFlag orientFlag:0];                          // SSO 로그인으로 화면 표시
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_scrollView setContentSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    // 뷰를 떠날 때 타이머를 멈춘다
    [self stopOtpTimer];
}

// 뷰 회전
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    BOOL isLandscape = (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
                        toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) ? YES:NO;
    
    CGFloat screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    if (!isLandscape) {
        [_scrollView setContentSize:CGSizeMake(screenWidth, screenHeight)];
    }
    else{
        [_scrollView setContentSize:CGSizeMake(screenHeight, screenWidth)];
    }
    
    
    
    // 뷰 회전시 업데이트 팝업 좌표 조정
    if (_updateView)
        [_updateView setUpdateViewPosition:self.view.frame];
    
    // 회전에 따른 레이아웃 구성
    [self setCurrentViewByOreint:isLandscape];
}


// 화면 방향에 따라 화면 구성
- (void)setCurrentViewByOreint:(BOOL)isLandscape
{
    if (_progressFlag == LoginState_LOGIN){
        [self readyStandardLogin:keyPadViewFlag orientFlag:1];
    }else if(_progressFlag == LoginState_OTP_LOGIN){
        [self readyRegistOTP:1];
    }
}

#pragma mark - Functions
- (void)tapToResignKeyboard
{
    [_inputText1 resignFirstResponder];
    [_inputText2 resignFirstResponder];
}


#pragma mark - Ready Login Views
// 일반 로그인 뷰
- (void)readyStandardLogin:(BOOL)paramKeyPadViewFlag orientFlag:(NSInteger)orientFlag
{
    _titleLabel.text = @"로그인";   // 팝업 타이틀
    
    _policyView.hidden = NO;        // 약관 보임
    _inputText2.hidden = NO;        // 텍스트 필드 2 보임
    otpTimeOut.hidden = YES;
    _otpSendButton.hidden = YES;
    idSaveLabel.hidden = NO;
    headerView.hidden = NO;
    _otpDesc.hidden = YES;
    
    [_inputText1 setEnabled:true];
    [_inputText2 setEnabled:true];
    [_nextBtn setEnabled:true];
    
    KeyboardView.hidden = !paramKeyPadViewFlag;
    
    _progressFlag = LoginState_LOGIN;    // 상태 시퀀스 (로그인)
    
    if( [[SettingManager sharedInstance] getIdSave]){
        _idSaveFlag = true;
        idSaveBtnOn.hidden = NO;
        idSaveBtnOff.hidden = YES;
        NSString * strTemp = [[SettingManager sharedInstance] getIdValue];
        NSUInteger length = [strTemp length];
        if(length > 0)
            [_inputText1 setText:strTemp];
    }else{
        _idSaveFlag = false;
        idSaveBtnOn.hidden = YES;
        idSaveBtnOff.hidden = NO;
        if(!orientFlag)
            [_inputText1 setText:@""];   // 텍스트 필드 1 공백
    }
    
    if(!orientFlag)
        [_inputText2 setText:@""];   // 텍스트 필드 2 공백
    
    NSDictionary *placeholderColor = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    NSAttributedString *idPlaceholderText = [[NSAttributedString alloc] initWithString:@"USER ID (사번)" attributes:placeholderColor];
    NSAttributedString *pwPlaceholderText = [[NSAttributedString alloc] initWithString:@"PASSWORD" attributes:placeholderColor];
    _inputText1.attributedPlaceholder = idPlaceholderText;
    _inputText2.attributedPlaceholder = pwPlaceholderText;
    
    [_inputText1 setSecureTextEntry:NO];
    [_inputText2 setSecureTextEntry:YES];
    [_inputText1 setKeyboardType:UIKeyboardTypeNumberPad];
    [_inputText2 setKeyboardType:UIKeyboardTypeDefault];
    
    [_nextBtn setTitle:@"" forState:UIControlStateNormal];
    [_nextBtn setTitle:@"" forState:UIControlStateHighlighted];
    
    // iPad 좌표 지정
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        //_idInputView.frame.size.height
        if(paramKeyPadViewFlag){ // show key pad
            [_idInputView setFrame:CGRectMake(_idInputView.frame.origin.x, CGRectGetMaxY(KeyboardView.frame),
                                              _idInputView.frame.size.width, 111.0f)];
            arrowUp.hidden = NO;
            arrowDown.hidden = YES;
            [keyPadBtn setTitle:@"키보드 닫기" forState:UIControlStateNormal];
            
        }else{ // hide key pad
            [_idInputView setFrame:CGRectMake(_idInputView.frame.origin.x, CGRectGetMaxY(headerView.frame),
                                              _idInputView.frame.size.width, 111.0f)];
            arrowUp.hidden = YES;
            arrowDown.hidden = NO;
            [keyPadBtn setTitle:@"키보드 열기" forState:UIControlStateNormal];
        }
        
        [_inputText2 setFrame:CGRectMake(_inputText2.frame.origin.x, _inputText2.frame.origin.y,
                                         _inputText1.frame.size.width, _inputText1.frame.size.height)];
        
        [_policyView setFrame:CGRectMake(_idInputView.frame.origin.x, CGRectGetMaxY(_idInputView.frame),
                                         _policyView.frame.size.width, _policyView.frame.size.height)];
        
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_login_iPad.png"] forState:UIControlStateNormal];
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_select_iPad.png"] forState:UIControlStateHighlighted];
        [_nextBtn setFrame:CGRectMake((self.view.frame.size.width-_nextBtn.frame.size.width)/2.0f, CGRectGetMaxY(_policyView.frame) - _nextBtn.frame.size.height - 10,
                                      _nextBtn.frame.size.width, _nextBtn.frame.size.height)];
        
    }
    
    // iPhone 좌표 지정
    else
    {
        if(paramKeyPadViewFlag){ // show key pad
            [_idInputView setFrame:CGRectMake(_idInputView.frame.origin.x, CGRectGetMaxY(KeyboardView.frame),
                                              _idInputView.frame.size.width, 109.0f)];
            arrowUp.hidden = NO;
            arrowDown.hidden = YES;
            [keyPadBtn setTitle:@"키보드 닫기" forState:UIControlStateNormal];
            
        }else{ // hide key pad
            //CGRectGetMaxY(headerView.frame)
            //84.0f + 29.0f
            [_idInputView setFrame:CGRectMake(_idInputView.frame.origin.x, CGRectGetMaxY(headerView.frame),
                                              _idInputView.frame.size.width, 109.0f)];
            arrowUp.hidden = YES;
            arrowDown.hidden = NO;
            [keyPadBtn setTitle:@"키보드 열기" forState:UIControlStateNormal];
        }
        
        [_inputText2 setFrame:CGRectMake(_inputText2.frame.origin.x, _inputText2.frame.origin.y,
                                         _inputText1.frame.size.width, _inputText1.frame.size.height)];
        
        [_policyView setFrame:CGRectMake(_idInputView.frame.origin.x, CGRectGetMaxY(_idInputView.frame),
                                         _policyView.frame.size.width, _policyView.frame.size.height)];
        
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_login_iPad.png"] forState:UIControlStateNormal];
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_select_iPad.png"] forState:UIControlStateHighlighted];
        [_nextBtn setFrame:CGRectMake((self.view.frame.size.width-_nextBtn.frame.size.width)/2.0f, CGRectGetMaxY(_policyView.frame) - _nextBtn.frame.size.height - 10,
                                      _nextBtn.frame.size.width, _nextBtn.frame.size.height)];
        
    }
}

// 핀코드 등록 뷰
- (void)readyRegistPinCode
{
    _titleLabel.text = @"PIN 저장";  // 팝업 타이틀
    
    _policyView.hidden = YES;       // 약관 감춤
    _inputText2.hidden = NO;        // 텍스트 필드 2 보임
    
    _progressFlag = LoginState_REGIST_PIN_CODE; // 상태 시퀀스 (핀코드 등록)
    
    [_inputText1 setText:@""];  // 텍스트 필드 1 공백
    [_inputText2 setText:@""];  // 텍스트 필드 2 공백
    [_inputText1 setFrame:CGRectMake((self.view.frame.size.width-_inputText1.frame.size.width)/2, 92.0f, _inputText1.frame.size.width, _inputText1.frame.size.height)];
    
    NSDictionary *placeholderColor = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    NSAttributedString *idPlaceholderText = [[NSAttributedString alloc] initWithString:@"PIN 번호" attributes:placeholderColor];
    NSAttributedString *pwPlaceholderText = [[NSAttributedString alloc] initWithString:@"재입력" attributes:placeholderColor];
    _inputText1.attributedPlaceholder = idPlaceholderText;
    _inputText2.attributedPlaceholder = pwPlaceholderText;
    
    [_inputText1 setSecureTextEntry:YES];
    [_inputText2 setSecureTextEntry:YES];
    [_inputText1 setKeyboardType:UIKeyboardTypeNumberPad];
    [_inputText2 setKeyboardType:UIKeyboardTypeNumberPad];
    [_inputText1 becomeFirstResponder]; // 키보드 보임
    
    // iPad 좌표 지정
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [_inputText1 setFrame:CGRectMake((self.view.frame.size.width-_inputText1.frame.size.width)/2, 102.0f, 512.0f, 30.0f)];
        
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_save_iPad.png"] forState:UIControlStateNormal];
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_save_select_iPad.png"] forState:UIControlStateHighlighted];
        [_nextBtn setFrame:CGRectMake((self.view.frame.size.width-_nextBtn.frame.size.width)/2, 182.0f,
                                      _nextBtn.frame.size.width, _nextBtn.frame.size.height)];
    }
    // iPhone 좌표 지정
    else
    {
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_save.png"] forState:UIControlStateNormal];
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_save_select.png"] forState:UIControlStateHighlighted];
        [_nextBtn setFrame:CGRectMake((self.view.frame.size.width-_nextBtn.frame.size.width)/2, 168.0f,
                                      _nextBtn.frame.size.width, _nextBtn.frame.size.height)];
    }
}

// 핀코드 로그인 뷰
- (void)readyPinCodeLogin
{
    _titleLabel.text = @"PIN 입력";  // 팝업 타이틀
    
    _policyView.hidden = YES;       // 약관 감춤
    _inputText2.hidden = YES;       // 텍스트 필드 2 감춤
    headerView.hidden = YES;
    KeyboardView.hidden = YES;
    
    _progressFlag = LoginState_PIN_CODE_LOGIN;  // 상태 시퀀스 (핀코드 로그인)
    
    [_inputText1 setText:@""];  // 텍스트 필드 1 공백
    
    NSDictionary *placeholderColor = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    NSAttributedString *idPlaceholderText = [[NSAttributedString alloc] initWithString:@"PIN 번호" attributes:placeholderColor];
    _inputText1.attributedPlaceholder = idPlaceholderText;
    
    [_inputText1 setSecureTextEntry:YES];
    [_inputText1 setKeyboardType:UIKeyboardTypeNumberPad];
    [_inputText1 becomeFirstResponder]; // 키보드 보임
    [_inputText1 setFrame:CGRectMake((self.view.frame.size.width-_inputText1.frame.size.width)/2, 117.0f, _inputText1.frame.size.width, _inputText1.frame.size.height)];
    
    // iPad 좌표 지정
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_login_iPad.png"] forState:UIControlStateNormal];
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_select_iPad.png"] forState:UIControlStateHighlighted];
        [_nextBtn setFrame:CGRectMake((self.view.frame.size.width-_nextBtn.frame.size.width)/2.0f, CGRectGetMaxY(_idInputView.frame) - _nextBtn.frame.size.height - 10,
                                      _nextBtn.frame.size.width, _nextBtn.frame.size.height)];

    }
    // iPhone 좌표 지정
    else
    {
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_login.png"] forState:UIControlStateNormal];
        [_nextBtn setImage:[UIImage imageNamed:@"btn_login_select.png"] forState:UIControlStateHighlighted];
        [_nextBtn setFrame:CGRectMake((self.view.frame.size.width-_nextBtn.frame.size.width)/2, 168.0f,
                                      _nextBtn.frame.size.width, _nextBtn.frame.size.height)];
    }
}


#pragma mark - OTP
// 핀코드 등록 뷰
- (void)readyRegistOTP:(NSInteger)orientFlag
{
    _titleLabel.text = @"OTP 보안 인증";      // 팝업 타이틀
    
    _policyView.hidden = YES;       // 약관 감춤
    _inputText2.hidden = NO;        // 텍스트 필드 2 보임
    otpTimeOut.hidden = NO;
    headerView.hidden = YES;
    KeyboardView.hidden = YES;
    idSaveBtnOn.hidden = YES;
    idSaveBtnOff.hidden = YES;
    idSaveLabel.hidden = YES;
    _otpSendButton.hidden = NO;
    _otpDesc.hidden = NO;
    
    _progressFlag = LoginState_OTP_LOGIN; // 상태 시퀀스 (핀코드 등록)
    
    if(!orientFlag){
        [_inputText1 setText:@""];  // 텍스트 필드 1 공백
        [_inputText2 setText:@""];  // 텍스트 필드 2 공백
        
        _otpInputMinute = 3;
        _otpInputSecond = 0;
        NSString *strValue = [NSString stringWithFormat:@"입력시간 %02d:%02d", _otpInputMinute, _otpInputSecond];
        [otpTimeOut setText:strValue];
        [self stopOtpTimer];
        
        [_inputText2 setEnabled:FALSE];
        [_nextBtn setEnabled:FALSE];
        [_otpSendButton setEnabled:true];
    }

    [_inputText1 setEnabled:FALSE];
    
    //CGFloat screenWidth  = [[UIScreen mainScreen] bounds].size.width;
    
//    [_inputText1 setFrame:CGRectMake((screenWidth-_inputText1.frame.size.width)/2, 92.0f, _inputText1.frame.size.width, _inputText1.frame.size.height)];
    
    // 사번
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc]  initWithIdentifier:@"UserAuth" accessGroup:nil];
    NSString *employeeNumb = [NSString decodeString:[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)]];
    
    NSDictionary *placeholderColor = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    NSAttributedString *idPlaceholderText = [[NSAttributedString alloc] initWithString:employeeNumb attributes:placeholderColor];
    NSAttributedString *pwPlaceholderText = [[NSAttributedString alloc] initWithString:@"인증코드" attributes:placeholderColor];
    _inputText1.attributedPlaceholder = idPlaceholderText;
    _inputText2.attributedPlaceholder = pwPlaceholderText;
    
    [_inputText1 setSecureTextEntry:NO];
    [_inputText2 setSecureTextEntry:NO];
    [_inputText1 setKeyboardType:UIKeyboardTypeNumberPad];
    [_inputText2 setKeyboardType:UIKeyboardTypeNumberPad];
    [_inputText2 becomeFirstResponder]; // 키보드 보임
    
    // iPad 좌표 지정
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        [_inputText2 setFrame:CGRectMake(_inputText2.frame.origin.x, _inputText2.frame.origin.y,
                                         _inputText1.frame.size.width - _otpSendButton.frame.size.width -10 , _inputText1.frame.size.height)];
        
        [_idInputView setFrame:CGRectMake(_idInputView.frame.origin.x, CGRectGetMaxY(_titleLabel.frame),
                                      _idInputView.frame.size.width, 405+20)];
        
        [_nextBtn setImage:nil forState:UIControlStateNormal];
        [_nextBtn setImage:nil  forState:UIControlStateHighlighted];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_save_iPad_new.png"] forState:UIControlStateNormal];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_save_select_iPad_new.png"] forState:UIControlStateHighlighted];
        [[_nextBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:35]];
        [_nextBtn setTitleColor:[UIColor colorWithRed:(0) green:(0) blue:(0) alpha:0.6 ]  forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor colorWithRed:(255) green:(255) blue:(255) alpha:0.6 ]  forState:UIControlStateHighlighted];
        
        [_nextBtn setTitle:@"인증 요청" forState:UIControlStateNormal];
        [_nextBtn setTitle:@"인증 요청" forState:UIControlStateHighlighted];
        
        [_nextBtn setFrame:CGRectMake((self.view.frame.size.width-_nextBtn.frame.size.width)/2.0f, CGRectGetMaxY(_idInputView.frame)-_nextBtn.frame.size.height-20,
                                      _nextBtn.frame.size.width, _nextBtn.frame.size.height)];
    }
    // iPhone 좌표 지정
    else
    {
        [_inputText2 setFrame:CGRectMake(_inputText2.frame.origin.x, _inputText2.frame.origin.y,
                                         _inputText1.frame.size.width - _otpSendButton.frame.size.width -10 , _inputText1.frame.size.height)];
        
        [_idInputView setFrame:CGRectMake(_idInputView.frame.origin.x, CGRectGetMaxY(_titleLabel.frame),
                                          _idInputView.frame.size.width, 318.0f+10.0f)];
        
        [_nextBtn setImage:nil forState:UIControlStateNormal];
        [_nextBtn setImage:nil  forState:UIControlStateHighlighted];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_save_iPad_new.png"] forState:UIControlStateNormal];
        [_nextBtn setBackgroundImage:[UIImage imageNamed:@"btn_login_save_select_iPad_new.png"] forState:UIControlStateHighlighted];
        [[_nextBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:18]];
        [_nextBtn setTitleColor:[UIColor colorWithRed:(0) green:(0) blue:(0) alpha:0.6 ]  forState:UIControlStateNormal];
        [_nextBtn setTitleColor:[UIColor colorWithRed:(255) green:(255) blue:(255) alpha:0.6 ]  forState:UIControlStateHighlighted];
        
        [_nextBtn setTitle:@"인증 요청" forState:UIControlStateNormal];
        [_nextBtn setTitle:@"인증 요청" forState:UIControlStateHighlighted];
        
        [_nextBtn setFrame:CGRectMake((self.view.frame.size.width-_nextBtn.frame.size.width)/2.0f, CGRectGetMaxY(_idInputView.frame)-_nextBtn.frame.size.height-20,
                                      _nextBtn.frame.size.width, _nextBtn.frame.size.height)];
    }
}


#pragma mark - 앱 업데이트
- (NSInteger)setUpdateView
{
    NSInteger returnValue = 0;
    
    // 업데이트 필요 유무 체크
    UpdateChecker *updateChecker = [[UpdateChecker alloc] init];
    NSArray *updateInfoArr = [updateChecker getUpdateCheckResult];
    
    // 업데이트 내역이 있는지 확인 있으면 업데이트 뷰 노출
    // ** 업데이트 뷰 히든 설정
    if (updateChecker.needUpdate)
    {
        returnValue = 1;
        // 앱 업데이트 화면 구성
        _updateView = [[UpdateView alloc] initWithFrame:self.view.frame withData:updateInfoArr];
        [self.navigationController.view addSubview:_updateView];
        
    }
    
    return returnValue;
}

#pragma mark - Login Actions
- (IBAction)pressNextBtn:(id)sender
{
    if (_progressFlag == LoginState_LOGIN)
        (_agreeFlag)? [self standardLogin]:[self showAlertWithMessage:TERMS_AGREE];
    else if (_progressFlag == LoginState_REGIST_PIN_CODE)
        [self registPinCode];
    else if (_progressFlag == LoginState_PIN_CODE_LOGIN)
        [self pinCodeLogin];
    else if (_progressFlag == LoginState_OTP_LOGIN)
        [self otpCodeLogin];
}

// 정보이용약관 동의 버튼
- (IBAction)pressAgree:(id)sender
{
    NSInteger tag = ((UIButton *) sender).tag;
    if (tag == 0) {
        _agreeOff.hidden = YES;
        _agreeFlag = NO;
    } else {
        _agreeOff.hidden = NO;
        _agreeFlag = YES;
    }
}

// 일반 로그인
- (void)standardLogin
{
    NSLog(@"[timestamp] 일반 로그인 시작");
    BOOL isValidLogin = [[NSUserDefaults standardUserDefaults] boolForKey:@"blockLoginFailed"];
    if (isValidLogin) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:LOGIN_FAILED_BLOCK_MESSAGE delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alert show];
        
        NSString *deviceToken = [[SettingManager sharedInstance] getDeviceToken];
        NSString *uuid = [[SettingManager sharedInstance] getUUID];
        if (!uuid) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"디바이스 아이디 없다" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
//            [alert show];

            //return;
        }
        else
        {
            BOOL logoutSuccess = YES;
            logoutSuccess = [[SoapInterface sharedInstance] setLogoutPorg:@{@"dvcId": uuid}];
            
//            if (!logoutSuccess) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"로그아웃에 실패하였습니다" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
//                [alert show];
//            }
        }

        //
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"blockLoginFailed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [_inputText2 setText:@""];
        
        //return;
    }
    
    // 영어 대문자, 소문자, 숫자, 특수기호 4가지 중 3가지 이상을 혼용하였을 경우 8자리 이상, 2가지를 혼용하였을 경우 10자리 이상
    BOOL includeInteger     = ([_inputText2.text rangeOfString:@"[0-9]"         options:NSRegularExpressionSearch].length > 0);
    BOOL includeUpperStr    = ([_inputText2.text rangeOfString:@"[A-Z]"         options:NSRegularExpressionSearch].length > 0);
    BOOL includeLowerStr    = ([_inputText2.text rangeOfString:@"[a-z]"         options:NSRegularExpressionSearch].length > 0);
    BOOL includeSymbol      = ([_inputText2.text rangeOfString:@"[^a-zA-Z0-9_]" options:NSRegularExpressionSearch].length > 0);
    
    NSInteger pwInspection = 0;
    if (includeInteger)     pwInspection++;
    if (includeUpperStr)    pwInspection++;
    if (includeLowerStr)    pwInspection++;
    if (includeSymbol)      pwInspection++;
    
    // ** 암호 검증 로그만찍게 해놓음
    NSInteger txtLength = [_inputText2.text length];
    if (pwInspection >= 3)
    {
        if (txtLength < 8) {
            // 오류처리
//            [self showAlertWithMessage:PASS_INPUT_ERROR_1];
            NSLog(@"8자 이상 입력하세요");
        }
    }
    else
    {
        if (txtLength < 10) {
            // 오류처리
//            [self showAlertWithMessage:PASS_INPUT_ERROR_2];
            NSLog(@"10자 이상 입력하세요");
        }
    }
    
    NSRange range = [_inputText1.text rangeOfString:@"[0-9]*" options:NSRegularExpressionSearch];
    
    if (range.length != [_inputText1.text length]) {
        //[self showAlertWithMessage:OTP_INPUT_NUMBER];
        NSLog(@"숫자만 입력 가능합니다.");
    }
    else if ([_inputText1.text isEqualToString:@""])
        [self showAlertWithMessage:@"아이디를 입력해 주세요"];
    else if ([_inputText2.text isEqualToString:@""])
        [self showAlertWithMessage:@"비밀번호를 입력해 주세요"];
    else
    {
        NSString * strTemp = _inputText1.text;
        // 로그인 요청
        _loginInfoDic = [NSDictionary dictionaryWithObjectsAndKeys: _inputText1.text, @"id", _inputText2.text, @"pw", nil];
        [_loginManager requestLogin:_loginInfoDic withPinCode:NO];
        
        if( [[SettingManager sharedInstance] getIdSave]){
            [[SettingManager sharedInstance] saveIdValue:strTemp];
        }
    }
    
    NSLog(@"[timestamp] 일반 로그인 끝");
}

// 핀코드 등록
- (void)registPinCode
{
    if ([_inputText1.text isEqualToString:@""] || [_inputText2.text isEqualToString:@""])
    {
        [self showAlertWithMessage:PIN_INPUT_BLANK];
        return;
    }
    else if (![_inputText1.text isEqualToString:_inputText2.text])
    {
        [self showAlertWithMessage:PIN_INPUT_NOT_MATCH];
        return;
    }
    else
    {
        // 핀코드 저장
        [[SettingManager sharedInstance] savePinCode:_inputText1.text];
        // id, pw 저장
        [_loginManager saveLoginInfoToKeychain:_loginInfoDic];
        
        // 메인으로 이동
        [_inputText1 resignFirstResponder];
        [_inputText2 resignFirstResponder];

        [self.navigationController pushViewController:[[MainViewController alloc] init] animated:YES];
    }
}

// OTP 발송
- (IBAction)otpCodeSend:(id)sender {

    [_nextBtn setEnabled:true];
    [_inputText2 setEnabled:true];
    [_otpSendButton setEnabled:false];
    
    // 사번
    KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc]  initWithIdentifier:@"UserAuth" accessGroup:nil];
    NSString *employeeNumb = [NSString decodeString:[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)]];
    
    _mobileNumber = [[SoapInterface sharedInstance] requestOTPSendSoapService:employeeNumb];
    
    [[SettingManager sharedInstance] setOtpMobileNumber:_mobileNumber];
    
    NSString * strTemp = [_mobileNumber substringWithRange:NSMakeRange(0, 3)];
    NSString * strViewPhone = [NSString stringWithFormat:@"%@-", strTemp];
    strTemp = [_mobileNumber substringWithRange:NSMakeRange(3, 4)];
    strViewPhone = [NSString stringWithFormat:@"%@%@-", strViewPhone, strTemp];
    strTemp = [_mobileNumber substringWithRange:NSMakeRange(7, 4)];
    strViewPhone = [NSString stringWithFormat:@"%@%@", strViewPhone, strTemp];
    
    NSString *alertString;
    alertString = [NSString stringWithFormat:@"%@ 으로 인증코드를 전송하였습니다.", strViewPhone];
    
    [self showAlertWithMessage:alertString];
    _employeeNumber = employeeNumb;
    
    _otpInputMinute = 3;
    _otpInputSecond = 0;
    _otpFailCount = 0;
    [self startOtpTimer];
}

// 핀코드로 로그인
- (void)pinCodeLogin
{
    NSLog(@"[timestamp] 핀 로그인 시작");
    // 핀코드 로그인 오류초과시 진행을 막는다
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"pinCodeFailed"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:PIN_LOGIN_FAILED_BLOCK_MESSAGE delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    // 핀코드 로그인 공백 제한
    if ([_inputText1.text isEqualToString:@""])
    {
        [self showAlertWithMessage:PIN_INPUT_BLANK];
        return;
    }
    
    // 핀코드 로그인 실패 처리
    if (![[SettingManager sharedInstance] isMatchedPinCode:_inputText1.text])
    {
        [self showAlertWithMessage:PIN_INPUT_NOT_MATCH];
        _pinCodeFailtCount++;
        if (_pinCodeFailtCount >= 3) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"pinCodeFailed"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    // pin code match success
    else
    {
        // 로그인
        [_loginManager requestLogin:nil withPinCode:YES];
    }
    
    NSLog(@"[timestamp] 핀 로그인 끝");
}

- (void)otpCodeLogin
{
    NSLog(@"[timestamp] otp 로그인 시작");
    
    // otp 로그인 공백 제한
    if ([_inputText2.text isEqualToString:@""])
    {
        [self showAlertWithMessage:OTP_INPUT_BLANK];
        return;
    }
    
    _otpNumber = _inputText2.text;
    BOOL bResult = [[SoapInterface sharedInstance] requestOTPValidateSoapService:_employeeNumber hp:_mobileNumber otp:_otpNumber];
    
    if(bResult){
        // 로그인
        //[_loginManager requestLogin:nil withPinCode:YES];
        
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3;
        [transition setType:kCATransitionFade];
        [transition setSubtype:kCATransitionFromRight];
        [self.view.layer addAnimation:transition forKey:nil];
        
        // id, pw 저장
        [_loginManager saveLoginInfoToKeychain:_loginInfoDic];
        
        NSString *uuid = [[SettingManager sharedInstance] getUUID];
        
        BOOL isSave = true;
        NSDictionary *userInfoDic = @{@"sabun"        : _employeeNumber,
                                      @"dvcId"           : (uuid)?uuid:@"",
                                      @"platformCd"          : PLATFORM_CODE,
                                      @"checkMobile"    : _mobileNumber,
                                      @"useYn"   : @"Y"};
        
        isSave = [[SoapInterface sharedInstance] setOTPinformation:userInfoDic];
        
        // 메인 뷰로 이동
        [self.navigationController pushViewController:[[MainViewController alloc] init] animated:YES];
        
    }else{
        
        if(_otpFailCount >= 4){
            _otpFailCount = 0;
            _otpInputMinute = 3;
            _otpInputSecond = 0;
            NSString *strValue = [NSString stringWithFormat:@"입력시간 %02d:%02d", _otpInputMinute, _otpInputSecond];
            [otpTimeOut setText:strValue];
            [self stopOtpTimer];
            [_nextBtn setEnabled:false];
            [_inputText2 setEnabled:false];
            [_otpSendButton setEnabled:true];
            [_inputText2 setText:@""];
            
            [self showAlertWithMessage:OTP_LOGIN_FAILED_LIMIT];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                BOOL logoutSuccess = [[SettingManager sharedInstance] requestSSOLogout];
                
                if (logoutSuccess) {
                    [self readyStandardLogin:keyPadViewFlag orientFlag:0];
                }
            });
            
            NSString *uuid = [[SettingManager sharedInstance] getUUID];
            
            BOOL isSave = true;
            NSDictionary *userInfoDic = @{@"sabun"        : _employeeNumber,
                                          @"dvcId"           : (uuid)?uuid:@"",
                                          @"platformCd"          : PLATFORM_CODE,
                                          @"checkMobile"    : _mobileNumber,
                                          @"useYn"   : @"N"};
            
            isSave = [[SoapInterface sharedInstance] setOTPinformation:userInfoDic];
            
        }else{
            _otpFailCount++;
            [_inputText2 setText:@""];
            NSString * alertString = [NSString stringWithFormat:OTP_INPUT_NOT_MATCH, _otpFailCount];
            [self showAlertWithMessage:alertString];
        }
        
        
    }
    
    NSLog(@"[timestamp] otp 로그인 끝");
}


#pragma mark - Login Delegate Methods
- (void)startedLogin
{
    // 키보드 resign
    [_inputText1 resignFirstResponder];
    [_inputText2 resignFirstResponder];
    
    // 인디케이터 시작
    [[IndicatorView sharedInstance] startIndicator];
}

- (void)endedLogin:(NSInteger)loginResult
{
    [[IndicatorView sharedInstance] stopIndicator];
    
    if (loginResult == 1)
        return;
    
    // 핀로그인시 저장된 패스워드가 틀린경우 처리
    else if (loginResult == 2) {
        [self readyStandardLogin:keyPadViewFlag orientFlag:0];
        [[SettingManager sharedInstance] initPinCode];
        
        return;
    }
    
    // 일반로그인 성공
    if (_progressFlag == LoginState_LOGIN)
    {
        // id, pw 저장
        [_loginManager saveLoginInfoToKeychain:_loginInfoDic];
        
        // 사번
        KeychainItemWrapper *keychainWrapper = [[KeychainItemWrapper alloc]  initWithIdentifier:@"UserAuth" accessGroup:nil];
        NSString *employeeNumb = [NSString decodeString:[keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)]];
        _employeeNumber = employeeNumb;
        
        NSString *deviceToken = [[SettingManager sharedInstance] getDeviceToken];
        
//        if (!deviceToken || [deviceToken isEqualToString:@""])  // 시뮬레이터는 실행하지 않는다
//            return;
        
        NSString *uuid = [[SettingManager sharedInstance] getUUID];
        
        NSDictionary *pushRegDic = @{@"regId"        : (deviceToken)?deviceToken:@"",
                                     @"empNo"        : _employeeNumber,
                                     @"dvcId"        : (uuid)?uuid:@"",
                                     @"modelNo"      : [[SettingManager sharedInstance] getHarwarePlatform],
                                     @"plafrormCode" : @"PT02",
                                     @"brandName"    : @"APPLE"};
        NSArray *resultDic = [[SoapInterface sharedInstance] registPushToken:pushRegDic];
        // 푸쉬 수신 여부를 유저 디폴트에 저장
        [[SettingManager sharedInstance] setPushStatus:resultDic];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 로깅
            NSDictionary *userInfoDic = @{@"logType"        : LOG_TYPE_LOGIN,  //접속 로그 타입 (LT01 : 접속 로그, LT02 : 서비스 접근 로그)
                                          @"code"           : @"",  //서비스코드
                                          @"empNo"          : _employeeNumber,  //사번
                                          @"dvcId"          : (uuid)?uuid:@"",  //기기구분값
                                          @"packageName"    : PACKAGE_NAME,  //패키지명
                                          @"platformCode"   : PLATFORM_CODE}; //플렛폼코드
            [[SoapInterface sharedInstance] setLoggingInfo:userInfoDic];
        });

        //////////////////////////////////////////////////////////////////////////////////////////////////////
        
        CATransition* transition = [CATransition animation];
        transition.duration = 0.3;
        [transition setType:kCATransitionFade];
        [transition setSubtype:kCATransitionFromRight];
        [self.view.layer addAnimation:transition forKey:nil];
        
        //otp 등록화면 표시여부 확인
        BOOL isShow = true;
        
        NSDictionary *userInfoDic = @{@"dvcID"        : (uuid)?uuid:@"",
                                      @"sabun"           : _employeeNumber};
        
        NSString *resultString = [[SoapInterface sharedInstance] getOTPisShow:userInfoDic servicename:@"OtpCheckUsr"];
        
        NSRange range = [resultString rangeOfString:@"0200"];
        if(range.location != NSNotFound){
            isShow = true;
        }
        
        range = [resultString rangeOfString:@"0000"];
        if(range.location != NSNotFound){
            isShow = false;
        }
        
        range = [resultString rangeOfString:@"0300"];
        if(range.location != NSNotFound){
            
            BOOL logoutSuccess = [[SettingManager sharedInstance] requestSSOLogout];
            if(logoutSuccess)
                NSLog(@"logoutSuccess...");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:OTP_LIMIT delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
            [alert show];
            
            return;
        }
        
        //isShow = true;
        
        // 업데이트 체크
        NSInteger returnValue = [self setUpdateView];
        if(returnValue == 1)
            return;
        
        if(isShow){
            [self readyRegistOTP:0];
        }else{
            // 메인 뷰로 이동
            [self.navigationController pushViewController:[[MainViewController alloc] init] animated:YES];
        }
    }
    // 핀코드 로그인 성공
    else if (_progressFlag == LoginState_PIN_CODE_LOGIN)
    {
        // 메인 뷰로 이동
        [self.navigationController pushViewController:[[MainViewController alloc] init] animated:YES];
    }
}


#pragma mark - Alert Methods
- (void)showAlertWithMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
    [alert show];
}

@end
