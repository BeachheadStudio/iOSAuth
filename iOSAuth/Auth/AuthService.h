//
//  AuthService.h
//  iOSAuth
//
//  Created by SingleMalt on 3/30/16.
//  Copyright © 2016 SingleMalt. All rights reserved.
//

#ifndef AuthService_h
#define AuthService_h

#include "ViewController.h"

@import GameKit;

@class PlayerInfo;

extern NSString *const PresentAuthViewController;

@interface AuthService : NSObject

@property (nonatomic, readonly) UIViewController *authViewController;
@property (nonatomic, readonly) NSError *lasterror;
@property (nonatomic, readonly) PlayerInfo *playerInfo;
@property (nonatomic, readonly) BOOL anonymous;
@property (nonatomic, readonly) NSHTTPCookie *httpCookie;
@property (nonatomic, readwrite) ViewController *rootViewController;

+(instancetype)sharedAuthService;
+(NSArray *)authStatus;
+(NSString *)generateUUID;

-(void)authLocalPlayer:(NSString *)serverUrl;
-(NSString *)getPlayerId;
-(NSString *)getPlayerName;
-(NSString *)getFailureError;
-(NSString *)getServerPlayerId;
-(NSString *)getSessionToken;
-(void)setRootViewController:(ViewController *)controller;
-(void)setServerPlayerId:(NSString *)serverPlayerId;
-(void)updateUIText;
-(BOOL)isAnonymous;
-(void)fireServerRequest;

@end

#endif /* AuthService_h */
