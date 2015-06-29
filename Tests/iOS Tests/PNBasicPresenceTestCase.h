//
//  PNBasicPresenceTestCase.h
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/28/15.
//
//
#import <PubNub/PubNub.h>

#import "PNBasicSubscribeTestCase.h"

typedef void (^PNOtherClientDidReceiveMessageAssertions)(PubNub *client, PNMessageResult *message);
typedef void (^PNOtherClientDidReceivePresenceEventAssertions)(PubNub *client, PNPresenceEventResult *event);
typedef void (^PNOtherClientDidReceiveStatusAssertions)(PubNub *client, PNSubscribeStatus *status);

@class XCTestExpectation;

@interface PNBasicPresenceTestCase : PNBasicSubscribeTestCase <PNObjectEventListener>

@property (nonatomic) PubNub *otherClient;

@property (nonatomic) XCTestExpectation *otherSubscribeExpectation;
@property (nonatomic) XCTestExpectation *otherUnsubscribeExpectation;
@property (nonatomic) XCTestExpectation *otherChannelGroupSubscribeExpectation;
@property (nonatomic) XCTestExpectation *otherChannelGroupUnsubscribeExpectation;

@property (nonatomic, copy) PNOtherClientDidReceiveMessageAssertions otherDidReceiveMessageAssertions;
@property (nonatomic, copy) PNOtherClientDidReceivePresenceEventAssertions otherDidReceivePresenceEventAssertions;
@property (nonatomic, copy) PNOtherClientDidReceiveStatusAssertions otherDidReceiveStatusAssertions;

- (void)PNTest_otherSubscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence;

- (void)PNTest_otherUnsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence;

- (void)PNTest_otherSubscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence;
- (void)PNTest_otherUnsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence;


@end
