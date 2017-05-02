//
//  IMYWebPrefetcher.h
//  Pods
//
//  Created by ljh on 2017/2/27.
//
//

#import <Foundation/Foundation.h>
#import "IMYWebDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMYWebLoader : NSObject

+ (id)handlerForProtocol:(Protocol *)protocol;

+ (void)setHandlerClass:(Class)handlerClass forProtocol:(Protocol *)protocol;

@end

@interface IMYWebLoader (Guest)

///请求拦截控制器
@property (class, readonly, nonatomic) id<IMYWebRequestHandleManager> defaultRequestManager;
///缓存控制器
@property (class, readonly, nonatomic) id<IMYWebCacheHandler> defaultCacheHandler;
///预加载控制器
@property (class, readonly, nonatomic) id<IMYWebPrefetchHandler> defaultPrefetchHandler;
///数据请求
@property (class, readonly, nonatomic) id<IMYWebNetworkHandler> defaultNetworkHandler;
/// Ajax 需要手动 执行 imy_installHookAjax，目前需要针对 WKWebView
@property (class, readonly, nonatomic) id<IMYWebAjaxHandler> defaultAjaxHandler;

@end

NS_ASSUME_NONNULL_END
