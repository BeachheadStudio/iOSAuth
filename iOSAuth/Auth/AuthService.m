//
//  AuthService.m
//  iOSAuth
//
//  Created by SingleMalt on 3/30/16.
//  Copyright © 2016 SingleMalt. All rights reserved.
//

#import "AuthService.h"
#import "PlayerInfo.h"
#import "UnityExtern.h"

NSString *const PresentAuthViewController = @"present_authentication_view_controller";

@implementation AuthService {
    BOOL _gcAuthed;
    BOOL _serverAuthed;
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

-(void)authLocalPlayer
{
    __weak GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error) {
        [self setLasterror:error];
        
        if(viewController != nil) {
            [self setAuthViewController:viewController];
        } else if([GKLocalPlayer localPlayer].isAuthenticated) {
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

                    [UnityExtern sendUnityMessage:@"Main Camera"
                                           method:@"LoginResult"
                                          message:[NSString stringWithUTF8String:[AuthService.authStatus[2] UTF8String]]];

                    self.playerInfo = [[PlayerInfo alloc] initWithId:[AuthService generateUUID]
                                                              andUrl:publicKeyUrl
                                                              andSig:signature
                                                             andSalt:salt
                                                             andTime:timestamp
                                                             andName:localPlayer.alias];
                } else {
                    self.playerInfo = [[PlayerInfo alloc] initWithId:localPlayer.playerID
                                                              andUrl:publicKeyUrl
                                                              andSig:signature
                                                             andSalt:salt
                                                             andTime:timestamp
                                                             andName:localPlayer.alias];
                }
            }];

        } else {
            _gcAuthed = NO;
            _anonymous = YES;
            [UnityExtern sendUnityMessage:@"Main Camera"
                                   method:@"LoginResult"
                                  message:[NSString stringWithUTF8String:[AuthService.authStatus[3] UTF8String]]];

            self.playerInfo = [[PlayerInfo alloc] initWithId:[AuthService generateUUID]
                                                      andUrl:nil
                                                      andSig:nil
                                                     andSalt:nil
                                                     andTime:0
                                                     andName:@""];
        }
    };
}

- (NSString *)getFirstPartyPlayerId {
    if(_gcAuthed) {
        return nil;
    } else if (_playerInfo == nil) {
        return nil;
    } else {
        return _playerInfo.firstPartyPlayerId;
    }
}

- (NSString *)getPlayerName {
    if(_gcAuthed) {
        return nil;
    } else if (_playerInfo == nil) {
        return nil;
    } else {
        return _playerInfo.playerName;
    }
}

- (NSString *)getFailureError {
    if(_lasterror == nil) {
        return nil;
    } else {
        NSString *errorStr = [[_lasterror userInfo] description];
        return [NSString stringWithUTF8String:[errorStr UTF8String]];
    }
}

- (NSString *)getPlayerId {
    if(_gcAuthed && !_anonymous) {
        return @"";
    } else {
        return @"";
    }
}

- (BOOL)isAnonymous {
    if(_gcAuthed) {
        return _anonymous;
    } else {
        return YES;
    }
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

        [UnityExtern sendUnityMessage:@"Main Camera"
                               method:@"LoginResult"
                              message:[NSString stringWithUTF8String:[AuthService.authStatus[3] UTF8String]]];
    }
}

-(void)setPlayerInfo:(PlayerInfo *)playerInfo {
    if(playerInfo != nil) {
        _playerInfo = playerInfo;
    }
}

@end
