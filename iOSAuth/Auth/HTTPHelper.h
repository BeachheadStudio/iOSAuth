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

+(NSString *)HTTPMethodString:(HTTPMethod)method;

-(id)init;
-(NSJSONSerialization *)HTTPRequest:(NSURL *)url
                             method:(HTTPMethod)method
                               data:(NSJSONSerialization *)data;

-(void)connectionDidFinishLoading:(NSURLConnection *)connection;

@end