//
//  PNChannelGroupTests.m
//  PubNubTest
//
//  Created by Sergey Kazanskiy on 5/18/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

@interface PNChannelGroupTests : XCTestCase
@property (nonatomic) PubNub *client;
@end

@implementation PNChannelGroupTests

- (void)setUp {
    
    [super setUp];
    
    self.client = [PubNub clientWithPublishKey:@"demo-36" andSubscribeKey:@"demo-36"];
}

- (void)tearDown {
    self.client = nil;
    [super tearDown];
}

- (void)testAddChannelGroups {
    XCTestExpectation *addChannelsExpectation = [self expectationWithDescription:@"add channels"];
    NSString *channel1 = @"a";
    NSString *channel2 = @"c";
    NSString *channelGroup = [[NSUUID UUID] UUIDString];
    [self.client addChannels:@[channel1, channel2] toGroup:channelGroup withCompletion:^(PNStatus *status) {
        XCTAssertFalse(status.error);
        [addChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        XCTAssertNil(error);
    }];
    
    XCTestExpectation *confirmAddedChannelsExpectation = [self expectationWithDescription:@"channels added"];
    [self.client channelsForGroup:channelGroup withCompletion:^(PNResult *result, PNStatus *status) {
        XCTAssertFalse(status.error);
        XCTAssertNotNil(result);
        NSDictionary *data = result.data;
        XCTAssertNotNil(data[@"channels"]);
        NSMutableArray *channelsToCompare = [@[channel1, channel2] mutableCopy];
        for (NSString *channelName in data[@"channels"]) {
            if ([channelsToCompare containsObject:channelName]) {
                [channelsToCompare removeObject:channelName];
            }
        }
        XCTAssertTrue([channelsToCompare count] == 0);
        [confirmAddedChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        XCTAssertNil(error);
    }];
}

- (void)testRemoveSomeChannelsFromChannelGroup {
    XCTestExpectation *addChannelsExpectation = [self expectationWithDescription:@"add channels"];
    NSString *channel1 = @"a";
    NSString *channel2 = @"c";
    NSString *channelGroup = [[NSUUID UUID] UUIDString];
    [self.client addChannels:@[channel1, channel2] toGroup:channelGroup withCompletion:^(PNStatus *status) {
        XCTAssertFalse(status.error);
        [addChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        XCTAssertNil(error);
    }];
    
    XCTestExpectation *removeChannelExpectation = [self expectationWithDescription:@"remove channel"];
    [self.client removeChannels:@[channel1] fromGroup:channelGroup withCompletion:^(PNStatus *status) {
        XCTAssertFalse(status.error);
        [removeChannelExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        XCTAssertNil(error);
    }];
    
    XCTestExpectation *checkChannelsExpectation = [self expectationWithDescription:@"check channel removal"];
    [self.client channelsForGroup:channelGroup withCompletion:^(PNResult *result, PNStatus *status) {
        XCTAssertFalse(status.error);
        XCTAssertNotNil(result);
        NSDictionary *data = result.data;
        XCTAssertNotNil(data[@"channels"]);
        NSArray *channels = data[@"channels"];
        XCTAssertTrue([channels count] == 1);
        XCTAssertTrue([channels containsObject:channel2]);
        XCTAssertFalse([channels containsObject:channel1]);
        [checkChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        XCTAssertNil(error);
    }];
}

- (void)testRemoveAllChannelsFromChannelGroup {
    XCTestExpectation *addChannelsExpectation = [self expectationWithDescription:@"add channels"];
    NSString *channel1 = @"a";
    NSString *channel2 = @"c";
    NSString *channelGroup = [[NSUUID UUID] UUIDString];
    [self.client addChannels:@[channel1, channel2] toGroup:channelGroup withCompletion:^(PNStatus *status) {
        XCTAssertFalse(status.error);
        [addChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        XCTAssertNil(error);
    }];
    
    XCTestExpectation *removeAllChannelsExpectation = [self expectationWithDescription:@"remove channel"];
    [self.client removeChannelsFromGroup:channelGroup withCompletion:^(PNStatus *status) {
        XCTAssertFalse(status.error);
        [removeAllChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        XCTAssertNil(error);
    }];
    
    XCTestExpectation *checkChannelsExpectation = [self expectationWithDescription:@"check channel removal"];
    [self.client channelsForGroup:channelGroup withCompletion:^(PNResult *result, PNStatus *status) {
        XCTAssertFalse(status.error);
        XCTAssertNotNil(result);
        NSDictionary *data = result.data;
        XCTAssertNotNil(data[@"channels"]);
        NSArray *channels = data[@"channels"];
        XCTAssertTrue([channels count] == 0);
        [checkChannelsExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        if (error) {
            NSLog(@"error: %@", error);
        }
        XCTAssertNil(error);
    }];
}

@end
