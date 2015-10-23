//
//  SoapInterface.m
//  KtisOn
//
//  Created by Hyuck on 3/3/14.
//
//

#import "SoapInterface.h"
#import "Defines.h"
#import "XmlParser.h"

@interface SoapInterface()
{
    XmlParser *_xmlParser;
}
- (NSArray *)requestSoapService:(NSString *)requestXmlStr servicename:(NSString *)servicename;
- (NSString *)requestSoapServiceForOtpShow:(NSString *)sabun dvcId:(NSString *)dvcId;
- (NSString *)requestSoapServiceForOtpSave:(NSDictionary *)empInfoDic;

@end

@implementation SoapInterface

static dispatch_once_t once;
static SoapInterface *_sharedInstance = nil;

+ (SoapInterface *) sharedInstance
{
    if (!_sharedInstance)
    {
        dispatch_once(&once, ^{
            _sharedInstance = [[SoapInterface alloc] init];
        });
    }
    return _sharedInstance;
}

- (id)init
{
    if (self = [super init]) {
        _xmlParser = [[XmlParser alloc] init];
    }
    return self;
}


#pragma mark - Service Interfaces
#pragma mark 푸쉬 토큰 등록
- (NSArray *)registPushToken:(NSDictionary *)registDic
{
    NSLog(@"(푸쉬등록 요청):%@", registDic);
    NSString *requestXML    = [self makeRequestXML:registDic requestType:@"pushRegId" namespace:REG_PUSH_ID_Namespace];
    NSArray *resultArr      = [self requestSoapService:requestXML servicename:@"PushRegId"];
    NSLog(@"(푸쉬등록 결과):%d건\n결과:%@", [resultArr count], resultArr);
    return resultArr;
}

#pragma mark 푸쉬 상태 전송
- (BOOL)setAllowPush:(NSDictionary *)pushDic
{
    NSLog(@"(푸쉬설정 요청):%@", pushDic);
    NSString *requestXML    = [self makeRequestXML:pushDic requestType:@"pushSetting" namespace:PUSH_SETTING_Namespace];
    NSArray *resultArr      = [self requestSoapService:requestXML servicename:@"PushSetting" ];
    NSLog(@"(푸쉬설정):%d건\n결과:%@", [resultArr count], resultArr);
    
    if ([[[resultArr firstObject] objectForKey:@"return"] isEqualToString:@"true"])
        return YES;
    else
        return NO;
}

#pragma mark 앱 업데이트 정보 조회
- (NSArray *)getAppUpdateInfo:(NSDictionary *)updateDic
{
    NSLog(@"(업데이트 요청):%@", updateDic);
    NSString *requestXML    = [self makeRequestXML:updateDic requestType:@"updateApp" namespace:APP_UPDATE_Namespace];
    NSArray *resultArr      = [self requestSoapService:requestXML servicename:@"UpdateApp" ];
    NSLog(@"(업데이트):%d건\n결과:%@", [resultArr count], resultArr);
    return resultArr;
}

#pragma mark 메뉴 목록 조회
- (NSArray *)getMainMenuList:(NSDictionary *)empInfoDic
{
    NSLog(@"(메뉴요청):%@", empInfoDic);
    NSString *requestXML    = [self makeRequestXML:empInfoDic requestType:@"servicePermission" namespace:MENU_LIST_Namespace];
    NSArray *resultArr      = [self requestSoapService:requestXML servicename:@"ServicePermission"];
    NSLog(@"(메뉴):%d건\n결과:%@", [resultArr count], resultArr);
    return resultArr;
}

#pragma mark 롤링 공지사항 조회
- (NSArray *)getNoticeList
{
    NSLog(@"(공지 요청)");
    NSString *requestXML    = [self makeRequestXML:nil requestType:@"notiList" namespace:NOTICE_LIST_Namespace];
    NSArray *resultArr      = [self requestSoapService:requestXML servicename:@"NotiList"];
    NSLog(@"(공지):%d건\n결과:%@", [resultArr count], resultArr);
    return resultArr;
}

#pragma mark 뱃지 개수 조회
- (NSDictionary *)getBadgeCount:(NSDictionary *)empInfoDic
{
    NSLog(@"(뱃지요청):%@", empInfoDic);
    NSString *requestXML    = [self makeRequestXML:empInfoDic requestType:@"badgeCount" namespace:BADGE_COUNT_Namespace];
    NSArray *resultArr      = [self requestSoapService:requestXML servicename:@"BadgeCount"];
    NSLog(@"(뱃지):%d건\n결과:%@", [resultArr count], resultArr);
    return ([resultArr count] > 0)? [resultArr objectAtIndex:0]:nil;
}

#pragma mark 접속 로그 전송
- (void)setLoggingInfo:(NSDictionary *)empInfoDic
{
    NSLog(@"(로깅요청):%@", empInfoDic);
    NSString *requestXML    = [self makeRequestXML:empInfoDic requestType:@"logging" namespace:ACCESS_LOG_Namespace];
    NSArray *resultArr      = [self requestSoapService:requestXML servicename:@"Logging"];
    NSLog(@"(로깅):%d건\n결과:%@", [resultArr count], resultArr);
}

