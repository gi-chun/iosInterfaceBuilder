//
//  WebLinkViewController.m
//  ktis Mobile
//
//  Created by Hyuck on 1/24/14.
//
//

#import "WebLinkViewController.h"
#import "IndicatorView.h"
#import "LoginViewController.h"
#import "Defines.h"

@interface WebLinkViewController ()
{
    IBOutlet UIWebView      *_webView;
    IBOutlet UILabel        *_titleLabel;
    NSString                *_title;
    
    NSURL                   *_url;
}

- (IBAction)pressBottomMenu:(id)sender;

@end

@implementation WebLinkViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withURL:(NSString*)url withTitle:(NSString *)title
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _url    = [NSURL URLWithString:url];
        _title  = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _webView.delegate = self;
    
    _titleLabel.text = _title;
    
    NSDictionary *userInfDic = [[SettingManager sharedInstance] getSSOStatus];
    if (!userInfDic)
        [self goLogin];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:_url];
    [_webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


#pragma mark - Actions
- (void)goLogin
{
    // 로그인 페이지로 이동
    for (id viewController in [[self navigationController] viewControllers]) {
        if ([viewController isKindOfClass:[LoginViewController class]])
            [self.navigationController popToViewController:viewController animated:YES];
    }
}

- (IBAction)pressBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pressBottomMenu:(id)sender
{
    NSInteger tag = ((UIBarButtonItem *)sender).tag;
    if (tag == 1)
        [_webView goBack];
    else if (tag == 2)
        [_webView goForward];
    else if (tag == 3)
        [_webView reload];
}


#pragma mark - Web view delegate methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([[[request URL] scheme] isEqualToString:@"openstore"])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_URL]];
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[IndicatorView sharedInstance] startIndicator];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[IndicatorView sharedInstance] stopIndicator];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[IndicatorView sharedInstance] stopIndicator];
}

@end
