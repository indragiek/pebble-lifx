//
//  PLFPebbleAppMessageHandler.h
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/9/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

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
@end
