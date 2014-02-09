//
//  PLFColorTableViewCell.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "PLFColorTableViewCell.h"
#import "PLFColorView.h"
#import "PLFColor.h"

@interface PLFColorTableViewCell ()
@property (nonatomic, weak) IBOutlet PLFColorView *colorView;
@property (nonatomic, weak) IBOutlet UILabel *colorLabel;
@end

NSString * const PLFColorTableViewCellIdentifier = @"ColorCell";

@implementation PLFColorTableViewCell

- (void)setColor:(PLFColor *)color
{
	if (_color != color) {
		_color = color;
		self.colorView.color = color.color;
		self.colorLabel.text = color.label;
	}
}

@end
