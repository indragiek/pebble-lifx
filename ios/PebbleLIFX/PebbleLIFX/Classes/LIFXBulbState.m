//
//  LIFXBulbState.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "LIFXBulbState.h"
#import "LIFXBulbStub.h"
#import "LIFXBulbState_Private.h"

@interface LIFXBulbState ()
@property (nonatomic, assign, readwrite) uint16_t power;
@end

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

- (BOOL)isOn
{
	return (self.power > 0);
}

- (void)setOn:(BOOL)on
{
	self.power = on ? UINT16_MAX : 0;
}

+ (NSSet *)keyPathsForValuesAffectingOn
{
	return [NSSet setWithObject:@"power"];
}

@end
