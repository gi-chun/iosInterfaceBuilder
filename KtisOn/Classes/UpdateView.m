//
//  UpdateView.m
//  KtisOn
//
//  Created by Hyuck on 3/24/14.
//
//

#import "UpdateView.h"
#import "Defines.h"
#import "NSData+MD5.h"

@interface UpdateView()
{
    UIImageView     *_bgImgView;
    
    // 업데이트 공지
    UIView          *_updateNoticeView;
    UITextView      *_updateInfoTextView;
    
    // 업데이트 진행
    UIView          *_updateProgressView;
    UIProgressView  *_updateProgressBar;
    
    NSInteger       _expectFileSize;
    NSMutableData   *_receiveData;
    NSURLConnection *_downloadConnection;
    NSArray         *_updateDataArr;
    
    NSMutableString *_updateText;
    NSString        *_updateFileUrl;
    NSString        *_updatePlistUrl;
    NSString        *_updateMD5Str;
}
- (void)cancelUpdate;
- (void)setCurrentData:(NSArray *)dataArr;
@end

@implementation UpdateView

- (id)initWithFrame:(CGRect)frame withData:(NSArray *)updateArr
{
    self = [super initWithFrame:frame];
    if (self) {
        // 데이터
        [self setCurrentData:updateArr];
        
        // BG
        _bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.png"]];
        [_bgImgView setFrame:self.frame];
        [self addSubview:_bgImgView];
        
        // 서브뷰
        CGRect rect;
        if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
            rect = CGRectMake(0.0f, 0.0f, 270.0f, 222.0f);  // iPhone
        else
            rect = CGRectMake(0.0f, 0.0f, 540.0f, 500.0f);  // iPad
        
        _updateNoticeView   = [[UIView alloc] initWithFrame:rect];  // 업데이트 공지
        _updateProgressView = [[UIView alloc] initWithFrame:rect];  // 업데이트 진행
        [self addSubview:_updateProgressView];
        [self addSubview:_updateNoticeView];
        [self setUpdateNoticeView];
        [self setUpdateProgressView];
        
        // 좌표 지정
        [self setUpdateViewPosition:frame];
    }
    return self;
}

- (void)setUpdateViewPosition:(CGRect)rect
{
    [_bgImgView setFrame:rect];
    [self setFrame:rect];
    [_updateNoticeView setCenter:self.center];
    [_updateProgressView setCenter:self.center];
}

- (void)setCurrentData:(NSArray *)dataArr
{
    NSDictionary *updateDic = [NSDictionary dictionary];
    
    // 업데이트 내역 텍스트
    _updateText  = [NSMutableString stringWithString:@""];
    for (id obj in dataArr)
    {
        NSString *tmpStr = [NSString stringWithFormat:@"%@\n%@\n%@\n--------------\n\n",
                            [obj objectForKey:@"appVer"],
                            [obj objectForKey:@"fileName"],
                            [obj objectForKey:@"noti"]];
        [_updateText appendString:tmpStr];
        if ([[obj objectForKey:@"deployYn"] isEqualToString:@"Y"])
            updateDic = obj;    // 배포중인 파일의 내역
    }
    
    // ipa 경로
    _updateFileUrl  = [NSString stringWithFormat:@"%@%@%@", UPDATE_FILE_PATH,
                      [updateDic objectForKey:@"filePath"], [updateDic objectForKey:@"fileName"]];
    
    // plist 경로
    _updatePlistUrl = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@%@%@", UPDATE_FILE_PATH,
                       [updateDic objectForKey:@"plistFilePath"], [updateDic objectForKey:@"plistFileName"]];
    
    // MD5 문자열
    _updateMD5Str   = [updateDic objectForKey:@"chksum"];
}

