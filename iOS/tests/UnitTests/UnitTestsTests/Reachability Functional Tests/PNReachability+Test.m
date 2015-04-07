//
//  PNReachability+Test.m
//  UnitTests
//
//  Created by Vadim Osovets on 4/7/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import "PNReachability+Test.h"

@interface PNReachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef serviceReachability;

+ (SCNetworkReachabilityRef)newReachabilityForWiFi:(BOOL)wifiReachability;

@end

@implementation PNReachability (Test)

- (SCNetworkConnectionFlags)synchronousStatusFlags {
    
    SCNetworkConnectionFlags reachabilityFlags;
    
    // Fetch cellular data reachability status
    SCNetworkReachabilityRef internetReachability = [[self class] newReachabilityForWiFi:NO];
    SCNetworkReachabilityGetFlags(internetReachability, &reachabilityFlags);
//    PNReachabilityStatus reachabilityStatus = PNReachabilityStatusForFlags(reachabilityFlags);
//    if (reachabilityStatus == PNReachabilityStatusUnknown || reachabilityStatus == PNReachabilityStatusNotReachable) {
//        
//        // Fetch WiFi reachability status
//        SCNetworkReachabilityRef wifiReachability = [[self class] newReachabilityForWiFi:YES];
//        SCNetworkReachabilityGetFlags(wifiReachability, &reachabilityFlags);
//        CFRelease(wifiReachability);
//    }
//    
//    CFRelease(internetReachability);
    
    
    return reachabilityFlags;
}

void PNReachabilityCallback(SCNetworkReachabilityRef reachability __unused, SCNetworkReachabilityFlags flags, void *info);

- (void)test {
    PNReachabilityCallback(self.serviceReachability, 2, NULL);
}

@end
