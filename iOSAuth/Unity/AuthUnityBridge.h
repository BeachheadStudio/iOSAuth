//
// Created by SingleMalt on 4/1/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#ifndef UnityExtern_h
#define UnityExtern_h


@interface AuthUnityBridge : NSObject

@end

NSString* CreateNSString(const char* string);
const char* CreateConstChar(NSString *string);
char* MakeStringCopy(const char* string);

#if defined __cplusplus
extern "C" {
#endif
void SendUnityMessage(const char *object, const char *method, const char *message);
#if __cplusplus
}
#endif

#if __cplusplus
extern "C" {
#endif

    extern void NativeLog(const char* message);
    extern void AuthLocalPlayer(const char* serverUrl, const char* serverPlayerId);
    extern const char* GetPlayerName();
    extern const char* GetPlayerId();
    extern const char* GetFirstPartyPlayerId();
    extern const char* GetFailureError();
    extern const char* GetSessionToken();
    extern void NativeOnPause();
    extern void NativeOnResume();

#if __cplusplus
}
#endif

#endif /* UnityExtern_h */