#pragma mark 로그아웃시 다비아스 아이디 처리
- (BOOL)setLogoutPorg:(NSDictionary *)empInfoDic
{
    NSLog(@"(로그아웃처리요청):%@", empInfoDic);
    NSString *requestXML    = [self makeRequestXML:empInfoDic requestType:@"logout" namespace:LOG_OUT_PROG_Namespace];
    NSArray *resultArr      = [self requestSoapService:requestXML servicename:@"Logout"];
    NSLog(@"(로그아웃처리결과):%d건\n결과:%@", [resultArr count], [[resultArr firstObject] objectForKey:@"return"]);
    if ([[[resultArr firstObject] objectForKey:@"return"] isEqualToString:@"true"])
        return YES;
    else
        return NO;
}

#pragma mark OTP Show 여부
- (NSString *)getOTPisShow:(NSDictionary *)empInfoDic servicename:(NSString *)servicename
{
    NSLog(@"(OTPShow여부요청):%@", empInfoDic);
    NSString *result = [self requestSoapServiceForOtpShow:[empInfoDic objectForKey:@"sabun"] dvcId:[empInfoDic objectForKey:@"dvcID"]];
    NSLog(@"(OTPShow여부결과):결과:%@", result);
    
    return result;
}

#pragma mark OTP save OTP information After OTP validation
- (BOOL)setOTPinformation:(NSDictionary *)empInfoDic
{
    NSLog(@"(OTPSave요청):%@", empInfoDic);
    
    NSString *result = [self requestSoapServiceForOtpSave:empInfoDic];
    
    NSRange range = [result rangeOfString:@"true"];
    if(range.location != NSNotFound){
        return true;
    }
    
    return false;
}

- (NSString *)requestOTPSendSoapService:(NSString *)id
{
    NSString *strReturn = @"";
    
    // service url
    NSString *serviceUrl    = [NSString stringWithFormat:@"%@?userID=%@",OTP_SEND_SERVER_URL, id];
    //    NSLog(@"serviceUrl %@\ncomplete xml:%@", serviceUrl, reqXmlStr);
    
    // make request
    NSTimeInterval requestTimeInterval = 30.0;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serviceUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:requestTimeInterval];
    
    //    [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //    [request addValue: @"" forHTTPHeaderField:@"SOAPAction"];
    //    [request addValue: [NSString stringWithFormat:@"%d", [requestXmlStr length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"GET"];
    //    [request setHTTPBody: [requestXmlStr dataUsingEncoding:NSUTF8StringEncoding]];
    //
    // get response data
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error)
        NSLog(@"error:%@", error);
    
    strReturn = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strReturn);
    
    NSString *alertString;
    alertString = [strReturn substringWithRange:NSMakeRange([strReturn rangeOfString:@"'"].location+1, 11)];
    strReturn = alertString;
    
    return strReturn;
}

- (BOOL)requestOTPValidateSoapService:(NSString *)id hp:(NSString *)hp otp:(NSString *)otp
{
    NSString *strReturn = @"";
    
    // service url
    NSString *serviceUrl    = [NSString stringWithFormat:@"%@?userID=%@&mobile=%@&otpNum=%@",OTP_VALIDATE_SERVER_URL, id, hp, otp];
    //    NSLog(@"serviceUrl %@\ncomplete xml:%@", serviceUrl, reqXmlStr);
    
    // make request
    NSTimeInterval requestTimeInterval = 30.0;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serviceUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:requestTimeInterval];
    
    [request setHTTPMethod:@"GET"];
    // get response data
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (error){
        NSLog(@"error:%@", error);
        return false;
    }
    
    strReturn = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strReturn);
    
//    if ([strReturn containsString:@"false"]) {
//        return false;
//    }
    
    NSRange range = [strReturn rangeOfString:@"false"];
    if(range.location != NSNotFound){
        return false;
    }
    
    return true;
}

#pragma mark - Request via Soap Service
// Make Request Url
- (NSString *)makeRequestXML:(NSDictionary *)requestBodyDic requestType:(NSString *)reqType namespace:(NSString *)namespace
{
    // xml header
    NSMutableString *xmlStr =
    [NSMutableString stringWithString:[NSString stringWithFormat:
                                       @"<v:Envelope xmlns:i='http://www.w3.org/2001/XMLSchema-instance' "
                                       "xmlns:d='http://www.w3.org/2001/XMLSchema' "
                                       "xmlns:c='http://schemas.xmlsoap.org/soap/encoding/' "
                                       "xmlns:v='http://schemas.xmlsoap.org/soap/envelope/'> "
                                       "<v:Header />"
                                       "<v:Body>"
                                       "<n0:%@ id='o0' c:root='1' xmlns:n0='%@/'>"
                                       "<%@ i:type='d:anyType'>",
                                       reqType, namespace, reqType]];
    
    // xml body
    for (NSString *key in requestBodyDic)
        [xmlStr appendString:[NSString stringWithFormat:@"<%@ i:type='d:string'>%@</%@>", key, [requestBodyDic objectForKey:key], key]];
    
    // xml end
    [xmlStr appendString:[NSString stringWithFormat:@"</%@></n0:%@></v:Body></v:Envelope>", reqType, reqType]];
    
    return xmlStr;
}

