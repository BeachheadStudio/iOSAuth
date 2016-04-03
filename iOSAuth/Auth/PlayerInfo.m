//
// Created by SingleMalt on 3/30/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerInfo.h"

@implementation PlayerInfo

@synthesize playerId;
@synthesize publicKeyUrl;
@synthesize signature;
@synthesize salt;
@synthesize timestamp;
@synthesize playerName;
@synthesize bundleId;
@synthesize network;
@synthesize serverPlayerId;

- (id)initWithId:(NSString *)id_
             url:(NSURL *)url_
       signature:(NSData *)signature_
            salt:(NSData *)salt_
       timestamp:(uint64_t)timestamp_
            name:(NSString *)name_
        bundleId:(NSString *)bundleId_
{
    self = [super init];

    if(self) {
        playerId = id_;
        publicKeyUrl = url_;
        signature = signature_;
        salt = salt_;
        timestamp = timestamp_;
        playerName = name_;
        bundleId = bundleId_;
        network = @"APPLE";
        serverPlayerId = @"";
    }

    return self;
}

- (NSMutableDictionary *)convertToDict {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    [dict setValue:playerId forKey:@"playerId"];
    [dict setValue:[publicKeyUrl absoluteString] forKey:@"publicKeyUrl"];
    [dict setValue:[signature base64EncodedStringWithOptions:0] forKey:@"signature"];
    [dict setValue:[salt base64EncodedStringWithOptions:0] forKey:@"salt"];
    [dict setValue:@(timestamp) forKey:@"timestamp"];
    [dict setValue:playerName forKey:@"playerName"];
    [dict setValue:bundleId forKey:@"bundleId"];
    [dict setValue:network forKey:@"network"];

    return dict;
}


@end