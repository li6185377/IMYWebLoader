//
//  IMYIndexVC.m
//  IMYWebLoader
//
//  Created by ljh on 2017/4/10.
//  Copyright © 2017年 meetyou. All rights reserved.
//

#import "IMYIndexVC.h"
#import "WKURLProtocolVC.h"
#import <IMYWebLoader.h>

@interface IMYCacheNewsRequestHandler : NSObject <IMYWebRequestHandler>

@end

@implementation IMYIndexVC {
    NSArray *array;
}

+ (void)initialize {
    [[IMYWebLoader defaultRequestManager] addRequestHandlerClass:[IMYCacheNewsRequestHandler class]];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    array = @[@{@"id":@0, @"title":@"正常WKWebView"},
              @{@"id":@1, @"title":@"Hook Ajax WKWebView"},
              @{@"id":@2, @"title":@"正常加载-有缓存"},
              @{@"id":@3, @"title":@"预加载"}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary *dict = array[indexPath.row];
    cell.textLabel.text = dict[@"title"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = array[indexPath.row];
    switch ([dict[@"id"] integerValue]) {
        case 0: {
            WKURLProtocolVC *vc = [WKURLProtocolVC new];
            vc.urlString = @"http://www.w3school.com.cn/tiy/loadtext.asp?f=ajax_post2";
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1: {
            WKURLProtocolVC *vc = [WKURLProtocolVC new];
            vc.urlString = @"http://www.w3school.com.cn/tiy/loadtext.asp?f=ajax_post2";
            vc.testAjax = YES;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2: {
            NSString *urlString = @"https://news-node.seeyouyima.com/article?news_id=842947";
            WKURLProtocolVC *vc = [WKURLProtocolVC new];
            vc.urlString = urlString;
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 3: {
            [self prefetchWebVC];
            break;
        }
    }
}

- (void)prefetchWebVC
{
    NSString *urlString = @"https://news-node.seeyouyima.com/article?news_id=842947";
    id data = [[IMYWebLoader defaultCacheHandler] dataForKey:urlString];
    if (data) {
        WKURLProtocolVC *vc = [WKURLProtocolVC new];
        vc.urlString = urlString;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        id<IMYWebPrefetcherProtocol> prefetcher = [[IMYWebLoader defaultPrefetchHandler] prefetchWebUrl:urlString];
        /// kvo complated ...
        if (![(id)prefetcher observationInfo]) {
            [(id)prefetcher addObserver:self forKeyPath:@"complated" options:NSKeyValueObservingOptionNew context:nil];   
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([change[NSKeyValueChangeNewKey] boolValue]) {
        NSLog(@"预加载完成!");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self prefetchWebVC]; 
        });
    }
    [object removeObserver:self forKeyPath:@"complated"];
}

@end



@implementation IMYCacheNewsRequestHandler

/// 是否要拦截该 request
+ (BOOL)shouldHookWithRequest:(NSURLRequest *)request
{
    if ([request.URL.absoluteString containsString:@"news-node.seeyouyima.com"]) {
        return YES;
    }
    return NO;
}

/// 取消该 Request 的拦截，只要有一个 class 返回 YES，则不拦截该请求
+ (BOOL)cancelHookWithRequest:(NSURLRequest *)request
{
    return NO;
}

/// 根据 Request 返回具体的请求实例, 会使用第一个返回的请求对象
+ (nullable id<IMYWebRequestHandler>)requestHandlerWithRequest:(NSURLRequest *)request
{
    return nil;
}

/// 开始加载
- (void)startLoadingWithDelegate:(id<IMYWebRequestDelegate>)delegate
{
    
}

/// 停止加载
- (void)stopLoading
{
    
}

@end
