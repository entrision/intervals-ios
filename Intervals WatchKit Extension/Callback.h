//
//  Callback.h
//  Intervals
//
//  Created by Hunter Whittle on 4/21/15.
//  Copyright (c) 2015 Hunter Whittle. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Callback : NSObject

+(void)addObjectivecObserver:(id)observer;

+(void(*)(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo))callback;

@end
