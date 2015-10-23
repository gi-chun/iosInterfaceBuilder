//
//  Defines.h
//  KtisOn
//
//  Created by Hyuck on 3/3/14.
//
//




#ifdef DEV_MODE

#pragma mark - #######DEV#######
#pragma mark - Menu PList
static NSString *MENU_PLIST = @"menuListDev";

#pragma mark - Gateway
static NSString *GATEWAY_SERVER_URL     = @"https://mgwdev.ktis.co.kr/gw/ws/";


#pragma mark - Services
static NSString *REG_PUSH_ID_Namespace  = @"http://regid.push.server.ws.gw.ktis.com";           // 서버에 푸쉬를 위한 디바이스 토큰 등록
static NSString *PUSH_SETTING_Namespace = @"http://setting.push.server.ws.gw.ktis.com";         // 푸쉬 설정
static NSString *APP_UPDATE_Namespace   = @"http://updateapp.server.ws.gw.ktis.com";            // 업데이트 정보 조회
static NSString *NOTICE_LIST_Namespace  = @"http://noti.server.ws.gw.ktis.com";                 // 공지사항 조회
static NSString *BADGE_COUNT_Namespace  = @"http://badge.server.ws.gw.ktis.com";                // 뱃지 카운트 조회
static NSString *MENU_LIST_Namespace    = @"http://servicepermission.server.ws.gw.ktis.com";    // 권한별 메뉴 조회
static NSString *ACCESS_LOG_Namespace   = @"http://logging.server.ws.gw.ktis.com";              // 로깅
static NSString *LOG_OUT_PROG_Namespace = @"http://logout.server.ws.gw.ktis.com";               // 로그아웃시 처리
static NSString *OTP_ISSHOW_Namespace = @"http://otpcheckusr.server.ws.gw.ktis.com";
static NSString *OTP_SAVE_Namespace = @"http://otpcheckhis.server.ws.gw.ktis.com";

static NSString *OTP_SEND_SERVER_URL     = @"https://sso.ktis.co.kr:8443/nsso-authweb/Otp/sendotp.do";
static NSString *OTP_VALIDATE_SERVER_URL     = @"https://sso.ktis.co.kr:8443/nsso-authweb/Otp/validateotp.do";


#pragma mark - 디바이스 정보
static NSString *PACKAGE_NAME   = @"com.ktis.ktison";   // 패키지 명
static NSString *PLATFORM_CODE  = @"PT02";              // 플랫폼 코드


#pragma mark - 접속 로그 타입
static NSString *LOG_TYPE_LOGIN     = @"LT01";  // 접속 로그
static NSString *LOG_TYPE_SERVICE   = @"LT02";  // 서비스 접근 로그


#pragma mark - URLs
static NSString *SSO_AUTH_SITE      = @"https://ssodev.ktis.co.kr:8943/nsso-authweb/logon.do?";                 // SSO 인증 서버
static NSString *NOTICE_URL         = @"https://mhrdev.ktis.co.kr?directpage_type=portal_notice&S_NOTI_NO=";    // 메인의 하단 공지사항 링크
static NSString *APP_STORE_URL      = @"https://appdev.ktis.co.kr/app/";                                        // 앱스토어
static NSString *UPDATE_FILE_PATH   = @"https://appdev.ktis.co.kr/app/files";                                   // 업데이트 경로
static NSString *SEND_MAIL_URL       = @"https://maildev.ktis.co.kr/mobile/mail/write_sso.do?toaddr=";          // 메일 쓰기 url
//static NSString *SEND_MAIL_URL       = @"https://mmail.ktis.co.kr/mobile/mail/write_sso.do?toaddr=";          // 메일 쓰기 url

#pragma mark - 푸쉬 수신 설정
static NSString *ALLOW_PUSH_HR          = @"push_hr";
static NSString *ALLOW_PUSH_DECISION    = @"push_decision";
static NSString *ALLOW_PUSH_MAIL        = @"push_mail";
static NSString *ALLOW_PUSH_SAILS       = @"push_sails";
static NSString *ALLOW_PUSH_CORPMAP     = @"push_corpmap";
static NSString *ALLOW_PUSH_NOTICE      = @"push_notice";

