//
//  IMYWebURLProtocol.h
//  Pods
//
//  Created by ljh on 2017/2/28.
//
//

#import <Foundation/Foundation.h>

@interface IMYWebURLProtocol : NSURLProtocol

@end


@interface IMYWebURLProtocol (WKCustomProtocol)
@property (class, nonatomic) BOOL enableWKCustomProtocol;
@end
