//
//  SettingViewController.m
//  ktis Mobile
//
//  Created by Hyuck on 1/27/14.
//
//

#import "SettingViewController.h"
#import "SettingManager.h"
#import "LoginViewController.h"
#import "IndicatorView.h"
#import "LoginViewController.h"
#import "Defines.h"
#import "KeychainItemWrapper.h"
#import "SecurityManager.h"
#import "SoapInterface.h"

@interface SettingViewController ()
{
    BOOL                    _isSSOValid;
    IBOutlet UIScrollView   *_settingScrollView;
    
    IBOutlet UILabel        *_empNoLabel;
    IBOutlet UILabel        *_empNameLabel;
    IBOutlet UILabel        *_empPartLabel;
    
    IBOutlet UIButton       *_mailOff;
    IBOutlet UIButton       *_permittOff;
    IBOutlet UIButton       *_hrOff;
    IBOutlet UIButton       *_sailsOff;
    
    IBOutlet UIButton       *_mailOn;
    IBOutlet UIButton       *_permittOn;
    IBOutlet UIButton       *_hrOn;
    IBOutlet UIButton       *_sailsOn;
}
- (void)setPushSwitchStatus;
- (IBAction)pressPushOff:(id)sender;
- (IBAction)pressPushOn:(id)sender;
- (IBAction)pressBack:(id)sender;
- (IBAction)pressLogout:(id)sender;
- (void)goLogin;
@end

@implementation SettingViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_settingScrollView setContentSize:CGSizeMake(self.view.frame.size.width, 440.0f)];

    // 유저 정보
    _isSSOValid = NO;
    NSDictionary *userInfDic = [[SettingManager sharedInstance] getSSOStatus];
    if (userInfDic) {
        _empNoLabel.text    = userInfDic[@"sabun"];
        _empNameLabel.text  = userInfDic[@"username"];
        _empPartLabel.text  = userInfDic[@"deptname"];
        
        _isSSOValid = YES;
    }
    
    
    // 인증 무효시 로그인으로 이동
    if (!_isSSOValid) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"인증이 만료되었습니다\n다시 로그인 해주세요" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"확인", nil];
        [alert show];
        return;
    }
    
    [self setPushSwitchStatus];
}


#pragma mark - Push Setting Toggles
// 저장된 푸쉬 스위치 상태 표시
- (void)setPushSwitchStatus
{
    NSDictionary *statDic    = [[SettingManager sharedInstance] getPushStatus];
//    NSLog(@"설정된 푸쉬 내용%@", statDic);
    
    BOOL isPushSettingEnable = [[SettingManager sharedInstance] isValidPushSwitch];
    if (!isPushSettingEnable)   // 푸쉬 설정이 불가능한 경우 버튼 disable
    {
        _hrOn.enabled       = NO;
        _permittOn.enabled  = NO;
        _mailOn.enabled     = NO;
        _sailsOn.enabled    = NO;
        
        _hrOff.hidden       = YES;
        _permittOff.hidden  = YES;
        _mailOff.hidden     = YES;
        _sailsOff.hidden    = YES;
    }
    else
    {
        BOOL allowHrPush        = [statDic[@"hr"]       boolValue];     // PS04 HR
        BOOL allowPermittPush   = [statDic[@"decision"] boolValue];     // PS02 전자결재
        BOOL allowMailPush      = [statDic[@"mail"]     boolValue];     // PS03 ktis메일
#warning 영업지원 적용시 sail 관련 주석해제
//        BOOL allowSailsPush     = [statDic[@"sails"]  boolValue];       // PS01 영업지원
        
//        BOOL allowCorpMapPush   = [statDic[@"corpMap"]  boolValue];    // PS05 조직도
//        BOOL allowNoticePush    = [statDic[@"notice"]   boolValue];     // PS06 공지사항
        
        _hrOff.hidden      = !allowHrPush;
        _hrOn.hidden       = allowHrPush;
        _permittOff.hidden = !allowPermittPush;
        _permittOn.hidden  = allowPermittPush;
        _mailOff.hidden    = !allowMailPush;
        _mailOn.hidden     = allowMailPush;
//        _sailsOff.hidden    = !allowSailsPush;
//        _sailsOn.hidden     = allowSailsPush;
    }
}

#pragma mark - Actions
// 푸쉬 끔
- (IBAction)pressPushOff:(id)sender
{
    [[IndicatorView sharedInstance] startIndicator];
    NSInteger btnTag = ((UIButton *)sender).tag;
    [self setPushStat:NO withBtnTag:btnTag];
}

// 푸쉬 켬
- (IBAction)pressPushOn:(id)sender
{
    [[IndicatorView sharedInstance] startIndicator];
    
    NSInteger btnTag = ((UIButton *)sender).tag;
    [self setPushStat:YES withBtnTag:btnTag];
}

- (void)setPushStat:(BOOL)isOn withBtnTag:(NSInteger)btnTag
{
    BOOL isSuccess = [[SettingManager sharedInstance] allowPush:btnTag isValid:isOn];
    if (isSuccess) {
        if (btnTag == 1) {
            _mailOff.hidden     = !isOn;    // 메일
            _mailOn.hidden      = isOn;
            [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:ALLOW_PUSH_MAIL];      // PS03 ktis메일
            
        } else if (btnTag == 2) {
            _permittOff.hidden  = !isOn;    // 전자결재
            _permittOn.hidden   = isOn;
            [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:ALLOW_PUSH_DECISION];  // PS02 전자결재
            
        } else if (btnTag == 3) {
            _hrOff.hidden       = !isOn;    // hr
            _hrOn.hidden        = isOn;
            [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:ALLOW_PUSH_HR];        // PS04 영업지원
            
        } else if (btnTag == 4) {
            _sailsOff.hidden    = !isOn;   // 영업지원
            _sailsOn.hidden     = isOn;
            [[NSUserDefaults standardUserDefaults] setBool:isOn forKey:ALLOW_PUSH_SAILS];      // PS01 영업지원
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[IndicatorView sharedInstance] stopIndicator];
}

// 로그아웃 진행
- (IBAction)pressLogout:(id)sender
{
    NSLog(@"[timestamp] 로그아웃 누름");
    [[IndicatorView sharedInstance] startIndicator];
    
    BOOL logoutSuccess = [[SettingManager sharedInstance] requestSSOLogout];
    
    if (logoutSuccess) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"성공" message:@"성공적으로 로그아웃되었습니다." delegate:self cancelButtonTitle:@"확인" otherButtonTitles:nil, nil];
        [alert show];
        
        [[SettingManager sharedInstance] initPinCode];
        [self goLogin];
    }
    
    [[IndicatorView sharedInstance] stopIndicator];
    NSLog(@"[timestamp] 로그아웃 끝");
}

#pragma mark - Navigation Actions
- (IBAction)pressBack:(id)sender
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

@end
