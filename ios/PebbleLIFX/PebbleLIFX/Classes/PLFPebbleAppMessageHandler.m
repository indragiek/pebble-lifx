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
	}
}

- (void)handleBulbRequest
{
	NSArray *bulbStates = [self.delegate appMessageHandlerHandleBulbRequest:self];
	if (bulbStates.count) {
		NSDictionary *begin = @{@(APPMSG_METHOD_KEY) : @(APPMSG_METHOD_BEGIN_RELOAD_BULBS),
								@(APPMSG_COUNT_KEY) : @(bulbStates.count)};
		[self queueUpdate:begin onSent:^(PBWatch *watch, NSDictionary *update, NSError *error) {
			if (error != nil) return;
			for (LIFXBulbState *state in bulbStates) {
				NSDictionary *update = @{@(APPMSG_METHOD_KEY): @(APPMSG_METHOD_RECEIVE_BULB),
										 @(APPMSG_BULB_INDEX_KEY) : @(state.bulb.index),
										 @(APPMSG_BULB_STATE_KEY) : @(state.on),
										 @(APPMSG_BULB_LABEL_KEY) : state.label};
				[self queueUpdate:update onSent:nil];
			}
			NSDictionary *end = @{@(APPMSG_METHOD_KEY) : @(APPMSG_METHOD_END_RELOAD_BULBS)};
			[self queueUpdate:end onSent:nil];
		}];
	}
}

#pragma mark - Queueing

- (void)queueUpdate:(NSDictionary *)dict onSent:(PLFPebbleAppMessageOnSent)onSent
{
	PLFPebbleAppMessageUpdate *update = [PLFPebbleAppMessageUpdate updateWithDictionary:dict onSent:onSent];
	[self.updateQueue addObject:update];
	if (self.updateOutbox.count) {
		// Gross way of trying to make sure that the Pebble's inbound buffer does not get
		// overloaded from too many successive updates.
		dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
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
