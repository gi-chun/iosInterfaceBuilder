//
//  XmlParser.h
//  KtisOn
//
//  Created by Hyuck on 3/10/14.
//
//

#import <Foundation/Foundation.h>

@interface XmlParser : NSObject <NSXMLParserDelegate>

- (NSArray *)getParsedData:(NSData *)xmlDic;

@end
