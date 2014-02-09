//
//  NSUserDefaults+PLFPreferences.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (PLFPreferences)
@property (nonatomic, copy) NSString *plf_serverAddress;
@property (nonatomic, strong) NSArray *plf_savedColors; // Array of PFColor objects
@end
