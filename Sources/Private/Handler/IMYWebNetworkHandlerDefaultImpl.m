//
//  IMYWebNetworkHandlerDefaultImpl.m
//  Pods
//
//  Created by ljh on 2017/2/28.
//
//

#import "IMYWebNetworkHandlerDefaultImpl.h"

@implementation IMYWebNetworkHandlerDefaultImpl

- (NSURLRequest *)requestWithString:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    if (!url) {
        return nil;
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    request.HTTPMethod = @"GET";
    return request;
}

- (id<IMYWebOperation>)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable, NSURLResponse * _Nullable, NSError * _Nullable))completionHandler
{
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:completionHandler];
    [task resume];
    return (id)task;
}

+ (void)networkRequestThreadEntryPoint
{
    @autoreleasepool {
        [[NSThread currentThread] setName:@"IMYWebNetworkThread"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

- (NSThread *)networkRequestThread
{
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:[IMYWebNetworkHandlerDefaultImpl class] selector:@selector(networkRequestThreadEntryPoint) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

@end
