//
// Created by SingleMalt on 4/1/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#ifndef UnityExtern_h
#define UnityExtern_h


@interface UnityBridge : NSObject

@end

void sendUnityMessage(const char* object, const char* method, const char* message);

#if __cplusplus
extern "C" {
#endif

    extern void NativeLog(const char* message);
    extern void AuthLocalPlayer(const char* serverUrl);
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