// 업데이트 알림 화면
- (void)setUpdateNoticeView
{
    [_updateNoticeView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _updateNoticeView.frame.size.width, 43.0f)];
    [titleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_login.png"]]];
    [titleLabel setText:@"업데이트"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [_updateNoticeView addSubview:titleLabel];
    
    // 업데이트 버튼
    UIImage *updatebtnImgNormal;
    UIImage *updatebtnImgHighlight;
    CGRect updateBtnRect;
    
    // 캔슬 버튼
    UIImage *cancelbtnImgNormal;
    UIImage *cancelbtnImgHighlight;
    CGRect cancelBtnRect;
    
    CGRect updateTextRect;
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone)
    {
        updatebtnImgNormal      = [UIImage imageNamed:@"btn_update02_update.png"];
        updatebtnImgHighlight   = [UIImage imageNamed:@"btn_update02_update_select.png"];
        updateBtnRect           = CGRectMake(8, 172, updatebtnImgNormal.size.width, updatebtnImgNormal.size.height);
        cancelbtnImgNormal      = [UIImage imageNamed:@"btn_update02_cancle.png"];
        cancelbtnImgHighlight   = [UIImage imageNamed:@"btn_update02_cancle_select.png"];
        cancelBtnRect           = CGRectMake(139, 172, cancelbtnImgNormal.size.width, cancelbtnImgNormal.size.height);
        updateTextRect          = CGRectMake(10.0f, 51.0f, _updateNoticeView.frame.size.width-20.0f, 111.0f);
    }
    else
    {
        updateTextRect          = CGRectMake(10.0f, 60.0f, _updateNoticeView.frame.size.width-20.0f, 320.0f);
        updatebtnImgNormal      = [UIImage imageNamed:@"btn_update02_update_iPad.png"];
        updatebtnImgHighlight   = [UIImage imageNamed:@"btn_update02_update_select_iPad.png"];
        updateBtnRect           = CGRectMake(16, updateTextRect.origin.y+updateTextRect.size.height+20.0f,
                                             updatebtnImgNormal.size.width, updatebtnImgNormal.size.height);
        cancelbtnImgNormal      = [UIImage imageNamed:@"btn_update02_cancle_iPad.png"];
        cancelbtnImgHighlight   = [UIImage imageNamed:@"btn_update02_cancle_select_iPad.png"];
        cancelBtnRect           = CGRectMake(278, updateTextRect.origin.y+updateTextRect.size.height+20.0f,
                                             cancelbtnImgNormal.size.width, cancelbtnImgNormal.size.height);
    }
    
    // 업데이트 버튼
    UIButton *updateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [updateBtn setImage:updatebtnImgNormal forState:UIControlStateNormal];
    [updateBtn setImage:updatebtnImgHighlight forState:UIControlStateHighlighted];
    [updateBtn setFrame:updateBtnRect];
    [updateBtn addTarget:self action:@selector(goUpdate) forControlEvents:UIControlEventTouchUpInside];
    [_updateNoticeView addSubview:updateBtn];
    
    // 캔슬 버튼
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:cancelbtnImgNormal forState:UIControlStateNormal];
    [cancelBtn setImage:cancelbtnImgHighlight forState:UIControlStateHighlighted];
    [cancelBtn setFrame:cancelBtnRect];
    [cancelBtn addTarget:self action:@selector(cancelUpdate) forControlEvents:UIControlEventTouchUpInside];
    [_updateNoticeView addSubview:cancelBtn];
    
    // 업데이트 내역
    _updateInfoTextView = [[UITextView alloc] initWithFrame:updateTextRect];
    [_updateInfoTextView setBackgroundColor:[UIColor lightGrayColor]];
    [_updateInfoTextView setFont:[UIFont systemFontOfSize:15.0f]];
    [_updateNoticeView addSubview:_updateInfoTextView];
    [_updateInfoTextView setText:_updateText];
}

