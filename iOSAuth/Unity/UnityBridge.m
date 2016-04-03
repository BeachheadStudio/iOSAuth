//
// Created by SingleMalt on 3/31/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UnityBridge.h"
#import "AuthService.h"

@implementation UnityBridge

@end

void sendUnityMessage(const char* object, const char* method, const char* message) {
    NSLog(@"Firing event to unity: %@ %@ %@", [NSString stringWithUTF8String:object],
                                              [NSString stringWithUTF8String:method],
                                              [NSString stringWithUTF8String:message]);
#if UNITY_5
    UnitySendMessage([object UTF8String],[method UTF8String], [message UTF8String]);
#endif
}

#if __cplusplus
extern "C" {
#endif
    extern void nativeLog(const char* message) {
        NSLog(@"UnityLog: %@", [NSString stringWithUTF8String:message]);
    }

    extern void Init(const char* serverUrl) {
        [[AuthService sharedAuthService] authLocalPlayer:[NSString stringWithUTF8String:serverUrl]];
    }

    extern const char* PlayerName() {
        return [[[AuthService sharedAuthService] getPlayerName] UTF8String];
    }

    extern const char* PlayerId() {
        return [[[AuthService sharedAuthService] getServerPlayerId] UTF8String];
    }

    extern const char* FirstPartyPlayerId() {
        return [[[AuthService sharedAuthService] getPlayerId] UTF8String];
    }

    extern const char* FailureError() {
        return [[[AuthService sharedAuthService] getFailureError] UTF8String];
    }

    extern const char* SessionToken() {
        return [[[AuthService sharedAuthService] getPlayerName] UTF8String];
    }

    extern void OnPause() {
        NSLog(@"Unity: OnPause");
    }

    extern void OnResume() {
        NSLog(@"Unity: OnResume");
    }

#if __cplusplus
}
#endif
