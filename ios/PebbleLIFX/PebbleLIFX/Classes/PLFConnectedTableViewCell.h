//
//  PLFConnectedTableViewCell.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const PLFConnectedTableViewCellIdentifier;

@interface PLFConnectedTableViewCell : UITableViewCell
@property (nonatomic, assign) BOOL connected;
@property (nonatomic, copy) NSString *pebbleName;
@end
