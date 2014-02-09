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

#pragma mark - NSObject

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@:%p label:%@ color:%@>", NSStringFromClass(self.class), self, self.label, self.color];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super init])) {
		self.label = [aDecoder decodeObjectForKey:@"label"];
		self.color = [aDecoder decodeObjectForKey:@"color"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.label forKey:@"label"];
	[aCoder encodeObject:self.color forKey:@"color"];
}

@end
