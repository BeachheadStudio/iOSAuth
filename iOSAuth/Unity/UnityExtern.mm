//
// Created by SingleMalt on 3/31/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UnityExtern.h"

@implementation UnityExtern

+ (void)sendUnityMessage:(NSString *)object
                  method:(NSString *)method
                 message:(NSString *)message {
    NSLog(@"Firing event to unity: %@ %@ %@", object, method, message);
#if UNITY_5
    UnitySendMessage([object UTF8String],[method UTF8String], [message UTF8String]);
#endif
}

@end
