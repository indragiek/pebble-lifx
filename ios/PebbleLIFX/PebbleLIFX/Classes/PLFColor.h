//
//  PLFColor.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface PLFColor : MTLModel
@property (nonatomic, copy, readonly) NSString *label;
@property (nonatomic, strong, readonly) UIColor *color;
+ (instancetype)colorWithLabel:(NSString *)label color:(UIColor *)color;
@end
