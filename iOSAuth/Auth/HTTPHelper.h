//
// Created by SingleMalt on 3/31/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

typedef NS_ENUM(NSUInteger, HTTPMethod)
{
    GET,
    POST,
    PUT,
    DELETE
};

@interface HTTPHelper : NSObject

+(NSOperationQueue *)HTTPQueue;

+(NSString *)HTTPMethodString:(HTTPMethod)method;

+(void)HTTPRequest:(NSURL *)url
            method:(HTTPMethod)method
              body:(NSMutableDictionary *)body
             block:(void(^)(NSData *data, NSURLResponse *response, NSError *error))block;

@end