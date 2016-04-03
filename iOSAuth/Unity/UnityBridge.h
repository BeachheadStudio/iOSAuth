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

    extern void nativeLog(const char* message);
    extern void Init(const char* serverUrl);
    extern const char* PlayerName();
    extern const char* PlayerId();
    extern const char* FirstPartyPlayerId();
    extern const char* FailureError();
    extern const char* SessionToken();
    extern void OnPause();
    extern void OnResume();

#if __cplusplus
}
#endif

#endif /* UnityExtern_h */