//
//  FMWrapperClass.h
//  TestFMDB
//
//  Created by Girijesh Kumar on 08/01/16.
//  Copyright © 2016 Girijesh Kumar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <FMDB/FMDB.h>
#import <MapKit/MapKit.h>
#import "RMTile.h"

#define kMBTilesDefaultLatLonBoundingBox ((RMSphericalTrapezium){.northEast = {.latitude = 90, .longitude = 180}, .southWest = {.latitude = -90, .longitude = -180}})

#define RMTileRequested @"RMTileRequested"
#define RMTileRetrieved @"RMTileRetrieved"

@class FMDatabaseQueue;

typedef struct {
    CLLocationCoordinate2D southWest;
    CLLocationCoordinate2D northEast;
} RMSphericalTrapezium;


@interface FMWrapperClass : NSObject
{
    FMDatabaseQueue *queue;

}
/** Initialize and return a newly allocated MBTiles tile source based on a given bundle resource.
 *   @param name The name of the resource file. If name is an empty string or `nil`, uses the first file encountered of the supplied type.
 *   @param extension If extension is an empty string or `nil`, the extension is assumed not to exist and the file is the first file encountered that exactly matches name.
 *   @return An initialized MBTiles tile source. */
- (id)initWithTileSetResource:(NSString *)name ofType:(NSString *)extension;


/** Initialize and return a newly allocated MBTiles tile source based on a given local database URL.
 *   @param tileSetURL Local file path URL to an MBTiles file.
 *   @return An initialized MBTiles tile source. */
- (id)initWithTileSetURL:(NSURL *)tileSetURL;

/** @name Supplying Tile Images */

/** Provide an image for a given tile location using a given cache.
 *   @param tile The map tile in question. RMTileMake((int)nextTileX, (int)nextTileY, currentZoom)
 *   @return An image to display. */
- (UIImage *)imageForTile:(RMTile)tile;

/** A suggested starting min zoom level for the map layer. */
- (float)minZoom;

/** A suggested starting center Max level for the map layer. */
- (float)maxZoom;

/** A suggested latitude Longitude BoundingBox level for the map layer. */
- (RMSphericalTrapezium)latitudeLongitudeBoundingBox;


/** @name Querying Tile Source Information */

/** Any available HTML-formatted map legend data for the tile source, suitable for display in a `UIWebView`. */
- (NSString *)legend;

/** A suggested starting center coordinate for the map layer. */
- (CLLocationCoordinate2D)centerCoordinate;

/** A suggested starting center zoom level for the map layer. */
- (float)centerZoom;

- (NSString *)shortName;
- (NSString *)longDescription;
- (NSString *)shortAttribution;
- (NSString *)longAttribution;

/** Returns YES if the tile source provides full-world coverage; otherwise, returns NO. */
- (BOOL)coversFullWorld;

@end
