//
//  IMYWebUtils.m
//  Pods
//
//  Created by ljh on 2017/4/10.
//
//

#import "IMYWebUtils.h"
#import <objc/runtime.h>

@implementation IMYWebUtils

+ (NSURL *)URLWithString:(NSString *)urlString baseURL:(NSURL *)baseURL
{
    if (!urlString.length) {
        return nil;
    }
    if (![urlString containsString:@"://"]) {
        if ([urlString hasPrefix:@"//"]) {
            urlString = [NSString stringWithFormat:@"%@:%@", baseURL.scheme?:@"http", urlString];
        }
        else if ([urlString hasPrefix:@"/"]) {
            urlString = [NSString stringWithFormat:@"%@://%@%@", baseURL.scheme?:@"http", baseURL.host, urlString];
        }
        else {
            urlString = [NSString stringWithFormat:@"%@://%@", baseURL.scheme?:@"http", urlString];
        }
    }
    NSURL *URL = [NSURL URLWithString:urlString];
    if (!URL) {
        urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        URL = [NSURL URLWithString:urlString];
    }
    return URL;
}

+ (BOOL)swizzleClass:(Class)clazz origMethod:(SEL)origSel_ withMethod:(SEL)altSel_
{
    Method origMethod = class_getInstanceMethod(clazz, origSel_);
    if (!origMethod) {
        return NO;
    }
    Method altMethod = class_getInstanceMethod(clazz, altSel_);
    if (!altMethod) {
        return NO;
    }
    
    class_addMethod(clazz,
                    origSel_,
                    class_getMethodImplementation(clazz, origSel_),
                    method_getTypeEncoding(origMethod));
    class_addMethod(clazz,
                    altSel_,
                    class_getMethodImplementation(clazz, altSel_),
                    method_getTypeEncoding(altMethod));
    
    method_exchangeImplementations(class_getInstanceMethod(clazz, origSel_), class_getInstanceMethod(clazz, altSel_));
    
    return YES;
}

@end
