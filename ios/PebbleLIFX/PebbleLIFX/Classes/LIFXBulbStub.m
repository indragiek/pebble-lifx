//
//  LIFXBulbStub.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "LIFXBulbStub.h"

@implementation LIFXBulbStub

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"address": @"lifxAddress"};
}

+ (NSValueTransformer *)addressJSONTransformer
{
	return [MTLValueTransformer transformerWithBlock:^id(NSArray *components) {
		return [components componentsJoinedByString:@":"];
	}];
}

@end