- (NSArray *)requestSoapService:(NSString *)requestXmlStr servicename:(NSString *)servicename
{
    // service url
    NSString *serviceUrl    = [NSString stringWithFormat:@"%@%@?wsdl",GATEWAY_SERVER_URL, servicename];
//    NSLog(@"serviceUrl %@\ncomplete xml:%@", serviceUrl, reqXmlStr);
    
    // make request
    NSTimeInterval requestTimeInterval = 30.0;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serviceUrl]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:requestTimeInterval];
    
    [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue: @"" forHTTPHeaderField:@"SOAPAction"];
    [request addValue: [NSString stringWithFormat:@"%d", [requestXmlStr length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [requestXmlStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    // get response data
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error)
        NSLog(@"error:%@", error);
    
    // parse data and return array
    NSArray *resultArr = [NSArray array];
    resultArr = [_xmlParser getParsedData:receivedData];
//    for (id obj in resultArr)
//        NSLog(@"result : %@", obj);
    
    return resultArr;
}

- (NSString *)requestSoapServiceForOtpShow:(NSString *)sabun dvcId:(NSString *)dvcId
{
    NSString *strReturn = @"";
    
    NSString *soapMessage = [NSString stringWithFormat: @"<v:Envelope xmlns:i='http://www.w3.org/2001/XMLSchema-instance' xmlns:d='http://www.w3.org/2001/XMLSchema' xmlns:c='http://schemas.xmlsoap.org/soap/encoding/' xmlns:v='http://schemas.xmlsoap.org/soap/envelope/'> <v:Header /> <v:Body><n0:otpCheckUsr id='o0' c:root='1' xmlns:n0='http://otpcheckusr.server.ws.gw.ktis.com/'> <OtpCheckUsr i:type='d:anyType'> <sabun i:type='d:string'>%@</sabun> <dvcId i:type='d:string'>%@</dvcId> </OtpCheckUsr> </n0:otpCheckUsr> </v:Body> </v:Envelope>", sabun, dvcId];
    
    //NSString *serviceUrl    = [NSString stringWithFormat:@"%@%@?wsdl",GATEWAY_SERVER_URL, servicename];
    //https://mgw.ktis.co.kr/gw/ws/
    NSString *serviceUrl    = [NSString stringWithFormat:@"%@OtpCheckUsr?wsdl",GATEWAY_SERVER_URL];
    
    NSURL *url = [NSURL URLWithString:serviceUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue: @"" forHTTPHeaderField:@"SOAPAction"];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    // get response data
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error)
        NSLog(@"error:%@", error);
    
    strReturn = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strReturn);
    
    return strReturn;
}

- (NSString *)requestSoapServiceForOtpSave:(NSDictionary *)empInfoDic
{
    NSString *strReturn = @"";
    
    NSString *soapMessage = [NSString stringWithFormat: @"<v:Envelope xmlns:i='http://www.w3.org/2001/XMLSchema-instance' xmlns:d='http://www.w3.org/2001/XMLSchema' xmlns:c='http://schemas.xmlsoap.org/soap/encoding/' xmlns:v='http://schemas.xmlsoap.org/soap/envelope/'> <v:Header /> <v:Body><n0:otpCheckHis id='o0' c:root='1' xmlns:n0='http://otpcheckhis.server.ws.gw.ktis.com/'> <OtpCheckHis i:type='d:anyType'> <sabun i:type='d:string'>%@</sabun> <dvcId i:type='d:string'>%@</dvcId> <platformCd i:type='d:string'>%@</platformCd> <checkMobile i:type='d:string'>%@</checkMobile> <useYn i:type='d:string'>%@</useYn> </OtpCheckHis> </n0:otpCheckHis> </v:Body> </v:Envelope>", [empInfoDic objectForKey:@"sabun"], [empInfoDic objectForKey:@"dvcId"], [empInfoDic objectForKey:@"platformCd"], [empInfoDic objectForKey:@"checkMobile"], [empInfoDic objectForKey:@"useYn"]];
    
    NSString *serviceUrl    = [NSString stringWithFormat:@"%@OtpCheckHis?wsdl",GATEWAY_SERVER_URL];
    NSURL *url = [NSURL URLWithString:serviceUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%d", [soapMessage length]];
    
    [request addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue: @"" forHTTPHeaderField:@"SOAPAction"];
    [request addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    // get response data
    NSError *error;
    NSHTTPURLResponse *response;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error)
        NSLog(@"error:%@", error);
    
    strReturn = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",strReturn);
    
    return strReturn;
}




@end
