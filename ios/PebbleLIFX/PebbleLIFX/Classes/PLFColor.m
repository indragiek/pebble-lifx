//
//  PLFColor.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "PLFColor.h"

@interface PLFColor ()
@property (nonatomic, copy, readwrite) NSString *label;
@property (nonatomic, strong, readwrite) UIColor *color;
@end

@implementation PLFColor

#pragma mark - Initialization

+ (instancetype)colorWithLabel:(NSString *)label color:(UIColor *)color
{
	PLFColor *colorModel = [[self alloc] init];
	colorModel.label = label;
	colorModel.color = color;
	return colorModel;
}

@end
