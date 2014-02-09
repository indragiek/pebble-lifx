//
//  PLFPebbleAppMessageHandler.m
//  PebbleLIFX
//
//  Created by Indragie Karunaratne on 2/9/2014.
//  Copyright (c) 2014 Indragie Karunaratne. All rights reserved.
//

#import "PLFPebbleAppMessageHandler.h"
#import "LIFXBulbState.h"
#import "LIFXBulbStub.h"
#import "PLFColor.h"
#import "keys.h"
#import <PebbleKit/PebbleKit.h>

static NSString * const PLFPebbleAppUUID = @"ed8b83a3-ecf9-4295-935f-127a1f465b96";

typedef void(^PLFPebbleAppMessageOnSent)(PBWatch *, NSDictionary *, NSError *);

@interface PLFPebbleAppMessageUpdate : NSObject
@property (nonatomic, strong) NSDictionary *dictionary;
@property (nonatomic, copy) PLFPebbleAppMessageOnSent onSent;
+ (instancetype)updateWithDictionary:(NSDictionary *)dictionary onSent:(PLFPebbleAppMessageOnSent)onSent;
@end

@implementation PLFPebbleAppMessageUpdate
+ (instancetype)updateWithDictionary:(NSDictionary *)dictionary onSent:(PLFPebbleAppMessageOnSent)onSent
{
	PLFPebbleAppMessageUpdate *update = [[self alloc] init];
	update.dictionary = dictionary;
	update.onSent = onSent;
	return update;
}
@end

@interface PLFPebbleAppMessageHandler ()
@property (nonatomic, strong) id updateHandler;
@property (nonatomic, strong) NSData *UUIDData;
@property (nonatomic, strong, readonly) NSMutableArray *updateQueue;
@property (nonatomic, strong, readonly) NSMutableSet *updateOutbox;
@end

@implementation PLFPebbleAppMessageHandler

#pragma mark - Initialization

- (id)initWithWatch:(PBWatch *)watch
{
	if ((self = [super init])) {
		_updateQueue = [NSMutableArray array];
		_updateOutbox = [NSMutableSet set];
		_watch = watch;
		[watch appMessagesGetIsSupported:^(PBWatch *pebble, BOOL isAppMessagesSupported) {
			if (isAppMessagesSupported) {
				[self registerForUpdates];
			}
		}];
	}
	return self;
}

- (void)registerForUpdates
{
	NSUUID *UUID = [[NSUUID alloc] initWithUUIDString:PLFPebbleAppUUID];
	uuid_t UUIDBytes;
	[UUID getUUIDBytes:UUIDBytes];
	self.UUIDData = [NSData dataWithBytes:UUIDBytes length:16];
	
	__weak __typeof(self) weakSelf = self;
	self.updateHandler = [self.watch appMessagesAddReceiveUpdateHandler:^BOOL(PBWatch *watch, NSDictionary *update) {
		__typeof(self) strongSelf = weakSelf;
		[strongSelf handleAppMessage:update];
		return YES;
	} withUUID:self.UUIDData];
}

#pragma mark - Cleanup

- (void)dealloc
{
	[self.watch appMessagesRemoveUpdateHandler:self.updateHandler];
}

#pragma mark - Messages

- (void)handleAppMessage:(NSDictionary *)update
{
	NSString *method = update[@(APPMSG_METHOD_KEY)];
	if ([method isEqualToString:@(APPMSG_METHOD_GET_BULBS)]) {
		[self handleBulbRequest];
	} else if ([method isEqualToString:@(APPMSG_METHOD_UPDATE_BULB_STATE)]) {
		[self handleBulbStateUpdate:update];
	} else if ([method isEqualToString:@(APPMSG_METHOD_GET_COLORS)]) {
		[self handleColorRequest:update];
	} else if ([method isEqualToString:@(APPMSG_METHOD_UPDATE_BULB_COLOR)]) {
		[self handleBulbColorUpdate:update];
	}
}

