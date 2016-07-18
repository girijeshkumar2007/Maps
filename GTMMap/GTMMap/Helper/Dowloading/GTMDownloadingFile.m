//
//  GTMDownloadingFile.m
//  GTM
//
//  Created by mac on 30/03/16.
//  Copyright © 2016 mac. All rights reserved.
//

#import "GTMDownloadingFile.h"
#import "AppDelegate.h"
#import "MapModel.h"
#import "MapShareClass.h"

@interface GTMDownloadingFile()<NSURLSessionDelegate>
{
    
}
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURL *docDirectoryURL;
@property (strong, nonatomic) NSMutableDictionary *downloads;

@end

@implementation GTMDownloadingFile

static GTMDownloadingFile *manager;
#pragma mark - Alloc Singleton Class Object
+ (instancetype)sharedCoreManager
{
#if ENABLE_LOGGING
    TRC_ENTRY()
#endif
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        manager = [[GTMDownloadingFile alloc] init];
    });
    return manager;
}

+ (id)alloc
{
    @synchronized(self)
    {
        NSAssert(manager == nil, @"Attempted to allocate a second instance of a singleton CoreDataManager.");
        manager = [super alloc];

    }
    
    return manager;
}

- (id)init {
    
    if (self = [super init]) {
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.BGTransferDemo"];
        sessionConfiguration.HTTPMaximumConnectionsPerHost = 100;
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration
                                                 delegate:self
                                            delegateQueue:nil];
        self.downloads = [NSMutableDictionary new];
    }
    return self;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)startDownloadingWithMap:(MapModel*)mapObject
{
    if (mapObject.mapStatus==kMapPurchased) {

        // This is the case where a download task should be started.
        
        // Create a new task, but check whether it should be created using a URL or resume data.
        if (mapObject.taskIdentifier == -1) {
            // If the taskIdentifier property of the mapObject object has value -1, then create a new task
            // providing the appropriate URL as the download source.
            NSURL *downnloadUrl = [NSURL URLWithString:mapObject.downloadSource];
            
            
#if TARGET_IPHONE_SIMULATOR
            //  downnloadUrl=[NSURL URLWithString:@"http://www.dharmamaps.com/gtm/MapList/271.mbtiles"];
#endif
            NSURLSessionDownloadTask *downloadTask = [self.session downloadTaskWithURL:downnloadUrl];
            mapObject.downloadTask=downloadTask;
            NSLog(@"downloadTask.taskIdentifier %@",@(downloadTask.taskIdentifier));
            // Keep the new task identifier.
            mapObject.taskIdentifier = downloadTask.taskIdentifier;
            
            // Start the task.
            [mapObject.downloadTask resume];
            mapObject.mapStatus=kMapInDownload;
            [self.downloads addEntriesFromDictionary:@{mapObject.mapUrl:mapObject}];

        }
        else{
           
        }
    }
}
-(void)pushDownloadingWithMap:(MapModel*)mapObject
{
    NSURLSessionDownloadTask *downloadTask = mapObject.downloadTask;
    // Pause the task by canceling it and storing the resume data.
    [downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
        if (resumeData != nil) {
            mapObject.taskResume = [[NSData alloc] initWithData:resumeData];
            mapObject.mapStatus=kMapDownloadPushed;

        }
    }];
}
-(void)resumeDownloadingWithMap:(MapModel*)mapObject
{
    NSURLSessionDownloadTask *downloadTask = mapObject.downloadTask;
    // Create a new download task, which will use the stored resume data.
    mapObject.downloadTask = [self.session downloadTaskWithResumeData:mapObject.taskResume];
    [mapObject.downloadTask resume];
    mapObject.mapStatus=kMapInDownload;
    // Keep the new download task identifier.
    mapObject.taskIdentifier = downloadTask.taskIdentifier;
}
- (void)stopDownloadingWithMap:(MapModel*)mapObject {
    
    // Get the FileDownloadInfo object being at the cellIndex position of the array.
    [mapObject.downloadTask cancel];
    // Change all related properties.
    mapObject.mapStatus=kMapPurchased;
    mapObject.taskIdentifier = -1;
    mapObject.downloadProgress = 0.0;
    [self.downloads removeObjectForKey:mapObject.mapUrl];

    // Reload the table view.
    //  [self.tblFiles reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    //   }
}
#pragma mark - NSURLSessionDelegate Deletegate

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    
    NSError *error;
    NSURL *destinationLocation;
    BOOL success = YES;
    if ([downloadTask.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger statusCode = [(NSHTTPURLResponse*)downloadTask.response statusCode];
        if (statusCode >= 400) {
            NSLog(@"ERROR: HTTP status code %@", @(statusCode));
            success = NO;
        }
    }
     NSString *destinationFilename = downloadTask.originalRequest.URL.lastPathComponent;
    if (success) {
        destinationLocation = [[self cachesDirectoryUrlPath] URLByAppendingPathComponent:destinationFilename];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:destinationLocation.path]) {
            [[NSFileManager defaultManager] removeItemAtURL:destinationLocation error:&error];
        }
        
        // Move downloaded item from tmp directory to te caches directory
        // (not synced with user's iCloud documents)
        [[NSFileManager defaultManager] moveItemAtURL:location
                                                toURL:destinationLocation
                                                error:&error];
        if (error) {
            NSLog(@"ERROR: %@", error);
        }
       
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSString *fileIdentifier = downloadTask.originalRequest.URL.absoluteString;
            MapModel *mapObject = [self.downloads objectForKey:fileIdentifier];
            
            // Change the flag values of the respective FileDownloadInfo object.
            mapObject.mapStatus = kMapAvailable;
            
            // Set the initial value to the taskIdentifier property of the fdi object,
            // so when the start button gets tapped again to start over the file download.
            mapObject.taskIdentifier = -1;
            // In case there is any resume data stored in the fdi object, just make it nil.
            mapObject.taskResume = nil;
            
            // Reload the respective table view row using the main thread.
            if (mapObject.completionBlock) {
                mapObject.completionBlock(YES,mapObject.appleID,nil);
            }
        }];
    }
    else{
        NSLog(@"Unable to copy temp file. Error: %@", [error localizedDescription]);
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    
    if (error != nil) {
        NSLog(@"Download completed with error: %@", [error localizedDescription]);
    }
    else{
        NSLog(@"Download finished successfully.");
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{

        NSString *fileIdentifier = task.originalRequest.URL.absoluteString;
        MapModel *mapObject = [self.downloads objectForKey:fileIdentifier];
        if (mapObject.completionBlock) {
            
            if (error.code!=-999) { //not equal to cancel
                mapObject.mapStatus = kMapPurchased;
                mapObject.taskIdentifier = -1;
                mapObject.taskResume = nil;
            }
            mapObject.completionBlock(NO,mapObject.appleID,error);
        }
    }];
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
    if (totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown) {
        NSLog(@"Unknown transfer size");
    }
    else{
        // Locate the FileDownloadInfo object among all based on the taskIdentifier property of the task.
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // Calculate the progress.
            NSString *fileIdentifier = downloadTask.originalRequest.URL.absoluteString;
            MapModel *mapObject = [self.downloads objectForKey:fileIdentifier];
            
            float download = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
            mapObject.downloadProgress = download*100;
//            NSLog(@"downloadTask.taskIdentifier %lu download == %f",(unsigned long)downloadTask.taskIdentifier,download);
            if (mapObject.progressBlock) {
                
                dispatch_async(dispatch_get_main_queue(), ^(void) {
                    if(mapObject.progressBlock){
                        mapObject.progressBlock(download,mapObject.appleID); //exception when progressblock is nil
                    }
                });
            }
        }];
    }
}


