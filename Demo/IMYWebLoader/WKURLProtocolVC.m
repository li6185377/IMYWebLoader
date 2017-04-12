//
//  WKURLProtocolVC.m
//  IMYWebLoader
//
//  Created by ljh on 2017/4/10.
//  Copyright © 2017年 meetyou. All rights reserved.
//

#import "WKURLProtocolVC.h"
#import <WebKit/WebKit.h>
#import <IMYWebLoader.h>

@interface WKURLProtocolVC ()
@property (nonatomic, weak) WKWebView *webView;
@end

@implementation WKURLProtocolVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [[WKUserContentController alloc] init];
    
    if (self.testAjax) {
        [configuration.userContentController imy_installHookAjax];
    }
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:configuration];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:webView];
    self.webView = webView;
    
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]]];
}

- (void)dealloc
{
    [self.webView.configuration.userContentController imy_uninstallHookAjax];
}

@end
