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
#import "NSUserDefaults+PLFPreferences.h"
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
		colors = @[[PLFColor colorWithLabel:@"Red" color:[UIColor colorWithRed:1.00 green:0.26 blue:0.32 alpha:1.0]],
				   [PLFColor colorWithLabel:@"Orange" color:[UIColor colorWithRed:0.99 green:0.53 blue:0.06 alpha:1.0]],
				   [PLFColor colorWithLabel:@"Yellow" color:[UIColor colorWithRed:1.00 green:0.83 blue:0.15 alpha:1.0]],
				   [PLFColor colorWithLabel:@"Green" color:[UIColor colorWithRed:0.23 green:0.89 blue:0.21 alpha:1.0]],
				   [PLFColor colorWithLabel:@"Blue" color:[UIColor colorWithRed:0.11 green:0.60 blue:0.97 alpha:1.0]],
				   [PLFColor colorWithLabel:@"Purple" color:[UIColor colorWithRed:0.41 green:0.36 blue:0.93 alpha:1.0]]];
	});
	return colors;
}

#pragma mark - Initialization

- (void)commonInitForPLFViewController
{
	_colors = [NSMutableArray array];
	NSArray *savedColors = NSUserDefaults.standardUserDefaults.plf_savedColors;
	if (savedColors.count) {
		[_colors addObjectsFromArray:savedColors];
	}
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (indexPath.section == PLFCustomColorsSectionIndex);
}

#pragma mark - UITableViewDelegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == PLFCustomColorsSectionIndex) {
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.section == PLFCustomColorsSectionIndex && editingStyle == UITableViewCellEditingStyleDelete) {
		[self.colors removeObjectAtIndex:indexPath.row];
		[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
		[self persistCustomColors];
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
	PLFColor *colorObject = [PLFColor colorWithLabel:label color:color];
	[self.colors insertObject:colorObject atIndex:0];
	[self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:PLFCustomColorsSectionIndex]] withRowAnimation:UITableViewRowAnimationAutomatic];
	[self persistCustomColors];
}

- (void)colorPicker:(PLFColorPickerViewController *)picker didSelectColor:(UIColor *)color
{
	
}

- (void)persistCustomColors
{
	NSUserDefaults.standardUserDefaults.plf_savedColors = self.colors;
}
@end
