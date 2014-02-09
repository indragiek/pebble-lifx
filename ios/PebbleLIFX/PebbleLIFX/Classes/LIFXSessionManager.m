//
//  LIFXSessionManager.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "LIFXSessionManager.h"
#import "LIFXBulbStub_Private.h"
#import "NSUserDefaults+PLFPreferences.h"

@implementation LIFXSessionManager

- (id)init
{
	NSString *address = NSUserDefaults.standardUserDefaults.plf_serverAddress;
	if ((self = [super initWithBaseURL:[NSURL URLWithString:address]])) {
		self.responseSerializer = [AFJSONResponseSerializer serializer];
	}
	return self;
}

- (NSURLSessionDataTask *)getBulbStubsWithSuccess:(void (^)(NSURLSessionDataTask *task, NSArray *stubs))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
	return [self GET:@"/bulbs" parameters:nil success:^(NSURLSessionDataTask *task, NSArray *bulbs) {
		NSMutableArray *stubs = [NSMutableArray arrayWithCapacity:bulbs.count];
		[bulbs enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
			LIFXBulbStub *stub = [MTLJSONAdapter modelOfClass:LIFXBulbStub.class fromJSONDictionary:dict error:nil];
			stub.index = idx;
			if (stub) [stubs addObject:stub];
		}];
		if (success) success(task, stubs);
	} failure:failure];
}

@end
