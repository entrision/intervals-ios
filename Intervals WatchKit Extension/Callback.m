//
//  Callback.m
//  Intervals
//
//  Created by Hunter Whittle on 4/21/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

#import "Callback.h"
#import "Intervals_WatchKit_Extension-Swift.h"

static void method(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    
    InterfaceController *controller = (__bridge InterfaceController *)observer;
    [controller sequenceLoaded];
}

@implementation Callback

+(void)objectivecObserver:(id)observer {

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), (__bridge const void *)(observer), self.callback, CFSTR("com.intervals.sequenceLoad"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
}

+ (void(*)(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo))callback {
    return method;
}

@end
