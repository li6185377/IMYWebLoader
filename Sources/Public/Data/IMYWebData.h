//
//  IMYWebData.h
//  Pods
//
//  Created by ljh on 2017/2/27.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMYWebData : NSObject <NSSecureCoding>

@property (nullable, nonatomic, copy) NSURLRequest *request; /**< 请求链接*/
@property (nullable, nonatomic, copy) NSURLRequest *redirectRequest; /**< 重定向链接*/
@property (nullable, nonatomic, copy) NSURLResponse *response; /**< 服务器返回的response*/
@property (nullable, nonatomic, copy) NSData *data; /**< 数据*/
@property (nullable, nonatomic, copy) NSError *error; /**< 错误*/

@property (nullable, nonatomic, copy) NSDate *createDate; /**< 创建时间*/
@property (nullable, nonatomic, copy) NSDictionary *userInfo; /**< 用户数据*/

@end

NS_ASSUME_NONNULL_END