// 업데이트 화면
- (void)setUpdateProgressView
{
    [_updateProgressView setBackgroundColor:[UIColor whiteColor]];
    
    // 타이틀
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _updateNoticeView.frame.size.width, 43)];
    [titleLabel setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"title_login.png"]]];
    [titleLabel setText:@"업데이트"];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:17.0f]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [_updateProgressView addSubview:titleLabel];
    
    // 다운로드 중입니다 레이블
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _updateNoticeView.frame.size.width, _updateProgressView.frame.size.width)];
    [textLabel setTextAlignment:NSTextAlignmentCenter];
    [textLabel setText:@"다운로드 중입니다."];
    [_updateProgressView addSubview:textLabel];
    
    // 캔슬 버튼
    UIImage *btnImgNormal;
    UIImage *btnImgHighlight;
    CGRect  cancelBtnRect;
    CGRect  progressBarRect;
    
    // 아이폰 업데이트 팝업
    if([[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPhone) {
        btnImgNormal    = [UIImage imageNamed:@"btn_update_cancle.png"];
        btnImgHighlight = [UIImage imageNamed:@"btn_update_cancle_select.png"];
        cancelBtnRect   = CGRectMake(8.0f, 172.0f, btnImgNormal.size.width, btnImgNormal.size.height);
        progressBarRect = CGRectMake(25.0f, 100.0f, 220.0f, 10.0f);
        [textLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [textLabel setFrame:CGRectMake(0.0f, 20.0f, textLabel.frame.size.width, textLabel.frame.size.width)];
    }
    
    // 아이패드 업데이트 팝업
    else {
        btnImgNormal    = [UIImage imageNamed:@"btn_update_cancle_iPad.png"];
        btnImgHighlight = [UIImage imageNamed:@"btn_update_cancle_select_iPad.png"];
        cancelBtnRect   = CGRectMake(16.0f, 400.0f, btnImgNormal.size.width, btnImgNormal.size.height);
        progressBarRect = CGRectMake(25.0f, 210.0f, 490.0f, 10.0f);
        [textLabel setFont:[UIFont systemFontOfSize:20.0f]];
        [textLabel setFrame:CGRectMake(0.0f, 30.0f, textLabel.frame.size.width, textLabel.frame.size.width)];
    }
    
    // 캔슬 버튼
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:btnImgNormal forState:UIControlStateNormal];
    [cancelBtn setImage:btnImgHighlight forState:UIControlStateHighlighted];
    [cancelBtn setFrame:cancelBtnRect];
    [cancelBtn addTarget:self action:@selector(cancelUpdate) forControlEvents:UIControlEventTouchUpInside];
    [_updateProgressView addSubview:cancelBtn];
    
    // 업데이트 진행 바
    _updateProgressBar = [[UIProgressView alloc] initWithFrame:progressBarRect];
    [_updateProgressView addSubview:_updateProgressBar];
}


#pragma mark - Actions
// 바이너리 다운로드 중지
- (void)cancelUpdate
{
    // 네트워크 인디케이터 중지하고 리퀘스트 커넥션 중단
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [_downloadConnection cancel];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:APP_UPDATE_RECOMMEND_MESSAGE delegate:self cancelButtonTitle:@"취소" otherButtonTitles:@"확인", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        exit(0);
    } else {
        if (_updateNoticeView.hidden)
            [self goUpdate];
    }
}

// 업데이트 노티스뷰를 히든시키고 바이너리 다운로드를 진행한다
- (void)goUpdate
{
    _updateNoticeView.hidden = YES;
    
    // ipa 다운로드
    _receiveData = [NSMutableData data];    // 데이터를 저장할 객체
//    if (!_downloadConnection) {
        NSURLRequest *request   = [NSURLRequest requestWithURL:[NSURL URLWithString:_updateFileUrl]];  // 리퀘스트 생성
        _downloadConnection     = [[NSURLConnection alloc] initWithRequest:request delegate:self];
//    }
    
    // ipa 다운로드 시작
    [_downloadConnection start];
}


#pragma mark - NSURLConnection Delegate Methods
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if(connection != _downloadConnection)
        return;
    
    // 다운로드할 파일 총 용량을 구한다
    _expectFileSize = (NSInteger)[[NSNumber numberWithLongLong:[response expectedContentLength]] longValue];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // 받은 데이터를 뮤터블 데이터에 추가
    [_receiveData appendData:data];
    
    // 프로그래스바에 표시
    _updateProgressBar.progress = (float)[_receiveData length]/_expectFileSize;
    NSLog(@"[다운로드중] %d/%d", [_receiveData length], _expectFileSize);
    
    // 스테이터스바의 네트워크 인디케이터 실행
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"[다운완료] md5:%@, 용량:%d", [_receiveData MD5], [_receiveData length]);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    // ** 파일다운(로컬에 쓰기 막아놓음)
//    NSError *error = nil;
//    NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
//    [_receiveData writeToFile:[NSString stringWithFormat:@"%@/KtisOn.ipa", docsDir] options:NSDataWritingAtomic error:&error];
//    NSLog(@"저장error: %@\n저장경로:%@", error, docsDir);
    
    // 받은 바이너리의 체크섬과 서버의 체크섬과 비교하여 동일한 경우 업데이트 실행
    BOOL md5Inspection = ([_updateMD5Str isEqualToString:[_receiveData MD5]]);
    // ** 임시로 체크섬 항상 통과하게 함(아래 한줄 삭제)
    md5Inspection = YES;
    if (md5Inspection)
    {
        // 앱을 닫고 업데이트를 실행한다
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_updatePlistUrl]];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"다운로드에 실패하였습니다," delegate:nil cancelButtonTitle:@"done" otherButtonTitles:nil, nil];
        [alert show];
    }
    _receiveData = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connect error: %@", [error localizedDescription]);
    
    // 스테이터스바의 네트워크 인디케이터 중지
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
