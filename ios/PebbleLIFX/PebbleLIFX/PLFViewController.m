//
//  PLFViewController.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "PLFViewController.h"
#import "PLFConnectedTableViewCell.h"
#import <PebbleKit/PebbleKit.h>

static NSInteger const PLFPebbleSectionIndex = 0;
static NSInteger const PLFColorsSectionIndex = 1;

@interface PLFViewController () <PBWatchDelegate>
@property (nonatomic, strong, readonly) NSMutableArray *colors;
@property (nonatomic, strong) PBWatch *connectedWatch;
@end

@implementation PLFViewController

#pragma mark - Initialization

- (void)commonInitForPLFViewController
{
	_colors = [NSMutableArray array];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		[self commonInitForPLFViewController];
	}
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style
{
	if ((self = [super initWithStyle:style])) {
		[self commonInitForPLFViewController];
	}
	return self;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.connectedWatch = PBPebbleCentral.defaultCentral.lastConnectedWatch;
	NSLog(@"%@", self.connectedWatch.name);
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case PLFPebbleSectionIndex:
			return 1;
		case PLFColorsSectionIndex:
			return self.colors.count;
		default:
			return 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case PLFPebbleSectionIndex:
			return NSLocalizedString(@"Pebble", nil);
		case PLFColorsSectionIndex:
			return NSLocalizedString(@"Colors", nil);
		default:
			return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == PLFPebbleSectionIndex) {
		PLFConnectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLFConnectedTableViewCellIdentifier];
		cell.connected = self.connectedWatch.connected;
		cell.pebbleName = self.connectedWatch.name;
		return cell;
	} else {
		return nil;
	}
}

@end
