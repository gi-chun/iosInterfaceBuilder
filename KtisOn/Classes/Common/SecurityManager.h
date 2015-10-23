//
//  SecurityManager.h
//  KtisOn
//
//  Created by Hyuck on 2/25/14.
//
//

#import <Foundation/Foundation.h>

@interface NSData(NSDataSeed)
+ (NSData *)encodeData:(NSData *)inputData;
+ (NSData *)decodeData:(NSData *)inputData;
+ (BOOL)encrypion:(unsigned char*)input andInputSize:(int)inputSize MallocOutput:(unsigned char**)output andOutputSize:(int*)outputSize;
+ (BOOL)descryption:(unsigned char*)input andInputSize:(int)inputSize MallocOutput:(unsigned char**)output andOutputSize:(int*)outputSize;
+ (NSData *) dataWithBase64EncodedString:(NSString *) string;
- (id) initWithBase64EncodedString:(NSString *) string;
- (NSString *) base64Encoding;
- (NSString *) base64EncodingWithLineLength:(NSUInteger) lineLength;
- (BOOL) hasPrefix:(NSData *) prefix;
- (BOOL) hasPrefixBytes:(const void *) prefix length:(NSUInteger) length;
- (BOOL) hasSuffix:(NSData *) suffix;
- (BOOL) hasSuffixBytes:(const void *) suffix length:(NSUInteger) length;
@end


@interface NSString(NSStringSeed)
+ (NSString *)encodeString:(NSString *)inputData;
+ (NSString *)decodeString:(NSString *)inputData;
@end


@interface SecurityManager : NSObject
@end