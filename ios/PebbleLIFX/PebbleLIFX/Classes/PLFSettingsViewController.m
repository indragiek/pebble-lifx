//
//  PLFSettingsViewController.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "PLFSettingsViewController.h"
#import "PLFSettingTableViewCell.h"
#import "NSUserDefaults+PLFPreferences.h"

@interface PLFSettingsViewController () <UITextFieldDelegate>
@end

@implementation PLFSettingsViewController

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	UIBarButtonItem *done = self.navigationItem.rightBarButtonItem;
	done.target = self;
	done.action = @selector(dismiss);
}

- (void)dismiss
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return NSLocalizedString(@"Server Address", nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return NSLocalizedString(@"Server Description", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PLFSettingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
	cell.textField.placeholder = NSLocalizedString(@"Server Address", nil);
	cell.textField.text = NSUserDefaults.standardUserDefaults.plf_serverAddress;
	return cell;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	NSUserDefaults.standardUserDefaults.plf_serverAddress = textField.text;
}

@end
