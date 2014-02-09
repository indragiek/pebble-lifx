//
//  PLFViewController.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "PLFViewController.h"
#import "PLFConnectedTableViewCell.h"
#import "PLFColorTableViewCell.h"
#import "PLFColor.h"
#import "PLFColorPickerViewController.h"
#import <PebbleKit/PebbleKit.h>

static NSInteger const PLFPebbleSectionIndex = 0;
static NSInteger const PLFCustomColorsSectionIndex = 1;
static NSInteger const PLFDefaultColorsSectionIndex = 2;

@interface PLFViewController () <PBWatchDelegate, PLFColorPickerViewControllerDelegate>
@property (nonatomic, strong, readonly) NSMutableArray *colors;
@property (nonatomic, strong) PBWatch *connectedWatch;
@end

@implementation PLFViewController

#pragma mark - Defaults

+ (NSArray *)defaultColors
{
	static NSArray *colors = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		colors = @[[PLFColor colorWithLabel:@"Red" color:UIColor.redColor],
				   [PLFColor colorWithLabel:@"Orange" color:UIColor.orangeColor],
				   [PLFColor colorWithLabel:@"Yellow" color:UIColor.yellowColor],
				   [PLFColor colorWithLabel:@"Green" color:UIColor.greenColor],
				   [PLFColor colorWithLabel:@"Blue" color:UIColor.blueColor],
				   [PLFColor colorWithLabel:@"Purple" color:UIColor.purpleColor]];
	});
	return colors;
}

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
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case PLFPebbleSectionIndex:
			return 1;
		case PLFCustomColorsSectionIndex:
			return self.colors.count;
		case PLFDefaultColorsSectionIndex:
			return self.class.defaultColors.count;
		default:
			return 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section) {
		case PLFPebbleSectionIndex:
			return NSLocalizedString(@"Pebble", nil);
		case PLFCustomColorsSectionIndex:
			return NSLocalizedString(@"Custom Colors", nil);
		case PLFDefaultColorsSectionIndex:
			return NSLocalizedString(@"Default Colors", nil);
		default:
			return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	switch (indexPath.section) {
		case PLFPebbleSectionIndex: {
			PLFConnectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLFConnectedTableViewCellIdentifier];
			cell.connected = self.connectedWatch.connected;
			cell.pebbleName = self.connectedWatch.name;
			return cell;
		}
		case PLFCustomColorsSectionIndex: {
			PLFColorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLFColorTableViewCellIdentifier];
			cell.color = self.colors[indexPath.row];
			return cell;
		}
		case PLFDefaultColorsSectionIndex: {
			PLFColorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLFColorTableViewCellIdentifier];
			cell.color = self.class.defaultColors[indexPath.row];
			return cell;
		}
		default:
			return nil;
	}
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"PickColor"]) {
		UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
		PLFColorPickerViewController *controller = (PLFColorPickerViewController *)navController.topViewController;
		controller.delegate = self;
	}
}

#pragma mark - PLFColorPickerViewControllerDelegate

- (void)colorPicker:(PLFColorPickerViewController *)picker didPickColor:(UIColor *)color withLabel:(NSString *)label
{
	NSLog(@"%@ %@", color, label);
}

- (void)colorPicker:(PLFColorPickerViewController *)picker didSelectColor:(UIColor *)color
{
	
}
@end
