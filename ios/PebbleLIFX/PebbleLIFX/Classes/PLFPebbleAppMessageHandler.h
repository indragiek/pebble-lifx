//
//  PLFPebbleAppMessageHandler.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/9/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "keys.h"

typedef NS_ENUM(NSInteger, PLFPebbleAppMessageColorType) {
	PLFPebbleAppMessageColorTypeCustom = APPMSG_COLOR_TYPE_CUSTOM,
	PLFPebbleAppMessageColorTypeDefault = APPMSG_COLOR_TYPE_DEFAULT
};

@protocol PLFPebbleAppMessageHandlerDelegate;

@class PBWatch;
@interface PLFPebbleAppMessageHandler : NSObject
@property (nonatomic, strong, readwrite) PBWatch *watch;
@property (nonatomic, assign) id<PLFPebbleAppMessageHandlerDelegate> delegate;
- (id)initWithWatch:(PBWatch *)watch;
@end

@protocol PLFPebbleAppMessageHandlerDelegate <NSObject>
@required
// Return array of LIFXBulbState objects.
- (NSArray *)appMessageHandlerHandleBulbRequest:(PLFPebbleAppMessageHandler *)handler;
- (void)appMessageHandler:(PLFPebbleAppMessageHandler *)handler setOn:(BOOL)on forBulbAtIndex:(NSUInteger)index;
- (void)appMessageHandler:(PLFPebbleAppMessageHandler *)handler setColorAtIndex:(NSUInteger)colorIndex ofType:(PLFPebbleAppMessageColorType)type forBulbAtIndex:(NSUInteger)bulbIndex;
- (NSArray *)appMessageHandler:(PLFPebbleAppMessageHandler *)handler colorsForType:(PLFPebbleAppMessageColorType)type;
@end
