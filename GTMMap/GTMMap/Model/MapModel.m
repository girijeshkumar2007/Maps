//
//  MapModel.m
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import "MapModel.h"
#import "Map.h"
#import "GTMDownloadingFile.h"

@implementation MapModel
- (id)initWithFileTitle:(NSString *)title andDownloadSource:(NSString *)source
{
    if(self == [super init])
    {
//        self.fileTitle = title;
        self.downloadSource = source;
        self.downloadProgress = 0.0;
//        self.isDownload=kDownlaodNone;
//        self.isDownloading = NO;
//        self.downloadComplete = NO;
        self.taskIdentifier = -1;
    }
    return self;
}

-(void)updateMapModelObjectWith:(Map*)mapObj{
    
    self.appleID=mapObj.appleID;
    self.name=mapObj.name;
    self.mapNumber=mapObj.mapNumber;
    self.company=mapObj.company;
    self.state=mapObj.state;
    self.region=mapObj.region;
    self.index=mapObj.index;
    self.mapUrl=mapObj.mapUrl;
    self.mapNotes=mapObj.mapNotes;
    self.isNew=mapObj.isNew;
    self.mapSourceMode=mapObj.mapSourceMode;
    self.mapLocations=mapObj.mapLocations;
    self.pubDate=mapObj.pubDate;
    self.mapStatus = kMapHasNoIAPInfo;
    if (mapObj.isDownload.boolValue) {
        
        BOOL fileExit=[[GTMDownloadingFile sharedCoreManager] fileExistsForUrl:mapObj.mapUrl];
        if (fileExit) {
            self.mapStatus=kMapAvailable;
        }
    }
    else if (mapObj.isPurchased.boolValue)
    {
        self.mapStatus = kMapPurchased;
    }
}
@end
