//
//  PLFColorView.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "PLFColorView.h"

@implementation PLFColorView

- (void)drawRect:(CGRect)rect
{
	UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
	[path addClip];
	[self.color setFill];
	UIRectFill(self.bounds);
}

@end