-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    
    // Check if all download tasks have been finished.
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        if ([downloadTasks count] == 0) {
            if (appDelegate.backgroundTransferCompletionHandler != nil) {
                // Copy locally the completion handler.
                void(^completionHandler)() = appDelegate.backgroundTransferCompletionHandler;
                
                // Make nil the backgroundTransferCompletionHandler.
                appDelegate.backgroundTransferCompletionHandler = nil;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Call the completion handler to tell the system that there are no other background transfers.
                    completionHandler();
                    
                    // Show a local notification when all downloads are over.
                    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                    localNotification.alertBody = @"All files have been downloaded!";
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
                }];
            }
        }
    }];
}

#pragma mark - File Management

- (BOOL)createDirectoryNamed:(NSString *)directory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *targetDirectory = [cachesDirectory stringByAppendingPathComponent:directory];
    
    NSError *error;
    return [[NSFileManager defaultManager] createDirectoryAtPath:targetDirectory
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&error];
}

- (NSURL *)cachesDirectoryUrlPath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSURL *cachesDirectoryUrl = [NSURL fileURLWithPath:cachesDirectory];
    return cachesDirectoryUrl;
}

- (BOOL)fileDownloadCompletedForUrl:(NSString *)fileIdentifier {
    
    BOOL retValue = YES;
    MapModel *download = [self.downloads objectForKey:fileIdentifier];
    if (download) {
        // downloads are removed once they finish
        retValue = NO;
    }
    return retValue;
}

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier {
    return [self isFileDownloadingForUrl:fileIdentifier
                       withProgressBlock:nil];
}

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier
              withProgressBlock:(ProgessBlock)block {
    return [self isFileDownloadingForUrl:fileIdentifier
                       withProgressBlock:block
                         completionBlock:nil];
}

