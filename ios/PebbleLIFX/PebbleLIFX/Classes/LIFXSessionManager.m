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

- (NSURLSessionDataTask *)setColor:(UIColor *)color forBulb:(LIFXBulbStub *)stub withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
	CGFloat hue, saturation, brightness = 0.1; // Lock the brightness to avoid blinding light
	[color getHue:&hue saturation:&saturation brightness:NULL alpha:NULL];
	NSString *path = [NSString stringWithFormat:@"/bulbs/%lu/color", (unsigned long)stub.index];
	NSDictionary *parameters = @{@"hue" : @(hue * UINT16_MAX),
								 @"saturation" : @(saturation * UINT16_MAX),
								 @"luminance" : @(brightness * UINT16_MAX),
								 @"whiteColor" : @0,
								 @"fadeTime" : @0};
	return [self POST:path parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)getStateForBulb:(LIFXBulbStub *)stub success:(void (^)(NSURLSessionDataTask *task, LIFXBulbState *state))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
	NSString *path = [NSString stringWithFormat:@"/bulbs/%lu", (unsigned long)stub.index];
	return [self GET:path parameters:nil success:^(NSURLSessionDataTask *task, NSDictionary *response) {
		LIFXBulbState *state = [MTLJSONAdapter modelOfClass:LIFXBulbState.class fromJSONDictionary:response error:nil];
		state.bulb.index = stub.index;
		if (success) success(task, state);
	} failure:failure];
}

- (NSURLSessionDataTask *)setOn:(BOOL)on forBulb:(LIFXBulbStub *)stub withSuccess:(void (^)(NSURLSessionDataTask *task, id responseObject))success failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
	NSString *path = [NSString stringWithFormat:@"/bulbs/%lu/on_off", (unsigned long)stub.index];
	return [self POST:path parameters:@{@"state" : @(on)} success:success failure:failure];
}

@end
