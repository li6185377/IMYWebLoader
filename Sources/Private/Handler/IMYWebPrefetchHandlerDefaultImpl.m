//
//  IMYWebPrefetchHandlerDefaultImpl.m
//  Pods
//
//  Created by ljh on 2017/2/28.
//
//

#import "IMYWebPrefetchHandlerDefaultImpl.h"
#import "XMLDictionary.h"
#import "IMYWebLoader.h"
#import "IMYWebUtils.h"

@interface IMYWebPrefetchOperater : NSObject <IMYWebPrefetcherProtocol>

@property (nonatomic, copy) NSString *webUrl;
@property (nonatomic, assign, getter=isComplated) BOOL complated;

@property (nonatomic, weak) id<IMYWebOperation> operation;
@property (nonatomic, strong) NSMutableDictionary<NSString *, IMYWebPrefetchOperater *> *detailMaps;

- (void)startLoading:(NSURLRequest *)request cacheKey:(NSString *)cacheKey;

@end

@interface IMYWebPrefetchHandlerDefaultImpl ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, IMYWebPrefetchOperater *> *webUrls;
@end

@implementation IMYWebPrefetchHandlerDefaultImpl

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.webUrls = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id<IMYWebPrefetcherProtocol>)prefetchWebUrl:(NSString *)webUrl
{
    if (!webUrl.length) {
        return nil;
    }
    id<IMYWebPrefetcherProtocol> prefetcher = nil;
    @synchronized (self) {
        prefetcher = self.webUrls[webUrl];
        //已存在，一次运行周期内 只预加载一次
        if (prefetcher) {
            return prefetcher;
        }
        prefetcher = [self lockPrefetchHTMLDetail:webUrl];
    }
    return prefetcher;
}

- (id<IMYWebPrefetcherProtocol>)lockPrefetchHTMLDetail:(NSString *)urlString
{
    NSURLRequest *request = [[IMYWebLoader defaultNetworkHandler] requestWithString:urlString];
    if (!request) {
        return nil;
    }
    
    IMYWebPrefetchOperater *operater = [IMYWebPrefetchOperater new];
    operater.webUrl = urlString;
    
    NSString *cacheKey = [[IMYWebLoader defaultCacheHandler] cacheKeyForRequest:request];
    IMYWebData *data = [[IMYWebLoader defaultCacheHandler] dataForKey:cacheKey];
    ///已有缓存
    if (data) {
        operater.complated = YES;
        return operater;
    }
    
    [operater startLoading:request cacheKey:cacheKey];
    
    return operater;
}

- (void)cancelAllPrefetcherLoading
{
    @synchronized (self) {
        [self.webUrls enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, IMYWebPrefetchOperater * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
    }
}

- (void)removePrefetcherForWebUrl:(NSString *)webUrl
{
    @synchronized (self) {
        [self.webUrls removeObjectForKey:webUrl];
    }
}

@end

@implementation IMYWebPrefetchOperater

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.detailMaps = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)startLoading:(NSURLRequest *)request cacheKey:(NSString *)cacheKey
{
    self.operation = [[IMYWebLoader defaultNetworkHandler] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!data.length || error) {
            return;
        }
        NSInteger statusCode = 0;
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            statusCode = [(NSHTTPURLResponse *)response statusCode];
        }
        if(statusCode < 200 || statusCode >= 300) {
            return;
        }
        
        NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        ///过滤可能的错误，html 文本长度过短，或者 内容包含 404错误字眼等
        if (!html.length || [html containsString:@"404错误"] || [html containsString:@" 404 "]) {
            return;
        }
        
        IMYWebData *webData = [IMYWebData new];
        webData.data = data;
        webData.response = response;
        webData.request = request;
        
        //数据缓存
        [[IMYWebLoader defaultCacheHandler] setData:webData forKey:cacheKey];
        
        ///标志已完成
        self.complated = YES;
        
        ///加载静态资源
        [self prefetchResourcesWithHTML:html baseURL:response.URL];
    }];
}


- (void)prefetchResourcesWithHTML:(NSString *)html baseURL:(NSURL *)baseURL
{
    ///替换 换行符，正则没匹配 \n
    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    
    [self prefetchCSSWithHTML:html baseURL:baseURL];
    [self prefetchScriptWithHTML:html baseURL:baseURL];
    
    [self prefetchImagesWithHTML:html baseURL:baseURL];
}

/// 没有导太多的 pods，只能手动写了
- (NSArray *)filter:(NSArray *)array block:(BOOL(^)(id element))block {
    if (!array || !block) {
        return [NSArray array];
    }
    NSMutableArray *result = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (block(obj)) {
            [result addObject:obj];
        }
    }];
    return result;
}

- (void)prefetchCSSWithHTML:(NSString *)html baseURL:(NSURL *)baseURL
{
    NSArray *urls = [self urlsWithHTML:html regular:[self cssHrefExpression] forKey:@"href" baseURL:baseURL];
    urls = [self filter:urls block:^BOOL(id element) {
        return [element containsString:@".css"] || [element containsString:@".ico"];
    }];
    if (urls.count) {
        [self prefetchFileWithUrls:urls];
    }
}

- (void)prefetchScriptWithHTML:(NSString *)html baseURL:(NSURL *)baseURL
{
    NSArray *urls = [self urlsWithHTML:html regular:[self scriptSrcExpression] forKey:@"src" baseURL:baseURL];
    urls = [self filter:urls block:^BOOL(id element) {
        return [element containsString:@".js"];
    }];
    if (urls.count) {
        [self prefetchFileWithUrls:urls];
    }
}

