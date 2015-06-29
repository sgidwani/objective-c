//
//  PNBasicPresenceTestCase.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/28/15.
//
//

#import "PNBasicPresenceTestCase.h"

@implementation PNBasicPresenceTestCase

- (void)setUp {
    [super setUp];
    PNConfiguration *config = [PNConfiguration configurationWithPublishKey:@"demo-36" subscribeKey:@"demo-36"];
    config.uuid = @"322A70B3-F0EA-48CD-9BB0-D3F1F5DE006C";
    self.otherClient = [PubNub clientWithConfiguration:config];
    [self.otherClient addListener:self];
}

- (void)tearDown {
    [self.otherClient removeListener:self];
    self.otherClient = nil;
    [super tearDown];
}

#pragma mark - Helpers

- (void)PNTest_otherSubscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence {
    self.otherSubscribeExpectation = [self expectationWithDescription:@"otherSubscribe"];
    [self.otherClient subscribeToChannels:channels withPresence:YES];
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_otherUnsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence {
    self.otherUnsubscribeExpectation = [self expectationWithDescription:@"otherUnsubscribe"];
    [self.otherClient unsubscribeFromChannels:channels withPresence:shouldObservePresence];
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_otherSubscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence {
    self.otherChannelGroupSubscribeExpectation = [self expectationWithDescription:@"otherChannelGroupSubscribe"];
    [self.otherClient subscribeToChannelGroups:groups withPresence:shouldObservePresence];
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

- (void)PNTest_unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence {
    self.otherChannelGroupUnsubscribeExpectation = [self expectationWithDescription:@"otherChannelGroupUnsubscribe"];
    [self.otherClient unsubscribeFromChannelGroups:groups withPresence:shouldObservePresence];
    [self waitForExpectationsWithTimeout:15 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNMessageResult *)message {
    if (
        (self.didReceiveMessageAssertions) &&
        (self.client == client)
        ) {
        self.didReceiveMessageAssertions(client, message);
    }
    if ((self.otherDidReceiveMessageAssertions) &&
        (self.otherClient == client)
        ) {
        self.otherDidReceiveMessageAssertions(client, message);
    }
}

- (void)client:(PubNub *)client didReceivePresenceEvent:(PNPresenceEventResult *)event {
    if (self.didReceivePresenceEventAssertions &&
        (self.client == client)
        ) {
        self.didReceivePresenceEventAssertions(client, event);
    }
    if (self.otherDidReceivePresenceEventAssertions &&
        (self.otherClient == client)
        ) {
        self.otherDidReceivePresenceEventAssertions(client, event);
    }
}

- (void)client:(PubNub *)client didReceiveStatus:(PNSubscribeStatus *)status {
    if (self.didReceiveStatusAssertions &&
        (self.client == client)
        ) {
        self.didReceiveStatusAssertions(client, status);
    }
    if (self.otherDidReceiveStatusAssertions &&
        (self.otherClient == client)
        ) {
        self.otherDidReceiveStatusAssertions(client, status);
    }
}

@end
