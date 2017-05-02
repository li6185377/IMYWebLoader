//
//  IMYWebCacheHandler.h
//  Pods
//
//  Created by ljh on 2017/2/27.
//
//

#import <Foundation/Foundation.h>
#import "IMYWebData.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IMYWebCacheHandler <NSObject>

- (NSString *)cacheKeyForRequest:(NSURLRequest *)request;

- (nullable IMYWebData *)dataForKey:(NSString *)key;
- (void)setData:(nullable IMYWebData *)data forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
