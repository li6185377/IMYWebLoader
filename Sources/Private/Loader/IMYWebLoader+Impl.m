//
//  IMYWebLoader+Impl.m
//  Pods
//
//  Created by ljh on 2017/2/27.
//
//

#import "IMYWebLoader+Impl.h"
#import <pthread.h>

#import "IMYWebCacheHandlerDefaultImpl.h"
#import "IMYWebNetworkHandlerDefaultImpl.h"
#import "IMYWebPrefetchHandlerDefaultImpl.h"
#import "IMYWebAjaxHandlerDefaultImpl.h"
#import "IMYWebRequestHandleManagerDefaultImpl.h"

static pthread_mutex_t _lock;
static NSMutableDictionary *_instanceMap = nil;
static NSMutableDictionary *_classMap = nil;

@implementation IMYWebLoader

+ (void)setHandlerClass:(Class)handlerClass forProtocol:(Protocol *)protocol
{
    if (!handlerClass || !protocol) {
        NSAssert(NO, @"handlerClass/protocol can't nil !");
        return;
    }
    NSString *key = NSStringFromProtocol(protocol);
    pthread_mutex_lock(&_lock);
    [_instanceMap removeObjectForKey:key];
    [_classMap setObject:handlerClass forKey:key];
    pthread_mutex_unlock(&_lock);
}

+ (id)handlerForProtocol:(Protocol *)protocol
{
    if (!protocol) {
        NSAssert(NO, @"protocol can't nil !");
        return nil;
    }
    NSString *key = NSStringFromProtocol(protocol);
    pthread_mutex_lock(&_lock);
    id handler = [_instanceMap objectForKey:key];
    if (!handler) {
        Class clazz = [_classMap objectForKey:key];
        handler = [[clazz alloc] init];
        if (handler) {
            [_instanceMap setObject:handler forKey:key];
        } else {
            NSAssert(NO, @"not found handler with %@ protocol !", key);
        }
    }
    pthread_mutex_unlock(&_lock);
    return handler;
}

+ (void)initialize
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pthread_mutex_init(&_lock, NULL);
        _instanceMap = [NSMutableDictionary dictionary];
        _classMap = [NSMutableDictionary dictionary];
        
        [self setHandlerClass:[IMYWebCacheHandlerDefaultImpl class] forProtocol:@protocol(IMYWebCacheHandler)];
        [self setHandlerClass:[IMYWebPrefetchHandlerDefaultImpl class] forProtocol:@protocol(IMYWebPrefetchHandler)];
        [self setHandlerClass:[IMYWebNetworkHandlerDefaultImpl class] forProtocol:@protocol(IMYWebNetworkHandler)];
        [self setHandlerClass:[IMYWebAjaxHandlerDefaultImpl class] forProtocol:@protocol(IMYWebAjaxHandler)];
        [self setHandlerClass:[IMYWebRequestHandleManagerDefaultImpl class] forProtocol:@protocol(IMYWebRequestHandleManager)];
    });
}

@end

@implementation IMYWebLoader (Guest)

+ (id<IMYWebRequestHandleManager>)defaultRequestManager
{
    return [self handlerForProtocol:@protocol(IMYWebRequestHandleManager)];
}

+ (id<IMYWebAjaxHandler>)defaultAjaxHandler
{
    return [self handlerForProtocol:@protocol(IMYWebAjaxHandler)];
}

+ (id<IMYWebCacheHandler>)defaultCacheHandler
{
    return [self handlerForProtocol:@protocol(IMYWebCacheHandler)];
}

+ (id<IMYWebNetworkHandler>)defaultNetworkHandler
{
    return [self handlerForProtocol:@protocol(IMYWebNetworkHandler)];
}

+ (id<IMYWebPrefetchHandler>)defaultPrefetchHandler
{
    return [self handlerForProtocol:@protocol(IMYWebPrefetchHandler)];
}

@end
