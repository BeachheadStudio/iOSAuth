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

@property (nonatomic, readwrite) NSString *playerId;
@property (nonatomic, readwrite) NSURL *publicKeyUrl;
@property (nonatomic, readwrite) NSData *signature;
@property (nonatomic, readwrite) NSData *salt;
@property (nonatomic, readwrite) uint64_t timestamp;
@property (nonatomic, readwrite) NSString *playerName;
@property (nonatomic, readwrite) NSString *serverPlayerId;
@property (nonatomic, readwrite) NSString *bundleId;
@property (nonatomic, readwrite) NSString *network;

- (id)initWithId:(NSString *)id_
  serverPlayerId:(NSString *)serverPlayerId_
             url:(NSURL *)url_
       signature:(NSData *)signature_
            salt:(NSData *)salt_
       timestamp:(uint64_t)timestamp_
            name:(NSString *)name_
        bundleId:(NSString *)bundleId_;

-(NSMutableDictionary *)convertToDict;
@end

#endif /* PlayerInfo_h */