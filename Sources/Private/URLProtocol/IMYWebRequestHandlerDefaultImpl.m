//
//  IMYWebRequestHandlerDefaultImpl.m
//  Pods
//
//  Created by ljh on 2017/4/11.
//
//

#import "IMYWebRequestHandlerDefaultImpl.h"
#import "IMYWebLoader.h"

static NSString * const IMYWebDXP = @"IMYWebDXP";

@interface IMYWebRequestHandlerDefaultImpl ()
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, weak) id<IMYWebOperation> operation;
@end

@implementation IMYWebRequestHandlerDefaultImpl

+ (BOOL)shouldHookWithRequest:(NSURLRequest *)request
{
    ///只缓存get请求
    if (request.HTTPMethod && ![request.HTTPMethod.uppercaseString isEqualToString:@"GET"]) {
        return NO;
    }
    
    ///通过UA 来判断是否UIWebView发起的请求
    NSString *UA = [request valueForHTTPHeaderField:@"User-Agent"];
    if ([UA containsString:@" AppleWebKit/"] == NO) {
        return NO;
    }
    
    /// 不缓存 ajax 请求
    NSString *hasAjax = [request valueForHTTPHeaderField:@"X-Requested-With"];
    if (hasAjax != nil) {
        return NO;
    }
    
    NSString *pathExtension = [request.URL.absoluteString componentsSeparatedByString:@"?"].firstObject.pathExtension.lowercaseString;
    NSArray *validExtension = @[ @"jpg", @"jpeg", @"gif", @"png", @"webp", @"bmp", @"tif", @"ico", @"js", @"css", @"html", @"htm", @"ttf", @"svg"];
    if (pathExtension && [validExtension containsObject:pathExtension]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)cancelHookWithRequest:(NSURLRequest *)request
{
    ///已被拦截
    if ([request valueForHTTPHeaderField:IMYWebDXP]) {
        return YES;
    }
    return NO;
}

+ (id<IMYWebRequestHandler>)requestHandlerWithRequest:(NSURLRequest *)request
{
    IMYWebRequestHandlerDefaultImpl *handler = [IMYWebRequestHandlerDefaultImpl new];
    handler.request = request;
    return handler;
}

- (void)startLoadingWithDelegate:(id<IMYWebRequestDelegate>)delegate
{
    NSString *cacheKey = [[IMYWebLoader defaultCacheHandler] cacheKeyForRequest:self.request];
    IMYWebData *webData = [[IMYWebLoader defaultCacheHandler] dataForKey:cacheKey];
    if (webData) {
        [delegate request:self didReceiveResponse:webData.response];
        [delegate request:self didReceiveData:webData.data];
        [delegate requestDidFinishLoading:self];
        return;
    }
    
    NSThread *thread = [NSThread currentThread];
    
    NSMutableURLRequest *request = [self.request mutableCopy];
    [request setValue:@"1" forHTTPHeaderField:IMYWebDXP];
    
    __weak id wself = self;
    self.operation = [[IMYWebLoader defaultNetworkHandler] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        __strong IMYWebRequestHandlerDefaultImpl *self = wself;
        [self performSelector:@selector(performBlock:) onThread:thread withObject:^{
            __strong IMYWebRequestHandlerDefaultImpl *self = wself;
            if (response) {
                [delegate request:self didReceiveResponse:response];
            }
            if (error) {
                [delegate request:self didFailWithError:error];
            } else {
                [delegate request:self didReceiveData:data];
                [delegate requestDidFinishLoading:self];
                
                IMYWebData *webData = [IMYWebData new];
                webData.data = data;
                webData.response = response;
                webData.request = self.request;
                [[IMYWebLoader defaultCacheHandler] setData:webData forKey:cacheKey];
            }
        } waitUntilDone:NO];
    }];
}

- (void)performBlock:(dispatch_block_t)block
{
    if (block) {
        block();
    }
}

- (void)stopLoading
{
    [self.operation cancel];
}

@end
