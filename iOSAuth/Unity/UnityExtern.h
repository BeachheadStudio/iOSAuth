//
// Created by SingleMalt on 4/1/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#ifndef UnityExtern_h
#define UnityExtern_h


@interface UnityExtern : NSObject

+(void)sendUnityMessage:(NSString *)object
                 method:(NSString *)method
                message:(NSString *)message;
@end

#endif /* UnityExtern_h */