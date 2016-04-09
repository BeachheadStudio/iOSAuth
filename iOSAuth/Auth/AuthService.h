//
//  AuthService.h
//  iOSAuth
//
//  Created by SingleMalt on 3/30/16.
//  Copyright © 2016 SingleMalt. All rights reserved.
//

#ifndef AuthService_h
#define AuthService_h

#if !UNITY_IOS
#include "ViewController.h"
#endif

@class PlayerInfo;

extern NSString *const PresentAuthViewController;

@interface AuthService : NSObject

@property (nonatomic, readonly) UIViewController *authViewController;
@property (nonatomic, readonly) NSError *lasterror;
@property (nonatomic, readonly) PlayerInfo *playerInfo;
@property (nonatomic, readonly) BOOL anonymous;
@property (nonatomic, readonly) NSHTTPCookie *httpCookie;
#if !UNITY_IOS
@property (nonatomic, readwrite) ViewController *rootViewController;
#endif

+(instancetype)sharedAuthService;
+(NSArray *)authStatus;

-(void)authLocalPlayer:(NSString *)serverUrl
        serverPlayerId:(NSString *)serverPlayerId;
-(NSString *)getPlayerId;
-(NSString *)getPlayerName;
-(NSString *)getFailureError;
-(NSString *)getServerPlayerId;
-(NSString *)getSessionToken;
-(NSString *)getAuthParams;
#if !UNITY_IOS
-(void)setRootViewController:(ViewController *)controller;
-(void)updateUIText;
#endif
-(BOOL)isAnonymous;
-(void)fireServerRequest;
-(void)awardAchievement:(NSString *)achievementId;

@end

#endif /* AuthService_h */
