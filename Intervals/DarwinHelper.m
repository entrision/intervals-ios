//
//  DarwinHelper.m
//  Intervals
//
//  Created by Hunter Whittle on 4/21/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

#import "DarwinHelper.h"

@implementation DarwinHelper

+(void)postSequenceLoadNotification {
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.intervals.sequenceLoad"), (__bridge const void *)(self), nil, TRUE);
}

@end
