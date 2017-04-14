//
//  NSObject+WKCustomProtocolLoader.m
//  Pods
//
//  Created by ljh on 2017/4/10.
//
//

#import "NSObject+WKCustomProtocolLoader.h"
#import "IMYWebLoader.h"
#import "IMYWebUtils.h"

@interface _IMYWKProtocolLoader : NSObject
@property (nonatomic, weak) id wkloader;
@property (nonatomic, strong) NSURLRequest *request;
@end

@implementation _IMYWKProtocolLoader

@end

/// 原始 WKCustomProtocolLoader 是在主线程进行网络请求，这边进行 hook 改为在子线程请求
@implementation NSObject (WKCustomProtocolLoader)

+ (void)load
{
    Class clazz = NSClassFromString([NSString stringWithFormat:@"%@%@%@",@"WK",@"Custom",@"ProtocolLoader"]);
    SEL swizzleSEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@",@"initWithCustomProtocol",@"ManagerProxy:customProtocolID",@":request:connection:"]);
    [IMYWebUtils swizzleClass:clazz origMethod:swizzleSEL withMethod:@selector(wkloader_initWithProtocolManager:protocolID:request:connection:)];
    
    SEL swizzleLegacySEL = NSSelectorFromString([NSString stringWithFormat:@"%@%@",@"initWithLegacyCustomProtocolManagerProxy",@":customProtocolID:request:"]);
    [IMYWebUtils swizzleClass:clazz origMethod:swizzleLegacySEL withMethod:@selector(wkloader_initWithLegacyCustomProtocolManagerProxy:customProtocolID:request:)];
}

- (id)wkloader_initWithLegacyCustomProtocolManagerProxy:(void*)customProtocolManagerProxy customProtocolID:(uint64_t)customProtocolID request:(NSURLRequest *)request
{
    id wkloader = [self wkloader_initWithLegacyCustomProtocolManagerProxy:customProtocolManagerProxy customProtocolID:customProtocolID request:[NSURLRequest new]];
    [NSObject wkloader_hookWKLoader:wkloader request:request];
    return wkloader;
}

- (id)wkloader_initWithProtocolManager:(void *)protocolManager protocolID:(uint64_t)protocolID request:(NSURLRequest *)request connection:(void *)connection
{
    id wkloader = [self wkloader_initWithProtocolManager:protocolManager protocolID:protocolID request:[NSURLRequest new] connection:connection];
    [NSObject wkloader_hookWKLoader:wkloader request:request];
    return wkloader;
}

+ (void)wkloader_hookWKLoader:(id)wkloader request:(NSURLRequest *)request
{
    NSURLConnection *urlConnection = [wkloader valueForKey:@"_urlConnection"];
    [urlConnection setValue:nil forKeyPath:@"_internal._delegate"];
    [urlConnection unscheduleFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [urlConnection cancel];
    
    _IMYWKProtocolLoader *weakObj = [_IMYWKProtocolLoader new];
    weakObj.wkloader = wkloader;
    weakObj.request = request;
    
    [self performSelector:@selector(wkloader_startConnection:) onThread:[[IMYWebLoader defaultNetworkHandler] networkRequestThread] withObject:weakObj waitUntilDone:NO];
}

+ (void)wkloader_startConnection:(_IMYWKProtocolLoader *)weakObj
{
    id wkloader = weakObj.wkloader;
    if (!wkloader) {
        return;
    }
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:weakObj.request delegate:wkloader startImmediately:NO];
    [urlConnection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [urlConnection start];
    [wkloader setValue:urlConnection forKey:@"_urlConnection"];
}

@end
