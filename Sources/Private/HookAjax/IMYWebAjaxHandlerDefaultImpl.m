//
//  IMYWebAjaxHandlerDefaultImpl.m
//  Pods
//
//  Created by ljh on 2017/4/10.
//
//

#import "IMYWebAjaxHandlerDefaultImpl.h"
#import "IMYWebUtils.h"
#import "IMYWebLoader.h"

@implementation IMYWebAjaxHandlerDefaultImpl

- (void)startWithMethod:(NSString *)method
                    url:(NSString *)urlString
                baseURL:(NSURL *)baseURL
                headers:(NSDictionary *)headers
                   body:(id)body
         completedBlock:(void (^)(NSInteger, NSDictionary * _Nullable, NSString * _Nullable))completedBlock
{
    NSURL *URL = [IMYWebUtils URLWithString:urlString baseURL:baseURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    request.HTTPMethod = method.uppercaseString;
    if ([body isKindOfClass:[NSString class]]) {
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([body isKindOfClass:[NSData class]]) {
        request.HTTPBody = body;
    } else if ([NSJSONSerialization isValidJSONObject:body]) {
        NSError *err = nil;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:&err];
    }
    [request setAllHTTPHeaderFields:headers];
    
    [[IMYWebLoader defaultNetworkHandler] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse *httpResponse = nil;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            httpResponse = (id)response;
        }
        NSDictionary *allHeaderFields = httpResponse.allHeaderFields;
        NSString *responseString = nil;
        if (data.length > 0) {
            responseString = [self responseStringWithData:data charset:allHeaderFields[@"Content-Type"]];
        }
        if (completedBlock) {
            completedBlock(httpResponse.statusCode, allHeaderFields, responseString);
        }
    }];
}

- (NSString *)responseStringWithData:(NSData *)data charset:(NSString *)charset
{
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    /// 对一些国内常见编码进行支持
    charset = charset.lowercaseString;
    if ([charset containsString:@"gb2312"]) {
        stringEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    }
    NSString *responseString = [[NSString alloc] initWithData:data encoding:stringEncoding];
    return responseString;
}

@end
