//
// Created by SingleMalt on 3/31/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AuthUnityBridge.h"
#import "AuthService.h"

@interface AuthUnityBridge () {
}
@end

@implementation AuthUnityBridge

@end

void SendUnityMessage(const char *object, const char *method, const char *message) {
    NSLog(@"Firing event to unity: %@ %@ %@", [NSString stringWithUTF8String:object],
                                              [NSString stringWithUTF8String:method],
                                              [NSString stringWithUTF8String:message]);
#if UNITY_IOS
    UnitySendMessage(object, method, message);
#endif
}

// Converts C style string to NSString
NSString* CreateNSString(const char* string) {
    if (string) {
        return [NSString stringWithUTF8String:string];
    } else {
        return [NSString stringWithUTF8String:""];
    }
}

const char* CreateConstChar(NSString *string) {
    if(string == nil) {
        return "";
    } else {
        return [string UTF8String];
    }
}

// Helper method to create C string copy
char* MakeStringCopy (const char* string)
{
    if (string == NULL) {
        return NULL;
    }

    char* res = (char*)malloc(strlen(string) + 1);
    strcpy(res, string);
    return res;
}

#if __cplusplus
extern "C" {
#endif
    void NativeLog(const char* message) {
        NSLog(@"UnityLog: %@", CreateNSString(message));
    }

    void AuthLocalPlayer(const char* serverUrl, const char* serverPlayerId) {
        [[AuthService sharedAuthService] authLocalPlayer:CreateNSString(serverUrl)
                                          serverPlayerId:CreateNSString(serverPlayerId)];
    }

    const char* GetPlayerName() {
        return MakeStringCopy(CreateConstChar([[AuthService sharedAuthService] getPlayerName]));
    }

    const char* GetPlayerId() {
        return MakeStringCopy(CreateConstChar([[AuthService sharedAuthService] getServerPlayerId]));
    }

    const char* GetFirstPartyPlayerId() {
        return MakeStringCopy(CreateConstChar([[AuthService sharedAuthService] getPlayerId]));
    }

    const char* GetFailureError() {
        return MakeStringCopy(CreateConstChar([[AuthService sharedAuthService] getFailureError]));
    }

    const char* GetSessionToken() {
        return MakeStringCopy(CreateConstChar([[AuthService sharedAuthService] getSessionToken]));
    }

    void NativeOnPause() {
        NSLog(@"Unity: OnPause");
    }

    void NativeOnResume() {
        NSLog(@"Unity: OnResume");
    }

    bool NativeIsAnonymous() {
        return ([[AuthService sharedAuthService] isAnonymous]);
    }

    const char* GetNativeAuthParams() {
        return MakeStringCopy(CreateConstChar([[AuthService sharedAuthService] getAuthParams]));
    }

    void NativeAwardAchievement(const char* achievementId) {
        [[AuthService sharedAuthService] awardAchievement:CreateNSString(achievementId)];
    }

#if __cplusplus
}
#endif
