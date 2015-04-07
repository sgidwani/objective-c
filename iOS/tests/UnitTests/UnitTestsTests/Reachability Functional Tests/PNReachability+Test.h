//
//  PNReachability+Test.h
//  UnitTests
//
//  Created by Vadim Osovets on 4/7/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import "PNReachability.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface PNReachability (Test)

- (SCNetworkConnectionFlags)synchronousStatusFlags;

- (void)test;

@end
