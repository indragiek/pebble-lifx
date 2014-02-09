//
//  LIFXBulbStub.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface LIFXBulbStub : MTLModel <MTLJSONSerializing>
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *address;
// This stores the index of the bulb as it exists on the server.
//
// This is dirty and the LIFX bulb address should be used instead to
// locate a particular bulb.
@property (nonatomic, assign, readonly) NSUInteger index;
@end
