//
//  AuthService.m
//  iOSAuth
//
//  Created by SingleMalt on 3/30/16.
//  Copyright © 2016 SingleMalt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

#import "AuthService.h"
#import "PlayerInfo.h"
#import "AuthUnityBridge.h"
#import "HTTPHelper.h"
#if UNITY_IOS
#import "UnityInterface.h"
#endif

NSString *const PresentAuthViewController = @"present_authentication_view_controller";

@implementation AuthService {
    BOOL _gcModalShown;
    BOOL _gcAuthed;
    BOOL _cancelled;
    BOOL _serverAuthed;
    NSURL *_serverUrl;
    NSString *_serverPlayerId;
}

+(instancetype)sharedAuthService
{
    static AuthService *sharedAuthService;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedAuthService = [[AuthService alloc] init];
    });

    return sharedAuthService;
}

-(id)init
{
    self = [super init];
    if(self) {
        _gcModalShown = NO;
        _gcAuthed = NO;
        _anonymous = YES;
        _cancelled = NO;
        _serverAuthed = NO;
    }

    return self;
}

+ (NSArray *)authStatus {
    static NSArray *values;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,  ^{
        values = @[@"Working", @"Success", @"Failure", @"Cancel"];
    });

    return values;
}

-(void)authLocalPlayer:(NSString *)serverUrl
        serverPlayerId:(NSString *)serverPlayerId
{
    NSLog(@"Starting auth");
    _serverUrl = [NSURL URLWithString:serverUrl];
    _serverPlayerId = serverPlayerId;

    if(_gcModalShown) {
        NSLog(@"Already server authed");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]];
        return;
    }

    if(_serverAuthed) {
        NSLog(@"Already server authed");
        return;
    }

    if(_playerInfo != nil) {
        NSLog(@"Local player info already exists");
        [self fireServerRequest];
        return;
    }

    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        NSLog(@"Starting authenticateHandler");

        if(_serverAuthed && [[GKLocalPlayer localPlayer] isAuthenticated]) {
            NSLog(@"Already server authed");
            return;
        } else {
            _serverAuthed = NO;
        }

        [self setLasterror:error];

        if(viewController != nil) {
            [self setAuthViewController:viewController];
        } else if([[GKLocalPlayer localPlayer] isAuthenticated]) {
            NSLog(@"Player is authenticated");
            _gcAuthed = YES;
            _anonymous = NO;
            _gcModalShown = NO;

            [localPlayer generateIdentityVerificationSignatureWithCompletionHandler:^
            (NSURL *publicKeyUrl, NSData *signature, NSData *salt, uint64_t timestamp, NSError *error_)
            {
                if(error_ != nil)
                {
                    _gcAuthed = NO;
                    _anonymous = YES;

                    NSLog(@"GameCenter auth failure: %@ ", error);
                    _lasterror = error;

                    [self setPlayerInfo:[[PlayerInfo alloc] initWithId:@""
                                                        serverPlayerId:_serverPlayerId
                                                                   url:nil
                                                             signature:nil
                                                                  salt:nil
                                                             timestamp:0
                                                                  name:localPlayer.alias
                                                              bundleId:[[NSBundle mainBundle] bundleIdentifier]]];
#if !UNITY_IOS
                    [self updateUIText];
#endif
                    [self fireServerRequest];
                } else {
                    NSLog(@"generated player info");
                    [self setPlayerInfo:[[PlayerInfo alloc] initWithId:localPlayer.playerID
                                                        serverPlayerId:_serverPlayerId
                                                                   url:publicKeyUrl
                                                             signature:signature
                                                                  salt:salt
                                                             timestamp:timestamp
                                                                  name:localPlayer.alias
                                                              bundleId:[[NSBundle mainBundle] bundleIdentifier]]];
#if !UNITY_IOS
                    [self updateUIText];
#endif
                    [self fireServerRequest];
                }
            }];

        } else {
            NSLog(@"player cancelled");
            _gcAuthed = NO;
            _anonymous = YES;
            _gcModalShown = YES;

            [self setPlayerInfo:[[PlayerInfo alloc] initWithId:@""
                                                serverPlayerId:_serverPlayerId
                                                           url:nil
                                                     signature:nil
                                                          salt:nil
                                                     timestamp:0
                                                          name:@""
                                                      bundleId:[[NSBundle mainBundle] bundleIdentifier]]];
#if !UNITY_IOS
            [self updateUIText];
#endif
            [self fireServerRequest];
        }
    };
}

- (NSString *)getPlayerId {
    if (_playerInfo == nil) {
        return @"";
    } else {
        return _playerInfo.playerId;
    }
}

- (NSString *)getPlayerName {
    if (_playerInfo == nil) {
        return @"";
    } else {
        return _playerInfo.playerName;
    }
}

- (NSString *)getFailureError {
    if(_lasterror == nil) {
        return @"";
    } else {
        NSString *errorStr = [[_lasterror userInfo] description];
        return [NSString stringWithUTF8String:[errorStr UTF8String]];
    }
}

- (NSString *)getSessionToken {
    if(_httpCookie != nil) {
        return _httpCookie.value;
    } else {
        return @"";
    }
}