#pragma mark - 푸쉬되는 url을 담는 User Defaults
static NSString *RECEIVED_PUSH_URL      = @"push_notice_url";

#pragma mark - Alert Messages
static NSString *LOGIN_FAILED_BLOCK_MESSAGE     = @"5회 이상 인증에 실패 하였습니다.\n해당 기기의 인증을 초기화 합니다.";
static NSString *PIN_LOGIN_FAILED_BLOCK_MESSAGE = @"3회 이상 인증에 실패 하였습니다\n재설치 후 사용해 주시기 바랍니다";
static NSString *PIN_INPUT_BLANK                = @"PIN 번호를 입력해 주세요";
static NSString *PIN_INPUT_NOT_MATCH            = @"PIN 번호가 일치 하지 않습니다";
static NSString *TERMS_AGREE                    = @"이용안내에 동의하지 않을 시\nktis on 사용이 불가합니다.";
static NSString *PASS_INPUT_ERROR_1             = @"8자 이상 입력하세요";
static NSString *PASS_INPUT_ERROR_2             = @"10자 이상 입력하세요";
static NSString *APP_UPDATE_RECOMMEND_MESSAGE   = @"업데이트 후 사용가능 합니다\n앱을 종료 하시겠습니까?";
static NSString *OTP_INPUT_BLANK                = @"OTP 번호를 입력해 주세요";
static NSString *OTP_INPUT_LENGTH               = @"인증코드는 6자리 입니다.";
static NSString *OTP_INPUT_NUMBER               = @"숫자만 입력 가능합니다.";
static NSString *OTP_INPUT_NOT_MATCH            = @"입력하신 인증번호가 올바르지 않습니다. 최대 5회까지 입력 가능합니다. (%d회 인증 실패)";
static NSString *OTP_LOGIN_FAILED_LIMIT         = @"5회 이상 인증에 실패 하였습니다. 정보보호를 위해 ktisON 사용이 제한됩니다.";
static NSString *OTP_LIMIT         = @"사용이 제한 된 기기입니다.\n 관리자에게 문의하세요.";



#else

#pragma mark - #######REAL#######
#pragma mark - Menu PList
static NSString *MENU_PLIST = @"menuList";


#pragma mark - Gateway
static NSString *GATEWAY_SERVER_URL     = @"https://mgw.ktis.co.kr/gw/ws/";

#pragma mark - Services
static NSString *REG_PUSH_ID_Namespace  = @"http://regid.push.server.ws.gw.ktis.com";           // 서버에 푸쉬를 위한 디바이스 토큰 등록
static NSString *PUSH_SETTING_Namespace = @"http://setting.push.server.ws.gw.ktis.com";         // 푸쉬 설정
static NSString *APP_UPDATE_Namespace   = @"http://updateapp.server.ws.gw.ktis.com";            // 업데이트 정보 조회
static NSString *NOTICE_LIST_Namespace  = @"http://noti.server.ws.gw.ktis.com";                 // 공지사항 조회
static NSString *BADGE_COUNT_Namespace  = @"http://badge.server.ws.gw.ktis.com";                // 뱃지 카운트 조회
static NSString *MENU_LIST_Namespace    = @"http://servicepermission.server.ws.gw.ktis.com";    // 권한별 메뉴 조회
static NSString *ACCESS_LOG_Namespace   = @"http://logging.server.ws.gw.ktis.com";              // 로깅
static NSString *LOG_OUT_PROG_Namespace = @"http://logout.server.ws.gw.ktis.com";               // 로그아웃시 처리
static NSString *OTP_ISSHOW_Namespace = @"http://otpcheckusr.server.ws.gw.ktis.com";
static NSString *OTP_SAVE_Namespace = @"http://otpcheckhis.server.ws.gw.ktis.com";

static NSString *OTP_SEND_SERVER_URL     = @"https://sso.ktis.co.kr:8443/nsso-authweb/Otp/sendotp.do";
static NSString *OTP_VALIDATE_SERVER_URL     = @"https://sso.ktis.co.kr:8443/nsso-authweb/Otp/validateotp.do";


