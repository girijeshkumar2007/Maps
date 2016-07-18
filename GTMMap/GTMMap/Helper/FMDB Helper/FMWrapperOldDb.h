//
//  FMWrapperOldDb.h
//  TestFMDB
//
//  Created by Girijesh Kumar on 15/05/16.
//  Copyright © 2016 Girijesh Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <FMDB/FMDB.h>
#import <MapKit/MapKit.h>
#import "RMTile.h"
#import "RMFoundation.h"

@interface FMWrapperOldDb : NSObject
{
    FMDatabase *fmdb ;
    FMDatabaseQueue *queue;
    // supported zoom levels
    float minZoom;
    float maxZoom;
    BOOL isInitialized;
    BOOL orientationLocked;
    float datumShiftLng;
    float datumShiftLat;
    float startX;
    float startY;
    float startZ;
    float boundsX;
    float boundsY;
    float boundsW;
    float boundsH;
    NSString*  boundsI;
    int tileSideLength;
    
    NSString*  tmsTemplate;
    BOOL viewSideA;
}
/** Initialize and return a newly allocated MBTiles tile source based on a given bundle resource.
 *   @param name The name of the resource file. If name is an empty string or `nil`, uses the first file encountered of the supplied type.
 *   @param extension If extension is an empty string or `nil`, the extension is assumed not to exist and the file is the first file encountered that exactly matches name.
 *   @return An initialized MBTiles tile source. */
- (id)initWithTileSetResource:(NSString *)name ofType:(NSString *)extension showSideA:(BOOL)sideA;


/** Initialize and return a newly allocated MBTiles tile source based on a given local database URL.
 *   @param tileSetURL Local file path URL to an MBTiles file.
 *   @return An initialized MBTiles tile source. */
- (id)initWithTileSetURL:(NSURL *)tileSetURL showSideA:(BOOL)sideA;

@property BOOL viewSideA;
@property (nonatomic, retain) FMDatabase* fmdb;

-(id)initWithPath:(NSString*)path;
-(id)initWithPath:(NSString*)path showSideA:(BOOL)sideA;
- (UIImage*)imageFromOldDataBasewithTiles:(RMTile)_tile;

-(int)tileSideLength;
-(float) minZoom;
-(float) maxZoom;
-(BOOL) isInitialized;
-(BOOL) orientationLocked;
-(float) datumShiftLng;
-(float) datumShiftLat;
-(float) startX;
-(float) startY;
-(float) startZ;
-(float) boundsX;
-(float) boundsY;
-(float) boundsW;
-(float) boundsH;

-(NSString *)shortName;
-(NSString *)longDescription;
-(NSString *)shortAttribution;
-(NSString *)longAttribution;

- (CLLocationCoordinate2D) topLeftOfCoverage;
- (CLLocationCoordinate2D) bottomRightOfCoverage;
- (CLLocationCoordinate2D) centerOfCoverage;
@end
