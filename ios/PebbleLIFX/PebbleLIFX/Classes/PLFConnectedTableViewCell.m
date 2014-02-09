//
//  PLFConnectedTableViewCell.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "PLFConnectedTableViewCell.h"

NSString * const PLFConnectedTableViewCellIdentifier = @"ConnectedCell";

#define PLF_CONNECTED_COLOR [UIColor colorWithRed:0.43 green:0.91 blue:0.47 alpha:1.0]
#define PLF_DISCONNECTED_COLOR [UIColor colorWithRed:0.99 green:0.56 blue:0.56 alpha:1.0]

@implementation PLFConnectedTableViewCell

- (void)commonInitForPLFConnectedTableViewCell
{
	self.backgroundColor = PLF_DISCONNECTED_COLOR;
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	self.textLabel.textAlignment = NSTextAlignmentCenter;
	[self resetConnectionLabel];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		[self commonInitForPLFConnectedTableViewCell];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self commonInitForPLFConnectedTableViewCell];
	}
	return self;
}

- (void)setPebbleName:(NSString *)pebbleName
{
	if (_pebbleName != pebbleName) {
		_pebbleName = [pebbleName copy];
		[self resetConnectionLabel];
	}
}

- (void)setConnected:(BOOL)connected
{
	if (_connected != connected) {
		_connected = connected;
		self.backgroundColor = connected ? PLF_CONNECTED_COLOR : PLF_DISCONNECTED_COLOR;
		[self resetConnectionLabel];
	}
}

- (void)resetConnectionLabel
{
	if (self.connected) {
		self.textLabel.text = [NSString stringWithFormat:@"Connected to %@", self.pebbleName];
	} else {
		self.textLabel.text = NSLocalizedString(@"No Pebble Connected", nil);
	}
}

@end
