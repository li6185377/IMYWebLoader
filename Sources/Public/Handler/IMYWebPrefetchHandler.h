//
//  IMYWebPrefetchHandler.h
//  Pods
//
//  Created by ljh on 2017/2/28.
//
//

#import <Foundation/Foundation.h>
#import "IMYWebOperation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IMYWebPrefetcherProtocol <IMYWebOperation>

@property (nonatomic, copy) NSString *webUrl;

@property (nonatomic, assign, readonly, getter=isComplated) BOOL complated;

@end

@protocol IMYWebPrefetchHandler <NSObject>

///一次生命周期内 对同一个 url，只会预加载一次，除非已经被移除了
- (id<IMYWebPrefetcherProtocol>)prefetchWebUrl:(NSString *)webUrl;

///取消全部预加载操作
- (void)cancelAllPrefetcherLoading;

///移除预加载对象
- (void)removePrefetcherForWebUrl:(NSString *)webUrl;

@end

NS_ASSUME_NONNULL_END