- (NSString *)getAuthParams {
    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    if([localPlayer isAuthenticated]) {
        NSError *error;
        NSMutableDictionary *dict = [_playerInfo convertToDict];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];

        if(error != nil) {
            [NSException raise:@"Could not turn object into JSON" format:@"object of %@ is invalid", dict];
        }

        char lastByte;
        [jsonData getBytes:&lastByte
                     range:NSMakeRange([jsonData length]-1, 1)];
        if (lastByte == 0x0) {
            // string is null terminated
            return [NSString stringWithUTF8String:[jsonData bytes]];
        } else {
            // string is not null terminated
            return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    } else {
        return @"";
    }
}


- (NSString *)getServerPlayerId {
    return _serverPlayerId;
}

- (BOOL)isAnonymous {
    if(_gcAuthed) {
        return _anonymous;
    } else {
        return YES;
    }
}

- (void)fireServerRequest {
    [HTTPHelper HTTPRequest:_serverUrl
                     method:POST
                       body:[_playerInfo convertToDict]
                      block:^(NSData *data, NSURLResponse *response, NSError *blockerror) {
                          NSLog(@"response from server");
                          if (blockerror != nil) {
                              _lasterror = blockerror;
                              NSLog(@"%@", [self getFailureError]);

                              SendUnityMessage("AuthGameObject", "LoginResult", [AuthService.authStatus[2] UTF8String]);
#if !UNITY_IOS
                              [self updateUIText];
#endif
                              return;
                          }

                          NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *) response;
                          NSInteger statusCode = HTTPResponse.statusCode;

                          if (statusCode != 200) {
                              NSLog(@"AuthServer call failed");

                              SendUnityMessage("AuthGameObject", "LoginResult", [AuthService.authStatus[2] UTF8String]);
#if !UNITY_IOS
                              [self updateUIText];
#endif
                              return;
                          }

                          NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[HTTPResponse allHeaderFields]
                                                                                    forURL:_serverUrl];
                          for (NSHTTPCookie *cookie in cookies) {
                              if([cookie.name isEqualToString:@"session-token"]) {
                                  _httpCookie = cookie;
                              }
                          }

                          NSError *parseError = nil;
                          NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:NSJSONReadingMutableContainers
                                                                                        error:&parseError];

                          if(parseError == nil) {
                              _serverPlayerId = dict[@"realPlayerID"];
                              _playerInfo.playerName = dict[@"playerName"];
                              _anonymous = [dict[@"isAnonymous"] boolValue];

                              _serverAuthed = YES;
                          } else {
                              [self setLasterror:parseError];
                          }

                          if(_cancelled) {
                              SendUnityMessage("AuthGameObject", "LoginResult", [AuthService.authStatus[3] UTF8String]);
                          } else if(parseError != nil) {
                              SendUnityMessage("AuthGameObject", "LoginResult", [AuthService.authStatus[2] UTF8String]);
                          } else {
                              SendUnityMessage("AuthGameObject", "LoginResult", [AuthService.authStatus[1] UTF8String]);
                          }
#if !UNITY_IOS
                          [self updateUIText];
#endif

                      }];
}

- (void)awardAchievement:(NSString *)achievementId {
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier:achievementId];

    if(achievement == nil) {
        NSLog(@"Achievement %@ doesn't exist", achievementId);
        return;
    }

    achievement.showsCompletionBanner = YES;
    achievement.percentComplete = 100.0;

    NSArray<GKAchievement *> *achievements = @[achievement];
    [GKAchievement reportAchievements:achievements
                withCompletionHandler:^(NSError *error) {
                    if(error != nil) {
                        _lasterror = error;
                        NSLog(@"Error awarding achievement: %@", [[_lasterror userInfo] description]);
                    }
                }];
}


-(void)setAuthViewController:(UIViewController *)authViewController
{
    if(authViewController != nil) {
        _authViewController = authViewController;

        _gcModalShown = YES;
#if UNITY_IOS
        [UnityGetGLViewController() presentViewController:_authViewController
                                                 animated:YES
                                               completion:nil];
#else
        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthViewController object:self];
#endif

    }
}

-(void)setLasterror:(NSError *)lasterror
{
    _lasterror = lasterror;
    if(_lasterror) {
        NSLog(@"GameCenter auth failure: %@ ", [[_lasterror userInfo] description]);
    }
}

-(void)setPlayerInfo:(PlayerInfo *)playerInfo {
    if(_playerInfo.playerId != nil) {
        if(_playerInfo.playerId != playerInfo.playerId) {
            SendUnityMessage("AuthGameObject", "PlayerChange", "true");
        }
    }

    _playerInfo = playerInfo;
}

-(void)resetServerAuth
{
    NSLog(@"resetServerAuth");
    _serverAuthed = NO;
}

#if !UNITY_IOS
- (void)setRootViewController:(ViewController *)controller {
    _rootViewController = controller;
}

-(void)updateUIText {
    if(_rootViewController != nil) {
        [_rootViewController updateTextViews];
    }
}
#endif

@end
