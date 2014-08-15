//
//  GBPDatabaseConnector.h
//  BarPad
//
//  Created by Joseph Pecoraro on 6/5/14.
//  Copyright (c) 2014 GatorLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HBADatabaseConnector : NSObject <NSURLConnectionDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, copy) NSString *postData;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLConnection *connection;
@property (copy) void(^responseHandler)(NSMutableData* data, NSError* error);

@property (nonatomic, assign) NSInteger timeoutInterval;

@property (nonatomic, strong) NSMutableString *logMessage;

@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *imageFormat; //png or jpeg

//if this is chosen instead of block
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL targetAction;

-(instancetype) initWithURLString:(NSString*)URL andPostData:(NSString*)postData completionBlock:(void(^)(NSMutableData* data, NSError* error))responseHandler;
-(instancetype) initWithURLString:(NSString*)URL andPostData:(NSString*)postData target:(id)responseTarget response:(SEL)targetAction;
-(instancetype) initWithImageName:(NSString*)imageName imageFormat:(NSString*)imageFormat imageDate:(NSData*)imageData;
-(void)startConnection;
-(void)startUpload;

@end
