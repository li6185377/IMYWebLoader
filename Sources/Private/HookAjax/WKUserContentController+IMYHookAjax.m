//
//  WKUserContentController+IMYHookAjax.m
//  IMYViewKit
//
//  Created by ljh on 2017/3/24.
//  Copyright © 2017年 IMY. All rights reserved.
//

#import "WKUserContentController+IMYHookAjax.h"
#import <objc/runtime.h>
#import "IMYWebUtils.h"
#import "IMYWebLoader.h"

@interface _IMYWKHookAjaxHandler : NSObject <WKScriptMessageHandler>
@property (nonatomic, weak) WKWebView *webView;
@end

@implementation _IMYWKHookAjaxHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    self.webView = message.webView;
    [self requestWithBody:message.body];
}

- (void)requestWithBody:(NSDictionary *)body
{
    id requestID = body[@"id"];
    NSString *method = body[@"method"];
    id requestData = body[@"data"];
    NSDictionary *requestHeaders = body[@"headers"];
    NSString *urlString = body[@"url"];
    
    [[IMYWebLoader defaultAjaxHandler] startWithMethod:method
                                                   url:urlString
                                               baseURL:self.webView.URL
                                               headers:requestHeaders
                                                  body:requestData
                                        completedBlock:^(NSInteger httpCode, NSDictionary * _Nullable headers, NSString * _Nullable data) {
                                            [self requestCallback:requestID httpCode:httpCode headers:headers data:data];
                                        }];
}

- (void)requestCallback:(id)requestId httpCode:(NSInteger)httpCode headers:(NSDictionary *)headers data:(NSString *)data
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"status"] = @(httpCode);
    dict[@"headers"] = headers;
    if (data.length > 0) {
        dict[@"data"] = data;
    }
    NSString *jsonString = nil;
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    if (jsonData.length > 0) {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSString *jsScript = [NSString stringWithFormat:@"window.imy_realxhr_callback(%@, %@);", requestId, jsonString?:@"{}"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webView evaluateJavaScript:jsScript completionHandler:^(id result, NSError *error) {
            
        }];
    });
  
}

@end

@implementation WKUserContentController (IMYHookAjax)

static const void *IMYHookAjaxKey = &IMYHookAjaxKey;
- (void)imy_uninstallHookAjax
{
    [self removeScriptMessageHandlerForName:@"IMYXHR"];
    objc_setAssociatedObject(self, IMYHookAjaxKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)imy_installHookAjax
{
    BOOL installed = [objc_getAssociatedObject(self, IMYHookAjaxKey) boolValue];
    if (installed) {
        return;
    }
    objc_setAssociatedObject(self, IMYHookAjaxKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    _IMYWKHookAjaxHandler *handler = [_IMYWKHookAjaxHandler new];
    [self addScriptMessageHandler:handler name:@"IMYXHR"];
    
    // add wk hook
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"imywk_hookajax" ofType:@"js"];
        NSString *jsScript = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsScript injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [self addUserScript:userScript];
    }
}

@end
