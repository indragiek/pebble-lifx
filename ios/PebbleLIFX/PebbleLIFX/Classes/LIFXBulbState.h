//
//  LIFXBulbState.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Mantle/Mantle.h>

@class LIFXBulbStub;

@interface LIFXBulbState : MTLModel <MTLJSONSerializing>
@property (nonatomic, strong, readonly) LIFXBulbStub *bulb;
@property (nonatomic, assign, readonly) int16_t hue;
@property (nonatomic, assign, readonly) int16_t saturation;
@property (nonatomic, assign, readonly) int16_t brightness;
@property (nonatomic, assign, readonly) int16_t dim;
@property (nonatomic, assign, readonly) int16_t kelvin;
@property (nonatomic, assign, readonly) int16_t power;
@property (nonatomic, copy, readonly) NSString *label;
@end
