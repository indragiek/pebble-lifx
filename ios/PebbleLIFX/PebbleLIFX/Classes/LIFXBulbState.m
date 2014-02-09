//
//  LIFXBulbState.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "LIFXBulbState.h"
#import "LIFXBulbStub.h"

@implementation LIFXBulbState

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{@"brightness" : @"state.brightness",
			 @"label" : @"state.bulbLabel",
			 @"dim" : @"state.dim",
			 @"hue" : @"state.hue",
			 @"kelvin" : @"state.kelvin",
			 @"power" : @"state.power",
			 @"saturation" : @"state.saturation"};
}

+ (NSValueTransformer *)bulbJSONTransformer
{
	return [MTLValueTransformer transformerWithBlock:^id(NSDictionary *bulb) {
		return [MTLJSONAdapter modelOfClass:LIFXBulbStub.class fromJSONDictionary:bulb error:nil];
	}];
}

@end
