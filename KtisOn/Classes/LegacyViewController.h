//
//  LegacyViewController.h
//  ktis Mobile
//
//  Created by Hyuck on 1/24/14.
//
//

#import <Cordova/CDVViewController.h>
#import <Cordova/CDVCommandDelegateImpl.h>
#import <Cordova/CDVCommandQueue.h>
#import <AddressBook/AddressBook.h>

@interface LegacyViewController : CDVViewController <UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *interactionController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil menuSeq:(NSInteger)menuSeq menuArr:(NSArray *)menuArr notice:(NSString *)noticeNo pushUrl:(NSURL *)pushUrl;

/* 코르도바 커스텀 플러그인 메소드 */
- (void)toggleGlobalMenu;
- (void)indicator;
- (void)sessionClose;
- (void)goHome;
- (void)openFile:(NSString *)fileUrl;
- (void)callPhone:(NSString *)phoneNumb;
- (void)sendSMS:(NSString *)phoneNumb;
- (void)sendMail:(NSString *)mailAddress backUrl:(NSString *)backUrl;
- (void)backSendMail;
- (void)insertContact:(NSString *)name contact:(NSString *)contact;
@end

@interface MainCommandDelegate : CDVCommandDelegateImpl
@end

@interface MainCommandQueue : CDVCommandQueue
@end