- (void)prefetchFileWithUrls:(NSArray *)urls
{
    @synchronized (self) {
        [self lockPrefetchFileWithUrls:urls];
    }
}

- (void)lockPrefetchFileWithUrls:(NSArray *)urls
{
    [urls enumerateObjectsUsingBlock:^(NSString *fileURL, NSUInteger idx, BOOL * _Nonnull stop) {
        
        IMYWebPrefetchOperater *operater = self.detailMaps[fileURL];
        if (operater) {
            return ;
        }
        
        NSURLRequest *request = [[IMYWebLoader defaultNetworkHandler] requestWithString:fileURL];
        if (!request) {
            return;
        }
        
        operater = [IMYWebPrefetchOperater new];
        operater.webUrl = fileURL;
        self.detailMaps[fileURL] = operater;
        
        NSString *cacheKey = [[IMYWebLoader defaultCacheHandler] cacheKeyForRequest:request];
        IMYWebData *data = [[IMYWebLoader defaultCacheHandler] dataForKey:cacheKey];
        ///已有缓存
        if (data) {
            operater.complated = YES;
            return;
        }
        
        operater.operation = [[IMYWebLoader defaultNetworkHandler] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!data.length || error) {
                return;
            }
            NSInteger statusCode = 0;
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                statusCode = [(NSHTTPURLResponse *)response statusCode];
            }
            if(statusCode < 200 || statusCode >= 300) {
                return;
            }
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            ///过滤可能的错误，html 文本长度过短，或者 内容包含 404错误字眼等
            if ([html containsString:@"404错误"] || [html containsString:@" 404 "]) {
                return;
            }
            
            operater.complated = YES;
            
            IMYWebData *cacheData = [IMYWebData new];
            cacheData.data = data;
            cacheData.response = response;
            cacheData.request = request;
            
            [[IMYWebLoader defaultCacheHandler] setData:cacheData forKey:cacheKey];
        }];
    }];
}

- (void)prefetchImagesWithHTML:(NSString *)html baseURL:(NSURL *)baseURL
{
    NSMutableArray *prefetchImages = [NSMutableArray array];
    
    NSArray *imgArray = [self urlsWithHTML:html regular:[self imgSrcExpression] forKey:@"src" baseURL:baseURL];
    if (imgArray.count > 3) {
        imgArray = [imgArray subarrayWithRange:NSMakeRange(0, 3)];
    }
    if (imgArray.count) {
        [prefetchImages addObjectsFromArray:imgArray];
    }
    
    NSArray *posterArray = [self urlsWithHTML:html regular:[self videoPosterExpression] forKey:@"poster" baseURL:baseURL];
    if (posterArray.count) {
        [prefetchImages addObjectsFromArray:posterArray];
    }
    [self prefetchFileWithUrls:prefetchImages];
}

- (NSArray<NSString *> *)urlsWithHTML:(NSString *)html regular:(NSRegularExpression *)regular forKey:(NSString *)key baseURL:(NSURL *)baseURL
{
    if (!html || !regular || !key) {
        return nil;
    }
    NSArray<NSTextCheckingResult *> *results = [regular matchesInString:html options:0 range:NSMakeRange(0, html.length)];
    NSMutableArray *urls = [NSMutableArray array];
    [results enumerateObjectsUsingBlock:^(NSTextCheckingResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *substring = [html substringWithRange:obj.range];
        NSDictionary *xmlNode = [NSDictionary dictionaryWithXMLString:substring];
        if (!xmlNode) {
            NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];
            NSArray *parts = [substring componentsSeparatedByCharactersInSet:whitespaces];
            NSArray *filteredArray = [self filter:parts block:^BOOL(id element) {
                return [element hasPrefix:@"<"] || [element containsString:@"="] || [element hasSuffix:@">"];
            }];
            NSString *nodeString = [filteredArray componentsJoinedByString:@" "];
            xmlNode = [NSDictionary dictionaryWithXMLString:nodeString];
        }
        
        ///获取 src url
        __block NSString *srcURL = nil;
        [xmlNode enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull nodeName, NSString * _Nonnull nodeValue, BOOL * _Nonnull stop) {
            if ([nodeName hasSuffix:key] && [nodeValue isKindOfClass:[NSString class]] && nodeValue.length > 0) {
                srcURL = nodeValue;
                *stop = YES;
            }
        }];
        
        srcURL = [IMYWebUtils URLWithString:srcURL baseURL:baseURL].absoluteString;
        
        if (srcURL) {
            [urls addObject:srcURL];
        }
    }];
    return urls;
}

- (NSRegularExpression *)cssHrefExpression
{
    return [NSRegularExpression regularExpressionWithPattern:@"<link.*?href=\"([^\"]*)\".*?/?>" options:0 error:nil];
}

- (NSRegularExpression *)scriptSrcExpression
{
    return [NSRegularExpression regularExpressionWithPattern:@"<script.*?src=\"([^\"]*)\".*?/?>" options:0 error:nil];
}

- (NSRegularExpression *)imgSrcExpression
{
    return [NSRegularExpression regularExpressionWithPattern:@"<img.*?src=\"([^\"]*)\".*?/?>" options:0 error:nil];
}

- (NSRegularExpression *)videoPosterExpression
{
    return [NSRegularExpression regularExpressionWithPattern:@"<video.*?poster=\"([^\"]*)\".*?/?>" options:0 error:nil];
}

- (void)cancel
{
    @synchronized (self) {
        if (self.operation) {
            [self.operation cancel];
            self.operation = nil;
        }
        [self.detailMaps enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, IMYWebPrefetchOperater * _Nonnull obj, BOOL * _Nonnull stop) {
            [obj cancel];
        }];
    }
}
@end
