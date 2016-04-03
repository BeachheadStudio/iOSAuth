//
// Created by SingleMalt on 3/31/16.
// Copyright (c) 2016 SingleMalt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HTTPHelper.h"


@implementation HTTPHelper {

}

+ (NSOperationQueue *)HTTPQueue {

    static NSOperationQueue *httpQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        httpQueue = [[NSOperationQueue alloc] init];
    });

    return httpQueue;
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

+ (void)HTTPRequest:(NSURL *)url
             method:(HTTPMethod)method
               body:(NSMutableDictionary *)body
              block:(void(^)(NSData *data, NSURLResponse *response, NSError *error))block;
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:20];

    if(method != GET && body != nil) {
        NSError *error;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:body
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];

        if(error != nil) {
            [NSException raise:@"Could not turn object into JSON" format:@"object of %@ is invalid", body];
        }

        [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[jsonData length]] forHTTPHeaderField:@"Content-Length"];
        [request setHTTPBody:jsonData];
    }

    [request setHTTPMethod:[HTTPHelper HTTPMethodString:method]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                                          delegate:nil
                                                     delegateQueue:[HTTPHelper HTTPQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:block];

    NSLog(@"Sending %@ to %@", [HTTPHelper HTTPMethodString:method], url);
    [task resume];
}

@end