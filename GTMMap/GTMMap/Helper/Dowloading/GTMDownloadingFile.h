//
//  GTMDownloadingFile.h
//  GTM
//
//  Created by mac on 30/03/16.
//  Copyright © 2016 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapModel.h"



@interface GTMDownloadingFile : NSObject

/**
 Creates the Singleton Object of 'GTMDownloadingFile'.
 @return singleton Object of 'GTMDownloadingFile'.
 */
+ (instancetype)sharedCoreManager;


-(void)startDownloadingWithMap:(MapModel*)mapObject;
-(void)pushDownloadingWithMap:(MapModel*)mapObject;
-(void)resumeDownloadingWithMap:(MapModel*)mapObject;
- (void)stopDownloadingWithMap:(MapModel*)mapObject;

//- (void)cancelAllDownloads;
//- (void)cancelDownloadForUrl:(NSString *)fileIdentifier;
//- (void)cleanDirectoryNamed:(NSString *)directory;

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier;
- (BOOL)isFileDownloadingForUrl:(NSString *)url withProgressBlock:(ProgessBlock)block;
- (BOOL)isFileDownloadingForUrl:(NSString *)url withProgressBlock:(ProgessBlock)block completionBlock:(CompleteBlock)completionBlock;

- (NSString *)localPathForFile:(NSString *)fileIdentifier;
- (NSString *)localPathForFile:(NSString *)fileIdentifier inDirectory:(NSString *)directoryName;

- (BOOL)fileExistsForUrl:(NSString *)urlString;
- (BOOL)fileExistsForUrl:(NSString *)urlString inDirectory:(NSString *)directoryName;
- (BOOL)fileExistsWithName:(NSString *)fileName;
- (BOOL)fileExistsWithName:(NSString *)fileName inDirectory:(NSString *)directoryName;

- (BOOL)deleteFileForUrl:(NSString *)urlString;
- (BOOL)deleteFileForUrl:(NSString *)urlString inDirectory:(NSString *)directoryName;
- (BOOL)deleteFileWithName:(NSString *)fileName;
- (BOOL)deleteFileWithName:(NSString *)fileName inDirectory:(NSString *)directoryName;

/**
 *  This method helps checking which downloads are currently ongoing.
 *
 *  @return an NSArray of NSString with the URLs of the currently downloading files.
 */
//- (NSArray *)currentDownloads;
@end
