//
//  PNSimplePresenceEventsTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/28/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicPresenceTestCase.h"

@interface PNSimplePresenceEventsTests : PNBasicPresenceTestCase
@end

@implementation PNSimplePresenceEventsTests

- (BOOL)isRecording {
    return YES;
}

- (NSArray *)basicChannels {
    return @[
             @"a"
             ];
}

- (NSArray *)basicChannelsWithPresence {
    return [[self basicChannels] arrayByAddingObject:@"a-pnpres"];
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    // ^returnType(parameters) {...};
//    typedef void (^PNOtherClientDidReceiveMessageAssertions)(PubNub *client, PNMessageResult *message);
//    typedef void (^PNOtherClientDidReceivePresenceEventAssertions)(PubNub *client, PNPresenceEventResult *event);
//    typedef void (^PNOtherClientDidReceiveStatusAssertions)(PubNub *client, PNSubscribeStatus *status);
    PNWeakify(self);
    self.didReceiveStatusAssertions = ^void(PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(client);
        XCTAssertEqualObjects(self.client, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        XCTAssertEqualObjects(status.subscribedChannels, [self basicChannelsWithPresence]);
        XCTAssertEqualObjects(status.data.timetoken, @14355573556281159);
        [self.subscribeExpectation fulfill];
    };
    [self PNTest_subscribeToChannels:[self basicChannels] withPresence:YES];
    if (self.invocation.selector == @selector(testLeaveEvent)) {
        [self PNTest_otherSubscribeToChannels:[self basicChannels] withPresence:YES];
        self.otherDidReceiveStatusAssertions = ^void(PubNub *client, PNSubscribeStatus *status) {
            PNStrongify(self);
            XCTAssertNotNil(client);
            XCTAssertEqualObjects(self.otherClient, client);
            XCTAssertNotNil(status);
            XCTAssertFalse(status.isError);
            XCTAssertEqual(status.category, PNConnectedCategory);
            XCTAssertEqual(status.subscribedChannelGroups.count, 0);
            XCTAssertEqualObjects(status.subscribedChannels, [self basicChannelsWithPresence]);
            XCTAssertEqualObjects(status.data.timetoken, @14355573556281159);
            [self.otherSubscribeExpectation fulfill];
        };
    }
}



- (void)testEnterEvent {
    PNWeakify(self);
//    XCTestExpectation *enterExpectation = [self expectationWithDescription:@"enter"];
    self.didReceivePresenceEventAssertions = ^void(PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        XCTAssertNotNil(client);
        [self.otherSubscribeExpectation fulfill];
    };
    self.otherDidReceiveStatusAssertions = ^void(PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(client);
        XCTAssertEqualObjects(self.otherClient, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        XCTAssertEqualObjects(status.subscribedChannels, [self basicChannelsWithPresence]);
        XCTAssertEqualObjects(status.data.timetoken, @14355573556281159);
        [self.otherSubscribeExpectation fulfill];
    };
    [self PNTest_otherSubscribeToChannels:[self basicChannels] withPresence:YES];
//    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
//        XCTAssertNil(error);
//    }];
}

- (void)testLeaveEvent {
    PNWeakify(self);
    self.didReceivePresenceEventAssertions = ^void(PubNub *client, PNPresenceEventResult *event) {
        PNStrongify(self);
        XCTAssertNotNil(client);
        [self.otherUnsubscribeExpectation fulfill];
    };
    self.otherDidReceiveStatusAssertions = ^void(PubNub *client, PNSubscribeStatus *status) {
        PNStrongify(self);
        XCTAssertNotNil(client);
        XCTAssertEqualObjects(self.otherClient, client);
        XCTAssertNotNil(status);
        XCTAssertFalse(status.isError);
        XCTAssertEqual(status.category, PNConnectedCategory);
        XCTAssertEqual(status.subscribedChannelGroups.count, 0);
        XCTAssertEqual(status.subscribedChannels.count, 0);
        XCTAssertEqualObjects(status.data.timetoken, @14355573556281159);
//        [self.otherUnsubscribeExpectation fulfill];
    };
    [self PNTest_otherUnsubscribeFromChannels:[self basicChannels] withPresence:YES];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.didReceivePresenceEventAssertions = nil;
    [self PNTest_unsubscribeFromChannels:[self basicChannels] withPresence:YES];
    [self PNTest_otherUnsubscribeFromChannels:[self basicChannels] withPresence:YES];
    [super tearDown];
}

@end
