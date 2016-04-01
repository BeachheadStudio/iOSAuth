//
// Created by SingleMalt on 3/30/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#import "PlayerInfo.h"

@implementation PlayerInfo

@synthesize firstPartyPlayerId;
@synthesize publicKeyUrl;
@synthesize signature;
@synthesize salt;
@synthesize timestamp;
@synthesize playerName;

- (id)initWithId:(NSString *)id
          andUrl:(NSURL *)url
          andSig:(NSData *)sig
         andSalt:(NSData *)salt_
         andTime:(uint64_t)time
         andName:(NSString *)name
{
    self = [super init];

    if(self) {
        firstPartyPlayerId = id;
        publicKeyUrl = url;
        signature = sig;
        salt = salt_;
        timestamp = time;
        playerName = name;
    }

    return self;
}

@end