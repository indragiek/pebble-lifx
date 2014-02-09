//
//  PLFColorPickerViewController.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PLFColorPickerViewControllerDelegate;
@interface PLFColorPickerViewController : UIViewController
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, assign) IBOutlet id<PLFColorPickerViewControllerDelegate> delegate;
@end

@protocol PLFColorPickerViewControllerDelegate <NSObject>
@optional
- (void)colorPicker:(PLFColorPickerViewController *)picker didSelectColor:(UIColor *)color;
- (void)colorPicker:(PLFColorPickerViewController *)picker didPickColor:(UIColor *)color withLabel:(NSString *)label;
@end