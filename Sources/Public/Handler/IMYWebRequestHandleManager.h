//
//  IMYWebRequestHandleManager.h
//  MeetYou
//
//  Created by ljh on 2017/2/27.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IMYWebRequestHandler,IMYWebCacheHandler;

@protocol IMYWebRequestDelegate <NSObject>
@required

- (void)request:(id<IMYWebRequestHandler>)request wasRedirectedToRequest:(NSURLRequest *)redirectRequest redirectResponse:(nullable NSURLResponse *)redirectResponse;

- (void)request:(id<IMYWebRequestHandler>)request didReceiveResponse:(NSURLResponse *)response;

- (void)request:(id<IMYWebRequestHandler>)request didReceiveData:(NSData *)data;

- (void)requestDidFinishLoading:(id<IMYWebRequestHandler>)request;

- (void)request:(id<IMYWebRequestHandler>)request didFailWithError:(NSError *)error;

@end

@protocol IMYWebRequestHandler <NSObject>
@required

/// 是否要拦截该 request
+ (BOOL)shouldHookWithRequest:(NSURLRequest *)request;

/// 取消该 Request 的拦截，只要有一个 class 返回 YES，则不拦截该请求
+ (BOOL)cancelHookWithRequest:(NSURLRequest *)request;

/// 根据 Request 返回具体的请求实例, 会使用第一个返回的请求对象
+ (nullable id<IMYWebRequestHandler>)requestHandlerWithRequest:(NSURLRequest *)request;

/// 开始加载
- (void)startLoadingWithDelegate:(id<IMYWebRequestDelegate>)delegate;

/// 停止加载
- (void)stopLoading;

@optional

/// 实现后 会用返回的缓存控制器 ， default：[IMYWebLoader defaultCacheHandler]
+ (id<IMYWebCacheHandler>)cacheHandler;

/// 拦截器优先级，默认 0，越大排序越前
+ (NSInteger)priority;

@end

@protocol IMYWebRequestHandleManager <NSObject>

- (void)addRequestHandlerClass:(Class<IMYWebRequestHandler>)handlerClass;

- (void)removeRequestHandlerClass:(Class<IMYWebRequestHandler>)handlerClass;

- (NSArray<Class<IMYWebRequestHandler>> *)requestHandlerClass;

///是否开启 WKWebView Custom Protocol 拦截 http、https。 default：YES
@property (nonatomic, assign) BOOL enableWKCustomProtocol;

@end

NS_ASSUME_NONNULL_END
