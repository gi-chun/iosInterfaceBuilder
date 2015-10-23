//
//  CrackChecker.m
//  ktis Mobile
//
//  Created by Hyuck on 1/27/14.
//
//

#import "CrackChecker.h"

@implementation CrackChecker

- (BOOL)isCracked
{
    // 1 API 호출 기반 탐지
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"])
    {
        NSLog(@"existed cydia");
        return YES;
    }
    
    // 2 시스템 호출 기반 탐지
    if(open("/Applications/Cydia.app" ,O_RDONLY) != -1)
    {
        // Jailbroken
        return YES;
    }
    else
    {
        // not Jailbroken
        return NO;
    }
    
    // 3 SVC 호출 기반 탐지
    char *str = "/Applications/Cydia.app";
    int flag=0;
    __asm __volatile("mov r0, %0" : "=r"(str)); // path
    __asm __volatile("mov r1, #0");             // mode
    __asm __volatile("mov r12, #5");            // open()
    __asm __volatile("svc 0x00000080");
    __asm __volatile("bcc 0x5");                // jmp if carry clear
    __asm __volatile("mov r0, 0x0");
    __asm __volatile("b 0x3");
    __asm __volatile("mov r0, 0x1");
    __asm __volatile("mov r0, %0" : "=r"(flag));
    return flag;
}

@end
