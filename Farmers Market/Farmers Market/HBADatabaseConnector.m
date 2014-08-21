//
//  GBPDatabaseConnector.m
//  BarPad
//
//  Created by Joseph Pecoraro on 6/5/14.
//  Copyright (c) 2014 GatorLab. All rights reserved.
//

#import "HBADatabaseConnector.h"

#define kImageURL @"image.php"

@implementation HBADatabaseConnector

-(instancetype)initWithURLString:(NSString *)URL andPostData:(NSString *)postData completionBlock:(void (^)(NSMutableData *, NSError *))responseHandler {
    self = [super init];
    if (self) {
        _url = [[NSURL alloc] initWithString:URL relativeToURL:[[NSURL alloc] initWithString:kBaseURL]];
        _postData = postData;
        _responseHandler = responseHandler;
        _logMessage = [[NSMutableString alloc] initWithString:@"\n"];
        _timeoutInterval = 5;
    }
    return self;
}

-(instancetype)initWithImageName:(NSString *)imageName imageFormat:(NSString *)imageFormat imageDate:(NSData *)imageData {
    self = [super init];
    if (self) {
        //_url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@%@", kURL, imagePath] relativeToURL:[[NSURL alloc] initWithString:kBaseURL]];
        _url = [[NSURL alloc] initWithString:kImageURL relativeToURL:[[NSURL alloc] initWithString:kBaseURL]];
        _imageName = imageName;
        _imageData = imageData;
        _imageFormat = imageFormat; //should be jpeg or png
        _logMessage = [[NSMutableString alloc] initWithString:@"\n"];
    }
    return self;
}

-(void)startConnection {
    if (self.connection != nil) {
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[self.postData dataUsingEncoding:NSUTF8StringEncoding]];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:self.timeoutInterval];
    
    [_logMessage appendFormat:@"Connection Began:\nURL:%@\nPost Data: %@", self.url, self.postData];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)startUpload {
    if (self.connection != nil) {
        return;
    }
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:self.url];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"0xIsTiLlDOnTkNOwbOuNdArY";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding: NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n",self.imageName]dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n", self.imageFormat] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:self.imageData];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    [request setTimeoutInterval:10];
    
    [_logMessage appendFormat:@"Connection Began Uploading:\nURL: %@\nImage Name: %@\nUpload Size: %.2fKb", self.url, self.imageName, [body length]/1024.0];
    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [_logMessage appendFormat:@"\n\nConnection failed with error: %@\n\n", error.localizedDescription];
    if (error.code == -1005) {
    }
    [self completeConnection:error];
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        [_logMessage appendFormat:@"\n\nConnection recieved response:\nStatus Code:%zd", httpResponse.statusCode];
    }
    else {
        [_logMessage appendFormat:@"\n\nConnection recieved Response:\n%@", response];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_logMessage appendFormat:@"\n\nConnection recieved data:\n%@\n\nNumber of KiloBytes: %.4f\n\n", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], [data length]/1024.0];
    if (!_data) {
        _data = [[NSMutableData alloc] init];
    }
    [self.data appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection*) connection {
    [self completeConnection:nil];
}

-(NSString*)description {
    return [NSString stringWithFormat:@"\nURL: %@ \nPost Data: %@\n\n", self.url, self.postData];
}

-(void)completeConnection:(NSError*)error {
    NSLog(@"%@", self.logMessage);
    
    if (_responseHandler) {
        _responseHandler(self.data, error);
    }
    [self destroyConnection];
    
}

-(void)destroyConnection {
    [self.connection cancel];
    _connection = nil;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end
