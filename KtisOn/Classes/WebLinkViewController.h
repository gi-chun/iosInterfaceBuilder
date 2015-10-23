//
//  WebLinkViewController.h
//  ktis Mobile
//
//  Created by Hyuck on 1/24/14.
//
//

#import <UIKit/UIKit.h>

@interface WebLinkViewController : UIViewController <UIWebViewDelegate>

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil withURL:(NSString*)url withTitle:(NSString *)title;

@end
