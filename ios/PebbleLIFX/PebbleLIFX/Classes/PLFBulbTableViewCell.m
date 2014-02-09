//
//  PLFBulbTableViewCell.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "PLFBulbTableViewCell.h"

NSString * const PLFBulbTableViewCellIdentifier = @"BulbCell";

@implementation PLFBulbTableViewCell

- (void)commonInitForPLFBulbTableViewCell
{
	self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		[self commonInitForPLFBulbTableViewCell];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self commonInitForPLFBulbTableViewCell];
	}
	return self;
}

@end
