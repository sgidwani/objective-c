//
//  PNHistoryTests.m
//  PubNub Tests
//
//  Created by Jordan Zucker on 6/23/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <PubNub/PubNub.h>

#import "PNBasicClientTestCase.h"

@interface PNHistoryTests : PNBasicClientTestCase
@end

@implementation PNHistoryTests

- (BOOL)isRecording {
    return NO;
}

- (void)testHistory {
    XCTestExpectation *historyExpectation = [self expectationWithDescription:@"history"];
    [self.client historyForChannel:@"a" start:@14356962344283504 end:@14356962619609342 withCompletion:^(PNHistoryResult *result, PNErrorStatus *status) {
        XCTAssertNil(status.errorData.information);
        XCTAssertNotNil(result);
        XCTAssertEqual(result.statusCode, 200);
        XCTAssertEqualObjects(result.data.start, @14356962364490888);
        XCTAssertEqualObjects(result.data.end, @14356962609521455);
        XCTAssertEqual(result.operation, PNHistoryOperation);
        // might want to assert message array is exactly equal, for now just get count
        XCTAssertNotNil(result.data.messages);
        XCTAssertEqual(result.data.messages.count, 13);
        NSArray *expectedMessages = @[
                                      @"*********...... 1244 - 2015-06-30 13:30:35",
                                      @"**********..... 1245 - 2015-06-30 13:30:37",
                                      @"***********.... 1246 - 2015-06-30 13:30:39",
                                      @"************... 1247 - 2015-06-30 13:30:41",
                                      @"*************.. 1248 - 2015-06-30 13:30:43",
                                      @"**************. 1249 - 2015-06-30 13:30:45",
                                      @"*************** 1250 - 2015-06-30 13:30:47",
                                      @"*.............. 1251 - 2015-06-30 13:30:49",
                                      @"**............. 1252 - 2015-06-30 13:30:51",
                                      @"***............ 1253 - 2015-06-30 13:30:53",
                                      @"****........... 1254 - 2015-06-30 13:30:55",
                                      @"*****.......... 1255 - 2015-06-30 13:30:58",
                                      @"******......... 1256 - 2015-06-30 13:31:00"
                                      ];
        NSLog(@"result: %@", result.data.messages);
        XCTAssertEqualObjects(result.data.messages, expectedMessages);
        NSLog(@"status: %@", status);
        [historyExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        NSLog(@"error: %@", error);
    }];
    
}

@end
