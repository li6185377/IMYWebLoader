//
//  NSObject+WKCustomProtocolLoader.h
//  Pods
//
//  Created by ljh on 2017/4/10.
//
//

#import <Foundation/Foundation.h>

/// 原始 WKCustomProtocolLoader 是在主线程进行网络请求，这边进行 hook 改为在子线程请求
@interface NSObject (WKCustomProtocolLoader)

@end
