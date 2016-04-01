//
// Created by SingleMalt on 3/31/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#import "HTTPHelper.h"


@implementation HTTPHelper {

}

+ (NSString *)HTTPMethodString:(HTTPMethod)method {
    switch (method) {
        case GET:
            return @"GET";
        case POST:
            return @"POST";
        case PUT:
            return @"PUT";
        case DELETE:
            return  @"DELETE";
    }
    return nil;
}

- (id)init {
    self = [super init];
    if(self) {

    }
    return self;
}

- (NSJSONSerialization *)HTTPRequest:(NSURL *)url
                              method:(HTTPMethod)method
                                data:(NSJSONSerialization *)data
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:[HTTPHelper HTTPMethodString:method]];


    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {

}


@end