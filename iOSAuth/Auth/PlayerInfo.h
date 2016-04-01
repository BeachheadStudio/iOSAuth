//
//  PlayerInfo.h
//  iOSAuth
//
// Created by SingleMalt on 3/30/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#ifndef PlayerInfo_h
#define PlayerInfo_h

@class PlayerInfo;

@interface PlayerInfo : NSObject

@property (nonatomic, readwrite) NSString *firstPartyPlayerId;
@property (nonatomic, readwrite) NSURL *publicKeyUrl;
@property (nonatomic, readwrite) NSData *signature;
@property (nonatomic, readwrite) NSData *salt;
@property (nonatomic, readwrite) uint64_t timestamp;
@property (nonatomic, readwrite) NSString *playerName;
@property (nonatomic, readwrite) NSString *playerId;

- (id)initWithId:(NSString *)id1
          andUrl:(NSURL *)url
          andSig:(NSData *)sig
         andSalt:(NSData *)salt_
         andTime:(uint64_t)time
         andName:(NSString *)name;
@end

#endif /* PlayerInfo_h */