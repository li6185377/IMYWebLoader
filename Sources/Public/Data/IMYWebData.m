//
//  IMYWebData.m
//  Pods
//
//  Created by ljh on 2017/2/27.
//
//

#import "IMYWebData.h"

static NSString * const kRequestKey = @"request";
static NSString * const kRedirectRequestKey = @"redirectRequest";
static NSString * const kResponseKey = @"response";
static NSString * const kDataKey = @"data";
static NSString * const kErrorKey = @"error";

static NSString * const kCreateDateKey = @"createDate";
static NSString * const kUserInfoKey = @"userInfo";

@implementation IMYWebData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _createDate = [NSDate date];
    }
    return self;
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_request forKey:kRequestKey];
    [aCoder encodeObject:_redirectRequest forKey:kRedirectRequestKey];
    [aCoder encodeObject:_response forKey:kResponseKey];
    [aCoder encodeObject:_data forKey:kDataKey];
    [aCoder encodeObject:_error forKey:kErrorKey];
    
    [aCoder encodeObject:_createDate forKey:kCreateDateKey];
    [aCoder encodeObject:_userInfo forKey:kUserInfoKey];
}

- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super init];
    if (self) {
        _request = [aDecoder decodeObjectForKey:kRequestKey];
        _redirectRequest = [aDecoder decodeObjectForKey:kRedirectRequestKey];
        _response = [aDecoder decodeObjectForKey:kResponseKey];
        _data = [aDecoder decodeObjectForKey:kDataKey];
        _error = [aDecoder decodeObjectForKey:kErrorKey];
        
        _createDate = [aDecoder decodeObjectForKey:kCreateDateKey];
        _userInfo = [aDecoder decodeObjectForKey:kUserInfoKey];
    }
    return self;
}

@end

