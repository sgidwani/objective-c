//
//  PNTestHelper.m
//  PubNubTest
//
//  Created by Jordan Zucker on 5/22/15.
//  Copyright (c) 2015 Vadim Osovets. All rights reserved.
//

#import "PNTestHelper.h"

static NSString * const letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

@implementation PNTestHelper

+ (NSString *)randomString:(NSInteger)length {
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    
    for (int i=0; i<length; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

@end
