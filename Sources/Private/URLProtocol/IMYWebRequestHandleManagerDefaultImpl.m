//
//  IMYWebRequestHandleManagerDefaultImpl.m
//  Pods
//
//  Created by ljh on 2017/4/10.
//
//

#import "IMYWebRequestHandleManagerDefaultImpl.h"
#import "IMYWebURLProtocol.h"
#import "IMYWebRequestHandlerDefaultImpl.h"

@interface IMYWebRequestHandleManagerDefaultImpl () {
    NSArray *_requestHandlerClass;
}
@end

@implementation IMYWebRequestHandleManagerDefaultImpl

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enableWKCustomProtocol = YES;
        [self addRequestHandlerClass:[IMYWebRequestHandlerDefaultImpl class]];
    }
    return self;
}

- (void)addRequestHandlerClass:(Class)handlerClass
{
    NSArray *array = _requestHandlerClass ?: [NSArray array];
    const NSInteger index = [array indexOfObject:handlerClass];
    if (index != NSNotFound) {
        return;
    }
    @synchronized (self) {
        array = [array arrayByAddingObject:handlerClass];
        array = [array sortedArrayUsingComparator:^NSComparisonResult(id<IMYWebRequestHandler> _Nonnull obj1, id<IMYWebRequestHandler> _Nonnull obj2) {
            NSInteger priority1 = [obj1 respondsToSelector:@selector(priority)] ? [obj1 priority] : 0;
            NSInteger priority2 = [obj2 respondsToSelector:@selector(priority)] ? [obj2 priority] : 0;
            if (priority1 < priority2) {
                return NSOrderedDescending;
            } else if (priority1 > priority2) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];

        id holdArray = _requestHandlerClass;
        dispatch_async(dispatch_get_main_queue(), ^{
            [holdArray description];
        });

        _requestHandlerClass = array;
    }
}

- (void)removeRequestHandlerClass:(Class)handlerClass
{
    NSArray *array = _requestHandlerClass ?: [NSArray array];
    const NSInteger index = [array indexOfObject:handlerClass];
    if (index == NSNotFound) {
        return;
    }
    @synchronized (self) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
        [mutableArray removeObjectAtIndex:index];

        id holdArray = _requestHandlerClass;
        dispatch_async(dispatch_get_main_queue(), ^{
            [holdArray description];
        });
        _requestHandlerClass = [mutableArray copy];
    }
}

- (NSArray<Class<IMYWebRequestHandler>> *)requestHandlerClass
{
    NSArray *array = _requestHandlerClass;
    return array;
}

- (void)setEnableWKCustomProtocol:(BOOL)enableWKCustomProtocol
{
    [IMYWebURLProtocol setEnableWKCustomProtocol:enableWKCustomProtocol];
}

- (BOOL)enableWKCustomProtocol
{
    return [IMYWebURLProtocol enableWKCustomProtocol];
}

@end
