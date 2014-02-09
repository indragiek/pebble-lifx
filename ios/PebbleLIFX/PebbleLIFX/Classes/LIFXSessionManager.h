//
//  LIFXSessionManager.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@class LIFXBulbStub;
@interface LIFXSessionManager : AFHTTPSessionManager
- (NSURLSessionDataTask *)getBulbStubsWithSuccess:(void (^)(NSURLSessionDataTask *task, NSArray *stubs))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
- (NSURLSessionDataTask *)setColor:(UIColor *)color forBulb:(LIFXBulbStub *)bulb withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