- (BOOL)isFileDownloadingForUrl:(NSString *)fileIdentifier
              withProgressBlock:(ProgessBlock)block
                completionBlock:(CompleteBlock)completionBlock {
    
    BOOL retValue = NO;
    MapModel *download = [self.downloads objectForKey:fileIdentifier];
    if (download) {
        if (block) {
            download.progressBlock = block;
        }
        if (completionBlock) {
            download.completionBlock = completionBlock;
        }
        retValue = YES;
    }
    return retValue;
}

#pragma mark File existance

- (NSString *)localPathForFile:(NSString *)fileIdentifier {
    return [self localPathForFile:fileIdentifier inDirectory:nil];
}

- (NSString *)localPathForFile:(NSString *)fileIdentifier inDirectory:(NSString *)directoryName {
    NSString *fileName = [fileIdentifier lastPathComponent];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    return [[cachesDirectory stringByAppendingPathComponent:directoryName] stringByAppendingPathComponent:fileName];
}

- (BOOL)fileExistsForUrl:(NSString *)urlString {
    return [self fileExistsForUrl:urlString inDirectory:nil];
}

- (BOOL)fileExistsForUrl:(NSString *)urlString inDirectory:(NSString *)directoryName {
    return [self fileExistsWithName:[urlString lastPathComponent] inDirectory:directoryName];
}

- (BOOL)fileExistsWithName:(NSString *)fileName
               inDirectory:(NSString *)directoryName {
    BOOL exists = NO;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    // if no directory was provided, we look by default in the base cached dir
    if ([[NSFileManager defaultManager] fileExistsAtPath:[[cachesDirectory stringByAppendingPathComponent:directoryName] stringByAppendingPathComponent:fileName]]) {
        exists = YES;
    }
    
    return exists;
}

- (BOOL)fileExistsWithName:(NSString *)fileName {
    return [self fileExistsWithName:fileName inDirectory:nil];
}

#pragma mark File deletion

- (BOOL)deleteFileForUrl:(NSString *)urlString {
    return [self deleteFileForUrl:urlString inDirectory:nil];
}

- (BOOL)deleteFileForUrl:(NSString *)urlString inDirectory:(NSString *)directoryName {
    return [self deleteFileWithName:[urlString lastPathComponent] inDirectory:directoryName];
}

- (BOOL)deleteFileWithName:(NSString *)fileName {
    return [self deleteFileWithName:fileName inDirectory:nil];
}

- (BOOL)deleteFileWithName:(NSString *)fileName
               inDirectory:(NSString *)directoryName {
    BOOL deleted = NO;
    
    NSError *error;
    NSURL *fileLocation;
    if (directoryName) {
        fileLocation = [[[self cachesDirectoryUrlPath] URLByAppendingPathComponent:directoryName] URLByAppendingPathComponent:fileName];
    } else {
        fileLocation = [[self cachesDirectoryUrlPath] URLByAppendingPathComponent:fileName];
    }
    
    
    // Move downloaded item from tmp directory to te caches directory
    // (not synced with user's iCloud documents)
    [[NSFileManager defaultManager] removeItemAtURL:fileLocation error:&error];
    
    if (error) {
        deleted = NO;
        NSLog(@"Error deleting file: %@", error);
    } else {
        deleted = YES;
    }
    return deleted;
}

#pragma mark - Clean directory

- (void)cleanDirectoryNamed:(NSString *)directory {
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NSString *file in [fm contentsOfDirectoryAtPath:directory error:&error]) {
        [fm removeItemAtPath:[directory stringByAppendingPathComponent:file] error:&error];
    }
}

- (void)cleanTmpDirectory {
    
    NSArray* tmpDirectory = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:NSTemporaryDirectory() error:NULL];
    for (NSString *file in tmpDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), file] error:NULL];
    }
}
@end
