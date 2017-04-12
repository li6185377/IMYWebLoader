//
//  IMYWebAjaxHandler.h
//  Pods
//
//  Created by ljh on 2017/4/10.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IMYWebAjaxHandler <NSObject>

- (void)startWithMethod:(NSString *)method
                    url:(NSString *)urlString
                baseURL:(nullable NSURL *)baseURL
                headers:(nullable NSDictionary *)headers
                   body:(nullable id)body
         completedBlock:(void (^)(NSInteger httpCode, NSDictionary * _Nullable headers, NSString * _Nullable data))completedBlock;

@end

NS_ASSUME_NONNULL_END
