//
//  PNPublishTest.m
//  PubNubTest
//
//  Created by Jordan Zucker on 5/22/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

@interface PNPublishTest : XCTestCase <PNObjectEventListener>
@property (nonatomic) PubNub *client;
@property (nonatomic) PNResult *mostRecentResult;
@property (nonatomic) PNStatus *mostRecentStatus;
@end

@implementation PNPublishTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.client = [PubNub clientWithPublishKey:@"demo-36" andSubscribeKey:@"demo-36"];
    [self.client addListeners:@[self]];
    self.mostRecentResult = nil;
    self.mostRecentStatus = nil;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [self.client removeListeners:@[self]];
    self.client = nil;
    [super tearDown];
}

- (void)testSimplePublish {
    XCTestExpectation *subscribeToChannelExpectation = [self expectationWithDescription:@"subscribe to channel"];
    NSString *channel = [[NSUUID UUID] UUIDString];
    [self.client subscribeToChannels:@[channel] withPresence:NO andCompletion:^(PNStatus *status) {
        XCTAssertFalse(status.error);
        [subscribeToChannelExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        XCTAssertNil(error);
    }];
    
    NSString *message = [[NSUUID UUID] UUIDString];
    XCTestExpectation *publishExpectation = [self expectationWithDescription:@"publish expectation"];
    [self.client publish:message toChannel:channel withCompletion:^(PNStatus *status) {
        XCTAssertFalse(status.error);
        [publishExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        XCTAssertNil(error);
    }];
    
//    XCTestExpectation *receivedMessageExpectation = [self expectationWithDescription:@"received message"];
//    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
//        if (error) {
//            NSLog(@"error: %@", error);
//        }
//        XCTAssertNil(error);
//    }];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5.0]];
    
    
    XCTAssertFalse(self.mostRecentStatus.error);
    XCTAssertNotNil(self.mostRecentResult);
    XCTAssertNotNil(self.mostRecentResult.data);
    XCTAssertNotNil(self.mostRecentResult.data[@"message"]);
    NSString *returnedMessage = self.mostRecentResult.data[@"message"];
    XCTAssertTrue([message isEqualToString:returnedMessage]);
}

#pragma mark - PNObjectEventListener

- (void)client:(PubNub *)client didReceiveMessage:(PNResult *)message withStatus:(PNStatus *)status {
    self.mostRecentResult = message;
    self.mostRecentStatus = status;
}

- (void)client:(PubNub *)client didReceiveStatus:(PNStatus *)status {
    self.mostRecentStatus = status;
}

@end
