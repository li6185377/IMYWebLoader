//
//  IMYWebUtils.h
//  Pods
//
//  Created by ljh on 2017/4/10.
//
//

#import <Foundation/Foundation.h>

@interface IMYWebUtils : NSObject

///模拟网页的 URL 生成规则
+ (NSURL *)URLWithString:(NSString *)urlString baseURL:(NSURL *)baseURL;

+ (BOOL)swizzleClass:(Class)clazz origMethod:(SEL)origSel_ withMethod:(SEL)altSel_;

@end
