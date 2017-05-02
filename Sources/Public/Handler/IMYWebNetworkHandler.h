//
//  IMYWebNetworkHandler.h
//  Pods
//
//  Created by ljh on 2017/2/28.
//
//

#import <Foundation/Foundation.h>
#import "IMYWebOperation.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IMYWebNetworkHandler <NSObject>

/// 生成 发起请求的 Request
- (NSURLRequest *)requestWithString:(NSString *)urlString;

/// 发起网络请求
- (id<IMYWebOperation>)dataTaskWithRequest:(NSURLRequest *)request completionHandler:(void (^)(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error))completionHandler;

/// 子线程
- (NSThread *)networkRequestThread;

@end

NS_ASSUME_NONNULL_END
