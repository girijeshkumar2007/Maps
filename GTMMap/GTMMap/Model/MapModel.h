//
//  MapModel.h
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Map;

typedef NS_ENUM(NSInteger, MapStatus) {
    
    kMapHasNoIAPInfo,
    kMapNotPurchased,
    kMapInPurchase = 5,
    kMapPurchased = 6,
    kMapInDownload = 10,
    kMapDownloadPushed = 15,
    kMapAvailable = 20,
};

typedef void (^ProgessBlock)(float progress, NSString *appleId);
typedef void (^CompleteBlock)(BOOL sucess,NSString *appleId, NSError *Error);

@interface MapModel : NSObject
{
    
}
@property (copy, nonatomic) ProgessBlock progressBlock;
@property (copy, nonatomic) CompleteBlock completionBlock;

@property (nullable, nonatomic, strong) NSString *appleID;
@property (nullable, nonatomic, strong) NSString *name;
@property (nullable, nonatomic, strong) NSString *mapNumber;
@property (nullable, nonatomic, strong) NSString *company;
@property (nullable, nonatomic, strong) NSString *state;
@property (nullable, nonatomic, strong) NSString *region;
@property (nullable, nonatomic, strong) NSString *index;
@property (nullable, nonatomic, strong) NSString *mapUrl;
@property (nullable, nonatomic, strong) NSString *mapNotes;
@property (nullable, nonatomic, strong) NSNumber *isNew;
@property (nullable, nonatomic, strong) NSString *mapSourceMode;
@property (nullable, nonatomic, strong) NSString *mapLocations;
//@property (nullable, nonatomic, strong) NSNumber *isPurchased;
@property (nullable, nonatomic, strong) NSNumber *downloading;
@property (nullable, nonatomic, strong) NSString *pubDate;
@property (nonatomic, assign) MapStatus mapStatus;

//@property (nullable,nonatomic, strong) NSString *fileTitle;
@property (nullable,nonatomic, strong) NSString *downloadSource;
@property (nullable,nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nullable,nonatomic, strong) NSData *taskResume;
@property (nonatomic) double downloadProgress;
@property (nonatomic) unsigned long taskIdentifier;

- (nullable id)initWithFileTitle:(nullable NSString *)title andDownloadSource:(nullable NSString *)source;
-(void)updateMapModelObjectWith:(nullable Map*)mapObj;
@end
