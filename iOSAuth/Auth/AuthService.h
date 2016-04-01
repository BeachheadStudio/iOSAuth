//
//  AuthService.h
//  iOSAuth
//
//  Created by SingleMalt on 3/30/16.
//  Copyright © 2016 SingleMalt. All rights reserved.
//

#ifndef AuthService_h
#define AuthService_h

@import GameKit;

@class PlayerInfo;

extern NSString *const PresentAuthViewController;

@interface AuthService : NSObject

@property (nonatomic, readonly) UIViewController *authViewController;
@property (nonatomic, readonly) NSError *lasterror;
@property (nonatomic, readonly) PlayerInfo *playerInfo;
@property (nonatomic, readwrite) BOOL anonymous;

+(instancetype)sharedAuthService;
+(NSArray *)authStatus;
+(NSString *)generateUUID;

-(void)authLocalPlayer;
-(NSString *)getFirstPartyPlayerId;
-(NSString *)getPlayerName;
-(NSString *)getFailureError;
-(NSString *)getPlayerId;
-(BOOL)isAnonymous;

@end

#endif /* AuthService_h */
