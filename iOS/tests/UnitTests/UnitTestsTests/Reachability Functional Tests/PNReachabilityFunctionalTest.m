//
//  PNReachabilityFunctionalTest.m
//  UnitTests
//
//  Created by Vadim Osovets on 4/7/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "PNReachability+Test.h"

@interface PubNub ()

@property (nonatomic, strong) PNReachability *reachability;

@end


@interface PNReachabilityFunctionalTest : XCTestCase

@end

@implementation PNReachabilityFunctionalTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Tests

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
    
    [PubNub setConfiguration:[PNConfiguration defaultTestConfiguration]];
    
    [PubNub connectWithSuccessBlock:^(NSString *origin) {
        NSLog(@"Origin: %@", origin);
    } errorBlock:^(PNError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    PNChannel *channel = [PNChannel channelWithName:@"test"];
    
    [PubNub subscribeOn:@[channel]];
    
    GCDGroup *group = [GCDGroup group];
    
    [group enter];
    
    [PubNub sendMessage:@"test" toChannel:channel
    withCompletionBlock:^(PNMessageState state, id data) {
        switch (state) {
            case PNMessageSent:
                [group leave];
                break;
            default:
                break;
        }
    }];
    
//    [[[PubNub sharedInstance] reachability] test];
    
    
    if ([GCDWrapper isGCDGroup:group timeoutFiredValue:kTestTestTimout]) {
        XCTFail(@"Timeout to connect to PubNub service");
        return;
    }
    
    NSLog(@"Success.");
}

@end
