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
#import "UnityBridge.h"
#import "HTTPHelper.h"

NSString *const PresentAuthViewController = @"present_authentication_view_controller";

@implementation AuthService {
    BOOL _gcAuthed;
    BOOL _serverAuthed;
    BOOL _cancelled;
    NSURL *_serverUrl;
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
        _gcAuthed = NO;
        _serverAuthed = NO;
        _anonymous = YES;
        _cancelled = NO;
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

+ (NSString *)generateUUID {
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    NSString *uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);

    return uuidStr;
}

-(void)authLocalPlayer:(NSString *)serverUrl
{
    NSLog(@"Starting auth");
    _serverUrl = [NSURL URLWithString:serverUrl];
    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        NSLog(@"Starting authenticateHandler");
        [self setLasterror:error];
        
        if(viewController != nil) {
            [self setAuthViewController:viewController];
            return;
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
            NSLog(@"Player is authenticated");
            _gcAuthed = YES;
            _anonymous = NO;

            [localPlayer generateIdentityVerificationSignatureWithCompletionHandler:^
            (NSURL *publicKeyUrl, NSData *signature, NSData *salt, uint64_t timestamp, NSError *error_)
            {
                if(error_ != nil)
                {
                    _gcAuthed = NO;
                    _anonymous = YES;

                    NSLog(@"GameCenter auth failure: %@ ", error);
                    _lasterror = error;

                    _playerInfo = [[PlayerInfo alloc] initWithId:[AuthService generateUUID]
                                                             url:publicKeyUrl
                                                       signature:signature
                                                            salt:salt
                                                       timestamp:timestamp
                                                            name:localPlayer.alias
                                                        bundleId:[[NSBundle mainBundle] bundleIdentifier]];
#if !UNITY_IOS
                    [self updateUIText];
#endif
                    [self fireServerRequest];
                } else {
                    NSLog(@"generated player info");
                    _playerInfo = [[PlayerInfo alloc] initWithId:localPlayer.playerID
                                                             url:publicKeyUrl
                                                       signature:signature
                                                            salt:salt
                                                       timestamp:timestamp
                                                            name:localPlayer.alias
                                                        bundleId:[[NSBundle mainBundle] bundleIdentifier]];
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

            _playerInfo = [[PlayerInfo alloc] initWithId:[AuthService generateUUID]
                                                     url:nil
                                               signature:nil
                                                    salt:nil
                                               timestamp:0
                                                    name:@""
                                                bundleId:[[NSBundle mainBundle] bundleIdentifier]];
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

- (NSString *)getServerPlayerId {
    if(_playerInfo != nil) {
        return _playerInfo.serverPlayerId;
    } else {
        return @"";
    }
}

- (void)setServerPlayerId:(NSString *)serverPlayerId {
    if(_playerInfo != nil) {
        _playerInfo.serverPlayerId = serverPlayerId;
    }
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

                              SendUnityMessage("Main Camera", "LoginResult", [AuthService.authStatus[2] UTF8String]);
#if !UNITY_IOS
                              [self updateUIText];
#endif
                              return;
                          }

                          NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *) response;
                          NSInteger statusCode = HTTPResponse.statusCode;

                          if (statusCode != 200) {
                              NSLog(@"AuthServer call failed");

                              SendUnityMessage("Main Camera", "LoginResult", [AuthService.authStatus[2] UTF8String]);
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
                              [self setServerPlayerId:dict[@"id"]];
                          } else {
                              [self setLasterror:parseError];
                          }

                          if(_cancelled) {
                              SendUnityMessage("Main Camera", "LoginResult", [AuthService.authStatus[3] UTF8String]);
                          } else {
                              SendUnityMessage("Main Camera", "LoginResult", [AuthService.authStatus[1] UTF8String]);
                          }

                          _serverAuthed = YES;
#if !UNITY_IOS
                          [self updateUIText];
#endif

                      }];
}


-(void)setAuthViewController:(UIViewController *)authViewController
{
    if(authViewController != nil) {
        _authViewController = authViewController;
        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthViewController object:self];
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
            SendUnityMessage("Main Camera", "PlayerChange", "true");
        }
    }

    _playerInfo = playerInfo;
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
