//
//  NetworkInterface.h
//  NETS.SSO.AppAgent.iOS
//
//  Created by 김상용 on 13. 3. 18..
//  Copyright (c) 2013년 김상용. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthCheck.h"
//ip address 에 필요한 lib
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <sys/types.h>

//get en0 or en1
#include <stdint.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/sockio.h>
#include <netinet/in.h>
#include <netdb.h>
#include <errno.h>
#include <net/ethernet.h>


#include <stdio.h>
#include <stdlib.h>
#include <ifaddrs.h>
#include <string.h>
#include <stdbool.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <arpa/inet.h>
#include <ifaddrs.h>

enum NetworkStatus{
	NotReachable = 1,
	ReachableViaWiFi = 2,
	ReachableViaWWAN = 3
} ;

@interface NetworkInterface : NSObject
{
	BOOL localWiFiRef;
	SCNetworkReachabilityRef reachabilityRef;
}
//mac address and ip address and hwName
void GetIPAddresses();
char* GetHWAddresses();

//ifName
-(NSString *)getIfName:(char *)if_name;
//mac address
-(NSString *)getMacAddress:(char*)macAddress :(char*)ifName;
//ip address
-(NSString *)getIPAddress:(NSString *)mode;

#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"
// 특정 호스트(웹주소)를 넣어서 어느것으로 연결되었는지 체크
+ (NetworkInterface*) reachabilityWithHostName: (NSString*) hostName;

// 특정 아이피 주소로 확인
+ (NetworkInterface*) reachabilityWithAddress: (const struct sockaddr_in*) hostAddress;


// 인터넷 접속 관련 체크
+ (NetworkInterface*) reachabilityForInternetConnection;

//WIFI접속 관련 체크
+ (NetworkInterface*) reachabilityForLocalWiFi;


// 현재 접속에 관하여 실시간적으로 체크
- (BOOL) startNotifier;
- (void) stopNotifier;

// 접속 Status체크
- (enum NetworkStatus) currentReachabilityStatus;

//WWAN may be available, but not active until a connection has been established.
//WiFi may require a connection for VPN on Demand.
- (BOOL) connectionRequired;

// 접속관련을 편하게 사용하게 하기 위해서 만들어넣은것.
+ (BOOL) isInternetReachable;
+ (BOOL) isWebSiteReachable: (NSString *)host;
@end
