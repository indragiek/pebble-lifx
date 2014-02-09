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
#import "PLFBulbTableViewCell.h"
#import "PLFColor.h"
#import "PLFColorPickerViewController.h"
#import "NSUserDefaults+PLFPreferences.h"
#import "LIFXSessionManager.h"
#import "LIFXBulbState_Private.h"
#import "PLFPebbleAppMessageHandler.h"
#import <PebbleKit/PebbleKit.h>

static NSInteger const PLFPebbleSectionIndex = 0;
static NSInteger const PLFBulbsSectionIndex = 1;
static NSInteger const PLFCustomColorsSectionIndex = 2;
static NSInteger const PLFDefaultColorsSectionIndex = 3;

@interface PLFViewController () <PBWatchDelegate, PLFColorPickerViewControllerDelegate, PLFPebbleAppMessageHandlerDelegate>
@property (nonatomic, strong, readonly) NSMutableArray *colors;
@property (nonatomic, strong) NSArray *bulbStates;
@property (nonatomic, strong) PBWatch *connectedWatch;
@property (nonatomic, strong, readonly) LIFXSessionManager *lifxManager;
@property (nonatomic, strong) PLFPebbleAppMessageHandler *pebbleHandler;
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
	_lifxManager = [LIFXSessionManager new];
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

- (void)getBulbStates:(void(^)(NSArray *bulbStates))completion
{
	[self.lifxManager getBulbStubsWithSuccess:^(NSURLSessionDataTask *task, NSArray *stubs) {
		NSMutableArray *bulbs = [NSMutableArray arrayWithCapacity:stubs.count];
		dispatch_group_t group = dispatch_group_create();
		for (LIFXBulbStub *stub in stubs) {
			dispatch_group_enter(group);
			[self.lifxManager getStateForBulb:stub success:^(NSURLSessionDataTask *task, LIFXBulbState *state) {
				[bulbs addObject:state];
				dispatch_group_leave(group);
			} failure:^(NSURLSessionDataTask *task, NSError *error) {
				NSLog(@"%@", error);
				dispatch_group_leave(group);
			}];
		}
		dispatch_group_notify(group, dispatch_get_main_queue(), ^{
			if (completion) completion(bulbs);
		});
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		NSLog(@"%@", error);
	}];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.connectedWatch = PBPebbleCentral.defaultCentral.lastConnectedWatch;
	[self getBulbStates:^(NSArray *bulbStates) {
		self.bulbStates = bulbStates;
		NSMutableArray *paths = [NSMutableArray arrayWithCapacity:bulbStates.count];
		[bulbStates enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:PLFBulbsSectionIndex];
			[paths addObject:path];
		}];
		[self.tableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationAutomatic];
	}];
}

- (void)dealloc
{
	[self.connectedWatch closeSession:nil];
}

#pragma mark - Accessors

- (void)setConnectedWatch:(PBWatch *)connectedWatch
{
	if (_connectedWatch != connectedWatch) {
		_connectedWatch = connectedWatch;
		self.pebbleHandler = [[PLFPebbleAppMessageHandler alloc] initWithWatch:connectedWatch];
		self.pebbleHandler.delegate = self;
	}
}

#pragma mark - PLFAppMessageHandlerDelegate

- (NSArray *)appMessageHandlerHandleBulbRequest:(PLFPebbleAppMessageHandler *)handler
{
	return self.bulbStates;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case PLFPebbleSectionIndex:
			return 1;
		case PLFBulbsSectionIndex:
			return self.bulbStates.count;
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
		case PLFBulbsSectionIndex:
			return NSLocalizedString(@"Bulbs", nil);
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
		case PLFBulbsSectionIndex: {
			PLFBulbTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLFBulbTableViewCellIdentifier];
			LIFXBulbState *state = self.bulbStates[indexPath.row];
			cell.nameLabel.text = state.bulb.name;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PLFColor *color = nil;
	if (indexPath.section == PLFCustomColorsSectionIndex) {
		color = self.colors[indexPath.row];
	} else if (indexPath.section == PLFDefaultColorsSectionIndex) {
		color = self.class.defaultColors[indexPath.row];
	}
	if (color) {
		[self testBulbColor:color.color];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)powerToggle:(id)sender
{
	CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
	NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
	LIFXBulbState *state = self.bulbStates[indexPath.row];

	[self.lifxManager setOn:!state.on forBulb:state.bulb withSuccess:^(NSURLSessionDataTask *task, id responseObject) {
		state.on = !state.on;
	} failure:^(NSURLSessionDataTask *task, NSError *error) {
		NSLog(@"%@", error);
	}];
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
	[self testBulbColor:color];
}

- (void)testBulbColor:(UIColor *)color
{
	if (self.bulbStates.count) {
		// TODO: Fix this to work with all bulbs instead of just the first bulb.
		LIFXBulbState *state = self.bulbStates[0];
		[self.lifxManager setColor:color forBulb:state.bulb withSuccess:nil failure:^(NSURLSessionDataTask *task, NSError *error) {
			NSLog(@"%@", error);
		}];
	}
}

- (void)persistCustomColors
{
	NSUserDefaults.standardUserDefaults.plf_savedColors = self.colors;
}

@end
