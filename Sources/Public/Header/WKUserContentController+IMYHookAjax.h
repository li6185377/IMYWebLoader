//
//  WKUserContentController+IMYHookAjax.h
//  IMYViewKit
//
//  Created by ljh on 2017/3/24.
//  Copyright © 2017年 IMY. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKUserContentController (IMYHookAjax)

/// 当 WebView 释放的时候，必须手动调用 uninstall 来移除该对象, 不然该对象永远不会释放
- (void)imy_installHookAjax;

/// 卸载 hook ajax
- (void)imy_uninstallHookAjax;

@end
