//
//  NSUserDefaults+PLFPreferences.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "NSUserDefaults+PLFPreferences.h"
#import "PLFColor.h"

static NSString * const PLFPreferencesServerAddressKey = @"ServerAddress";
static NSString * const PLFPreferencesSavedColorsKey = @"SavedColors";

@implementation NSUserDefaults (PLFPreferences)

- (NSString *)plf_serverAddress
{
	return [self objectForKey:PLFPreferencesServerAddressKey];
}

- (void)setPlf_serverAddress:(NSString *)plf_serverAddress
{
	[self setObject:plf_serverAddress forKey:PLFPreferencesServerAddressKey];
}

- (NSArray *)plf_savedColors
{
	NSArray *colorData = [self arrayForKey:PLFPreferencesSavedColorsKey];
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:colorData.count];
	for (NSData *data in colorData) {
		PLFColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:data];
		if (color) [colors addObject:color];
	}
	return colors;
}

- (void)setPlf_savedColors:(NSArray *)plf_savedColors
{
	NSMutableArray *colorData = [NSMutableArray arrayWithCapacity:plf_savedColors.count];
	for (PLFColor *color in plf_savedColors) {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:color];
		if (data) [colorData addObject:data];
	}
	[self setObject:colorData forKey:PLFPreferencesSavedColorsKey];
}

@end