- (void)handleBulbRequest
{
	NSArray *bulbStates = [self.delegate appMessageHandlerHandleBulbRequest:self];
	if (bulbStates.count) {
		NSDictionary *begin = @{@(APPMSG_METHOD_KEY) : @(APPMSG_METHOD_BEGIN_RELOAD_BULBS),
								@(APPMSG_COUNT_KEY) : @(bulbStates.count)};
		[self queueUpdate:begin onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
			if (error != nil) {
				NSLog(@"%@", error);
			}
			for (LIFXBulbState *state in bulbStates) {
				NSDictionary *update = @{@(APPMSG_METHOD_KEY): @(APPMSG_METHOD_RECEIVE_BULB),
										 @(APPMSG_INDEX_KEY) : @(state.bulb.index),
										 @(APPMSG_BULB_STATE_KEY) : @(state.on),
										 @(APPMSG_LABEL_KEY) : state.label};
				[self queueUpdate:update onSent:nil];
			}
			NSDictionary *end = @{@(APPMSG_METHOD_KEY) : @(APPMSG_METHOD_END_RELOAD_BULBS)};
			[self queueUpdate:end onSent:nil];
		}];
	}
}

- (void)handleBulbStateUpdate:(NSDictionary *)update
{
	BOOL state = [update[@(APPMSG_BULB_STATE_KEY)] boolValue];
	NSUInteger index = [update[@(APPMSG_INDEX_KEY)] unsignedIntegerValue];
	[self.delegate appMessageHandler:self setOn:state forBulbAtIndex:index];
}

- (void)handleColorRequest:(NSDictionary *)update
{
	PLFPebbleAppMessageColorType colorType = [update[@(APPMSG_COLOR_TYPE_KEY)] integerValue];
	NSArray *colors = [self.delegate appMessageHandler:self colorsForType:colorType];
	if (colors.count) {
		NSDictionary *begin = @{@(APPMSG_METHOD_KEY) : @(APPMSG_METHOD_BEGIN_RELOAD_COLORS),
								@(APPMSG_COUNT_KEY) : @(colors.count),
								@(APPMSG_COLOR_TYPE_KEY) : @(colorType)};
		[self queueUpdate:begin onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
			if (error != nil) {
				NSLog(@"%@", error);
			}
			[colors enumerateObjectsUsingBlock:^(PLFColor *color, NSUInteger idx, BOOL *stop) {
				NSDictionary *update = @{@(APPMSG_METHOD_KEY) : @(APPMSG_METHOD_RECEIVE_COLOR),
										 @(APPMSG_INDEX_KEY) : @(idx),
										 @(APPMSG_LABEL_KEY) : color.label,
										 @(APPMSG_COLOR_TYPE_KEY) : @(colorType)};
				[self queueUpdate:update onSent:nil];
				*stop = YES;
			}];
			NSDictionary *end = @{@(APPMSG_METHOD_KEY) : @(APPMSG_METHOD_END_RELOAD_COLORS),
								  @(APPMSG_COLOR_TYPE_KEY) : @(colorType)};
			[self queueUpdate:end onSent:^(PBWatch *watch, NSDictionary *dict, NSError *error) {
				NSLog(@"Sent: %@", error);
			}];
		}];
	}
}

- (void)handleBulbColorUpdate:(NSDictionary *)update
{
	NSUInteger colorIndex = [update[@(APPMSG_COLOR_INDEX_KEY)] unsignedIntegerValue];
	NSUInteger bulbIndex = [update[@(APPMSG_INDEX_KEY)] unsignedIntegerValue];
	PLFPebbleAppMessageColorType type = [update[@(APPMSG_COLOR_TYPE_KEY)] integerValue];
	[self.delegate appMessageHandler:self setColorAtIndex:colorIndex ofType:type forBulbAtIndex:bulbIndex];
}

#pragma mark - Queueing

- (void)queueUpdate:(NSDictionary *)dict onSent:(PLFPebbleAppMessageOnSent)onSent
{
	PLFPebbleAppMessageUpdate *update = [PLFPebbleAppMessageUpdate updateWithDictionary:dict onSent:onSent];
	[self.updateQueue addObject:update];
	if (self.updateOutbox.count) {
		// Gross way of trying to make sure that the Pebble's inbound buffer does not get
		// overloaded from too many successive updates.
		dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC));
		dispatch_after(time, dispatch_get_main_queue(), ^{
			[self pushNextUpdate];
		});
	} else {
		[self pushNextUpdate];
	}
}

- (void)pushNextUpdate
{
	if (self.updateQueue.count == 0) return;
	PLFPebbleAppMessageUpdate *update = self.updateQueue.firstObject;
	[self.watch appMessagesPushUpdate:update.dictionary withUUID:self.UUIDData onSent:^(PBWatch *watch, NSDictionary *dict, NSError *error) {
		[self.updateOutbox removeObject:update];
		if (update.onSent) update.onSent(watch, dict, error);
	}];
	[self.updateOutbox addObject:update];
	[self.updateQueue removeObjectAtIndex:0];
}

@end
