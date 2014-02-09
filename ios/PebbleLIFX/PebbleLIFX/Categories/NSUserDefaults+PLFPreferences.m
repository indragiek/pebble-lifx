//
//  NSUserDefaults+PLFPreferences.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "NSUserDefaults+PLFPreferences.h"

static NSString * const PLFPreferencesServerAddressKey = @"ServerAddress";

@implementation NSUserDefaults (PLFPreferences)

- (NSString *)plf_serverAddress
{
	return [self objectForKey:PLFPreferencesServerAddressKey];
}

- (void)setPlf_serverAddress:(NSString *)plf_serverAddress
{
	[self setObject:plf_serverAddress forKey:PLFPreferencesServerAddressKey];
}

@end
