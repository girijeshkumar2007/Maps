//
//  NetworkManager.h
//  NetworkManager
//
//  Created by Girijesh Kumar on 05/01/16.
//  Copyright © 2016 Girijesh Kumar. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "NetworkURLs.h"


#define kAuthentication     @"Authentication"                   //Header key of request  encrypt data
#define kEncryptionKey      @"Wizz"                    //Encryption key replace this with your projectname

typedef enum{
    kHTTPMethodGET = 0,
    kHTTPMethodPOST,
    kHTTPMethodPUT,
    kHTTPMethodDELETE,
    kHTTPMethodHEAD,
    kHTTPMethodPATCH,
}kHTTPMethod;

/**
 'NetworkManager' subclass of 'AFHTTPSessionManager' is the singleton class performs
 all network operations over HTTP or HTTPS protocol over GET, POST http methods.
 
 This sigleton class creates single 'NSOperationQueue' in which all web service calls goes as an
 'NSOperation'. This gives the flexibility to know what all web services are running at particular
 time and gives useful methods to cancel all or any operation.
 
 ## NOTE: Do not alloc init this class.
 */

@interface NetworkManager : AFHTTPSessionManager

/**
 Creates the Singleton Object of 'NetworkManager'.
 @return singleton Object of 'NetworkManager'.
 */
+ (instancetype)manager;

/**
 *  Initiates HTTPS or HTTP request over |kHTTPMethod| method and returns call back in success and failure block.
 *
 *  @param serviceName  name of the service
 *  @param method       method type like Get and Post
 *  @param postData     parameters
 *  @param responeBlock call back in block
 */
- (void)requestApiWithName:(NSString *)serviceName
               requestType:(kHTTPMethod)method
                  postData:(id)postData
             callBackBlock:(void (^)(id response,NSError *error))responeBlock;


/**
 *  Upload multiple images via multipart
 *
 *  @param serviceName  name of the service
 *  @param postData     parameters
 *  @param imagesArray  array having images in NSData form
 *  @param responeBlock call back in block
 */
-(void)requestApiWithMultiPart:(NSString *)serviceName
                      postData:(NSDictionary*)postData
                    imageArray:(NSMutableArray*)imagesArray
                 callBackBlock:(void (^)(id response,NSError *error))responeBlock;

/**
 *  Upload multiple images and videos via multipart
 *
 *  @param serviceName  name of the service
 *  @param postData     parameters
 *  @param imagesArray  array having images in NSData form
 *  @param videosArray  array having videos file path
 *  @param responeBlock call back in block
 */
-(void)requestApiWithMultiPart:(NSString *)serviceName
                      postData:(NSDictionary*)postData
                    imageArray:(NSMutableArray*)imagesArray
                    videoArray:(NSMutableArray*)videosArray
                 callBackBlock:(void (^)(id response,NSError *error))responeBlock;


/**
 Cancels all HTTP requests
 */
- (void)cancelAllRequests;

/**
 Cancel particular request identified with |URLString|.
 */
- (void)cancelRequestWithURLString:(NSString*)URLString;

/**
 Returns number of requests submitted to Manager.
 */
- (NSUInteger)numberOfRequestsInManager;

//-(NSString *)encryptRequestString:(NSString *)requestStr;
//- (BOOL)isConnectedToWiFi;
//- (BOOL)isInternetAvailable;

@end
