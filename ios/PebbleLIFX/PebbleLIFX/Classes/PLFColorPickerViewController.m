//
//  PLFColorPickerViewController.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "PLFColorPickerViewController.h"
#import "RSColorPickerView.h"
#import "RSSelectionView.h"
#import "PLFColorView.h"

@interface PLFColorPickerViewController () <RSColorPickerViewDelegate, UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet RSColorPickerView *colorPickerView;
@property (nonatomic, weak) IBOutlet PLFColorView *colorView;
@property (nonatomic, weak) IBOutlet UITextField *labelField;
@end

@implementation PLFColorPickerViewController {
	struct {
		unsigned int didSelectColor:1;
		unsigned int didPickColor:1;
	} _delegateFlags;
}

#pragma mark - View Controller Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.colorPickerView.cropToCircle = YES;
	self.colorPickerView.delegate = self;
	self.colorPickerView.selectionColor = [UIColor redColor];
}

#pragma mark - RSColorPickerDelegate

- (void)colorPickerDidChangeSelection:(RSColorPickerView *)cp
{
	self.selectedColor = cp.selectionColor;
}

#pragma mark - Accessors

- (void)setDelegate:(id<PLFColorPickerViewControllerDelegate>)delegate
{
	if (_delegate != delegate) {
		_delegate = delegate;
		_delegateFlags.didPickColor = [delegate respondsToSelector:@selector(colorPicker:didPickColor:withLabel:)];
		_delegateFlags.didSelectColor = [delegate respondsToSelector:@selector(colorPicker:didSelectColor:)];
	}
}

- (void)setSelectedColor:(UIColor *)selectedColor
{
	if (_selectedColor != selectedColor) {
		_selectedColor = selectedColor;
		self.colorView.color = selectedColor;
		if (_delegateFlags.didSelectColor) {
			[self.delegate colorPicker:self didSelectColor:selectedColor];
		}
	}
}

#pragma mark - Actions

- (IBAction)pickColor:(id)sender
{
	if (_delegateFlags.didPickColor) {
		[self.delegate colorPicker:self didPickColor:self.selectedColor withLabel:self.labelField.text];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancel:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
