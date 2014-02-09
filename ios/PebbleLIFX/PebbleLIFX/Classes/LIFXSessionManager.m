//
//  LIFXSessionManager.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "LIFXSessionManager.h"
#import "NSUserDefaults+PLFPreferences.h"

@implementation LIFXSessionManager

- (id)init
{
	if ((self = [super initWithBaseURL:nil])) {
		self.responseSerializer = [AFJSONResponseSerializer serializer];
	}
	return self;
}

- (NSURLSessionDataTask *)getBulbStubsWithSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
	return [self GET:[self requestURLStringWithRelativePath:@"/bulbs"] parameters:nil success:success failure:failure];
}

- (NSString *)requestURLStringWithRelativePath:(NSString *)path
{
	NSString *address = NSUserDefaults.standardUserDefaults.plf_serverAddress;
	return [address stringByAppendingPathComponent:path];
}

@end
