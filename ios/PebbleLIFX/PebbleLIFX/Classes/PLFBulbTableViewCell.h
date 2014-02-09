//
//  PLFBulbTableViewCell.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/8/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const PLFBulbTableViewCellIdentifier;

@interface PLFBulbTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@end
