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

- (void)callbackReachabilityWithFlags:(SCNetworkConnectionFlags)flags {
    
    /*
     kSCNetworkReachabilityFlagsTransientConnection	= 1<<0,
     kSCNetworkReachabilityFlagsReachable		= 1<<1,
     kSCNetworkReachabilityFlagsConnectionRequired	= 1<<2,
     kSCNetworkReachabilityFlagsConnectionOnTraffic	= 1<<3,
     kSCNetworkReachabilityFlagsInterventionRequired	= 1<<4,
     kSCNetworkReachabilityFlagsConnectionOnDemand	= 1<<5,	// __OSX_AVAILABLE_STARTING(__MAC_10_6,__IPHONE_3_0)
     kSCNetworkReachabilityFlagsIsLocalAddress	= 1<<16,
     kSCNetworkReachabilityFlagsIsDirect		= 1<<17,
     #if	TARGET_OS_IPHONE
     kSCNetworkReachabilityFlagsIsWWAN		= 1<<18,
     #endif	// TARGET_OS_IPHONE
     
     kSCNetworkReachabilityFlagsConnectionAutomatic	= kSCNetworkReachabilityFlagsConnectionOnTraffic
     */
    
    
    PNReachabilityCallback(self.serviceReachability, 0, NULL);
}

@end
