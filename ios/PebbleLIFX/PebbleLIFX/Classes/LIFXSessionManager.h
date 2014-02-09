//
//  LIFXSessionManager.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "AFHTTPSessionManager.h"
#import "LIFXBulbStub.h"
#import "LIFXBulbState.h"

@interface LIFXSessionManager : AFHTTPSessionManager

- (NSURLSessionDataTask *)getBulbStubsWithSuccess:(void (^)(NSURLSessionDataTask *task, NSArray *stubs))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)getStateForBulb:(LIFXBulbStub *)stub success:(void (^)(NSURLSessionDataTask *task, LIFXBulbState *state))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)setColor:(UIColor *)color forBulb:(LIFXBulbStub *)stub withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

- (NSURLSessionDataTask *)setOn:(BOOL)on forBulb:(LIFXBulbStub *)stub withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
@end
