//
//  IMYWebCacheHandlerDefaultImpl.m
//  Pods
//
//  Created by ljh on 2017/2/28.
//
//

#import "IMYWebCacheHandlerDefaultImpl.h"
#import <CommonCrypto/CommonDigest.h>

@interface IMYWebCacheHandlerDefaultImpl ()

@property (nonatomic, strong) NSCache *memCache;
@property (nonatomic, strong) NSString *dirPath;

@end

@implementation IMYWebCacheHandlerDefaultImpl

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        self.dirPath = [paths.firstObject stringByAppendingPathComponent:@"imy.web.default.cache"];
    }
    return self;
}

- (void)applicationDidReceiveMemoryWarning
{
    [self.memCache removeAllObjects];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)cacheKeyForRequest:(NSURLRequest *)request
{
    return request.URL.absoluteString;
}

- (NSString *)fileNameForKey:(NSString *)key
{
    if (!key) {
        return @"";
    }
    
    NSData *data = [key dataUsingEncoding:NSUTF8StringEncoding];
    
    // CC_SHA1_DIGEST_LENGTH : 20
    uint8_t digest[20];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSString *sha1 = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                      digest[0], digest[1], digest[2], digest[3], digest[4],
                      digest[5], digest[6], digest[7], digest[8], digest[9],
                      digest[10], digest[11], digest[12], digest[13], digest[14],
                      digest[15], digest[16], digest[17], digest[18], digest[19]];
    
    return sha1;
}

- (NSString *)filePathForKey:(NSString *)key
{
    NSString *fileName = [self fileNameForKey:key];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_dirPath]) {
        [fileManager createDirectoryAtPath:_dirPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [_dirPath stringByAppendingPathComponent:fileName];
    return filePath;
}

- (void)setData:(IMYWebData *)data forKey:(NSString *)key
{
    [self.memCache setObject:data forKey:key];
    NSString *filePath = [self filePathForKey:key];
    NSData *fileData = nil;
    if (data) {
        fileData = [NSKeyedArchiver archivedDataWithRootObject:data];
    }
    if (fileData) {
        [fileData writeToFile:filePath atomically:YES];
    } else {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

- (IMYWebData *)dataForKey:(NSString *)key
{
    IMYWebData *data = [self.memCache objectForKey:key];
    if (!data) {
        NSString *filePath = [self filePathForKey:key];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        if (fileData) {
            data = [NSKeyedUnarchiver unarchiveObjectWithData:fileData];
        }
    }
    return data;
}

@end