#pragma mark - 디바이스 정보
static NSString *PACKAGE_NAME   = @"com.ktis.ktison";   // 패키지 명
static NSString *PLATFORM_CODE  = @"PT02";              // 플랫폼 코드


#pragma mark - 접속 로그 타입
static NSString *LOG_TYPE_LOGIN     = @"LT01";  // 접속 로그
static NSString *LOG_TYPE_SERVICE   = @"LT02";  // 서비스 접근 로그


#pragma mark - URLs
static NSString *SSO_AUTH_SITE      = @"https://sso.ktis.co.kr:8443/nsso-authweb/logon.do?";                // SSO 인증 서버
static NSString *NOTICE_URL         = @"https://mhr.ktis.co.kr?directpage_type=portal_notice&S_NOTI_NO=";   // 하단 공지 링크
static NSString *APP_STORE_URL      = @"https://app.ktis.co.kr/app/";                                       // 앱스토어
static NSString *UPDATE_FILE_PATH   = @"https://app.ktis.co.kr/app/files";                                  // 업데이트 경로
//static NSString *SEND_MAIL_URL      = @"https://mail.ktis.co.kr/mobile/mail/write_sso.do?toaddr=";          // 메일 쓰기 url
static NSString *SEND_MAIL_URL      = @"https://mmail.ktis.co.kr/mobile/mail/write_sso.do?toaddr=";          // 메일 쓰기 url

#pragma mark - 푸쉬 수신 설정
static NSString *ALLOW_PUSH_HR          = @"push_hr";
static NSString *ALLOW_PUSH_DECISION    = @"push_decision";
static NSString *ALLOW_PUSH_MAIL        = @"push_mail";
static NSString *ALLOW_PUSH_SAILS       = @"push_sails";
static NSString *ALLOW_PUSH_CORPMAP     = @"push_corpmap";
static NSString *ALLOW_PUSH_NOTICE      = @"push_notice";

#pragma mark - 푸쉬되는 url을 담는 User Defaults
static NSString *RECEIVED_PUSH_URL      = @"push_notice_url";

#pragma mark - Alert Messages
static NSString *LOGIN_FAILED_BLOCK_MESSAGE     = @"5회 이상 인증에 실패 하였습니다.\n해당 기기의 인증을 초기화 합니다.";
static NSString *PIN_LOGIN_FAILED_BLOCK_MESSAGE = @"3회 이상 인증에 실패 하였습니다\n재설치 후 사용해 주시기 바랍니다";
static NSString *PIN_INPUT_BLANK                = @"PIN 번호를 입력해 주세요";
static NSString *PIN_INPUT_NOT_MATCH            = @"PIN 번호가 일치 하지 않습니다";
static NSString *TERMS_AGREE                    = @"이용안내에 동의하지 않을 시\nktis on 사용이 불가합니다.";
static NSString *PASS_INPUT_ERROR_1             = @"8자 이상 입력하세요";
static NSString *PASS_INPUT_ERROR_2             = @"10자 이상 입력하세요";
static NSString *APP_UPDATE_RECOMMEND_MESSAGE   = @"업데이트 후 사용가능 합니다\n앱을 종료 하시겠습니까?";
static NSString *OTP_INPUT_BLANK                = @"OTP 번호를 입력해 주세요";
static NSString *OTP_INPUT_LENGTH               = @"인증코드는 6자리 입니다.";
static NSString *OTP_INPUT_NUMBER               = @"숫자만 입력 가능합니다.";
static NSString *OTP_INPUT_NOT_MATCH            = @"입력하신 인증번호가 올바르지 않습니다. 최대 5회까지 입력 가능합니다. (%d회 인증 실패)";
static NSString *OTP_LOGIN_FAILED_LIMIT         = @"5회 이상 인증에 실패 하였습니다. 정보보호를 위해 ktisON 사용이 제한됩니다.";
static NSString *OTP_LIMIT         = @"사용이 제한 된 기기입니다.\n 관리자에게 문의하세요.";

#endif
