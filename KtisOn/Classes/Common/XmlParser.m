//
//  XmlParser.m
//  KtisOn
//
//  Created by Hyuck on 3/10/14.
//
//

#import "XmlParser.h"

@interface XmlParser()
{
    NSMutableDictionary *_dataDictionary;
    NSMutableArray      *_elementArray;
    NSString            *_parsedString;
    NSMutableString     *_tmpString;
}

@end

@implementation XmlParser

#pragma mark - XML Parsing
- (NSArray *)getParsedData:(NSData *)xmlDic
{
    _tmpString = [[NSMutableString alloc] initWithString:@""];
    NSString *xml = [[NSString alloc] initWithData:xmlDic encoding:NSUTF8StringEncoding];
    NSLog(@"[XML] %@", xml);
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:xmlDic];
    [xmlParser setDelegate:self];
    [xmlParser setShouldResolveExternalEntities:YES];
    
    _elementArray = [NSMutableArray array];
    
    return ([xmlParser parse]) ? _elementArray : nil;
}


#pragma mark - NSXML Parser Delegate
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"title"]) // 롤링 공지 처리
        [_tmpString setString:@""];
    
    if ([elementName isEqualToString:@"return"])
    {
        _dataDictionary = [NSMutableDictionary dictionary];
    }
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    _parsedString = string;
    
    [_tmpString appendString:string];
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    // 롤링 공지 처리
    if ([elementName isEqualToString:@"title"])
    {
        _parsedString = [NSString stringWithFormat:@"%@", _tmpString];
        [_tmpString setString:@""];
    }
    
    if ([elementName isEqualToString:@"return"])
    {
        // 결과값이 true, false등의 노드 네임이 없는 하나뿐인 결과에 대한 처리
        if ([[_dataDictionary allKeys] count] < 1) {
            [_dataDictionary setObject:_parsedString forKey:elementName];
            [_elementArray addObject:_dataDictionary];
        }
        else
        {
            [_elementArray addObject:_dataDictionary];
        }
    }
    else
    {
        // 의미있는 내용만 추가
        if ([elementName rangeOfString:@":"].length < 1)
            [_dataDictionary setObject:_parsedString forKey:elementName];
    }
}

@end
