//
//  FMWrapperClass.m
//  TestFMDB
//
//  Created by Girijesh Kumar on 08/01/16.
//  Copyright © 2016 Girijesh Kumar. All rights reserved.
//

#import "FMWrapperClass.h"
#import <CommonCrypto/CommonCryptor.h>

#define kMBTilesDefaultMinTileZoom 0
#define kMBTilesDefaultMaxTileZoom 22

@implementation FMWrapperClass
{

}
- (id)initWithTileSetResource:(NSString *)name ofType:(NSString *)extension
{
    NSString *filPath =[[NSBundle mainBundle] pathForResource:name ofType:extension];
    NSURL *fileUrl =[NSURL fileURLWithPath:filPath];
    return [self initWithTileSetURL:fileUrl];
}
- (id)initWithTileSetURL:(NSURL *)tileSetURL
{
    if ( ! (self = [super init]))
        return nil;
    queue = [FMDatabaseQueue databaseQueueWithPath:[tileSetURL path]];
    if ( ! queue)
        return nil;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
    }];
    return self;
}
- (float)minZoom
{
    __block double minZoom;
    
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"select min(zoom_level) from tiles"];
         
         if ([db hadError])
             minZoom = kMBTilesDefaultMinTileZoom;
         
         [results next];
         
         minZoom = [results doubleForColumnIndex:0];
         
         [results close];
     }];
    
    return minZoom;
}

- (float)maxZoom
{
    __block double maxZoom;
    
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"select max(zoom_level) from tiles"];
         
         if ([db hadError])
             maxZoom = kMBTilesDefaultMaxTileZoom;
         
         [results next];
         
         maxZoom = [results doubleForColumnIndex:0];
         
         [results close];
     }];
    
    return maxZoom;
}

- (UIImage *)imageForTile:(RMTile)tile
{
//    if (((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom))) {
//        return nil;
//    }
   // NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
   //           @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f",
   //           self, tile.zoom, self.minZoom, self.maxZoom);
    NSUInteger zoom = tile.zoom;
    NSUInteger x    = tile.x;
    NSUInteger y    = pow(2, zoom) - tile.y - 1;
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [[NSNotificationCenter defaultCenter] postNotificationName:RMTileRequested object:@(RMTileKey(tile))];
                   });
    
    __block UIImage *image = nil;
    
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"select tile_data from tiles where zoom_level = ? and tile_column = ? and tile_row = ?",@(zoom),@(x),@(y)];
    
         if ([db hadError]){
             NSLog(@"[db lastErrorMessage] %@",[db lastErrorMessage]);

             image = nil;
         }
         [results next];
         
         NSData *data = ([[results columnNameToIndexMap] count] ? [results dataForColumn:@"tile_data"] : nil);
         
         if ( ! data)
         {
            // image = [UIImage imageNamed:@"error"];
             image = nil;
             NSLog(@"[db lastErrorMessage] %@",[db lastErrorMessage]);
 
         }
         else
             image = [UIImage imageWithData:data];
         [results close];
     }];
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   {
                       [[NSNotificationCenter defaultCenter] postNotificationName:RMTileRetrieved object:@(RMTileKey(tile))];
                   });
    
    return image;
}

- (RMSphericalTrapezium)latitudeLongitudeBoundingBox
{
    __block RMSphericalTrapezium bounds = kMBTilesDefaultLatLonBoundingBox;
    
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'bounds'"];
         
         [results next];
         
         NSString *boundsString = [results stringForColumnIndex:0];
         
         [results close];
         
         if (boundsString)
         {
             NSArray *parts = [boundsString componentsSeparatedByString:@","];
             
             if ([parts count] == 4)
             {
                 bounds.southWest.longitude = [[parts objectAtIndex:0] doubleValue];
                 bounds.southWest.latitude  = [[parts objectAtIndex:1] doubleValue];
                 bounds.northEast.longitude = [[parts objectAtIndex:2] doubleValue];
                 bounds.northEast.latitude  = [[parts objectAtIndex:3] doubleValue];
             }
         }
     }];
    
    return bounds;
}

- (NSString *)legend
{
    __block NSString *legend  = nil;
    
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'legend'"];
         
         if ([db hadError])
             legend = nil;
         
         [results next];
         
         legend = [results stringForColumn:@"value"];
         
         [results close];
     }];
    
    return legend;
}

- (CLLocationCoordinate2D)centerCoordinate
{
    __block CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(0, 0);
    
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'center'"];

       //  FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'bounds'"];
         
         [results next];
         
         if ([results stringForColumn:@"value"] && [[[results stringForColumn:@"value"] componentsSeparatedByString:@","] count] >= 2)
             centerCoordinate = CLLocationCoordinate2DMake([[[[results stringForColumn:@"value"] componentsSeparatedByString:@","] objectAtIndex:1] doubleValue],
                                                           [[[[results stringForColumn:@"value"] componentsSeparatedByString:@","] objectAtIndex:0] doubleValue]);
         
         [results close];
     }];
    
    return centerCoordinate;
}

- (float)centerZoom
{
    __block CGFloat centerZoom = [self minZoom];
    
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'center'"];
         
         [results next];
         
         if ([results stringForColumn:@"value"] && [[[results stringForColumn:@"value"] componentsSeparatedByString:@","] count] >= 3)
             centerZoom = [[[[results stringForColumn:@"value"] componentsSeparatedByString:@","] objectAtIndex:2] floatValue];
         
         [results close];
     }];
    
    return centerZoom;
}
- (NSString *)shortName
{
    __block NSString *shortName = nil;
    
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'name'"];
         
         if ([db hadError])
             shortName = nil;
         
         [results next];
         
         shortName = [results stringForColumnIndex:0];
         
         [results close];
     }];
    
    return shortName;
}

- (NSString *)longDescription
{
    __block NSString *description = nil;
    
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'description'"];
         
         if ([db hadError])
             description = nil;
         
         [results next];
         
         description = [results stringForColumnIndex:0];
         
         [results close];
     }];
    
    return [NSString stringWithFormat:@"%@ - %@", [self shortName], description];
}

- (NSString *)shortAttribution
{
    __block NSString *attribution = nil;
    
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:@"select value from metadata where name = 'attribution'"];
         
         if ([db hadError])
             attribution = @"Unknown MBTiles attribution";
         
         [results next];
         
         attribution = [results stringForColumnIndex:0];
         
         [results close];
     }];
    return attribution;
}

- (NSString *)longAttribution
{
    return [NSString stringWithFormat:@"%@ - %@", [self shortName], [self shortAttribution]];
}
- (BOOL)coversFullWorld
{
    RMSphericalTrapezium ownBounds     = [self latitudeLongitudeBoundingBox];
    RMSphericalTrapezium defaultBounds = kMBTilesDefaultLatLonBoundingBox;
    
    if (ownBounds.southWest.longitude <= defaultBounds.southWest.longitude + 10 &&
        ownBounds.northEast.longitude >= defaultBounds.northEast.longitude - 10)
        return YES;
    
    return NO;
}



- (UIImage*)imageFromOldDataBasewithTiles:(RMTile)_tile sideA:(BOOL)viewA {
    
    __block UIImage *tilesImage = nil;
    // get the unique key for the tile
    //float fz = (float) tileWithLocalOffset.zoom;
    //NSNumber* key = [NSNumber numberWithLongLong:RMTileKey(tileWithLocalOffset)];
    long long unsigned int zoom = (int) _tile.zoom;
    long long unsigned int tx = _tile.x;
    long long unsigned int zy = _tile.y;
    long long unsigned int ty = pow(2,(float) zoom) - (1 + (int)_tile.y);
    long long unsigned int akey = zoom * pow(2,36) + tx * pow(2,18) + ty;
    //NSNumber* akey = (zoom << 36) | (x << 18) | (y << 0);
    
    NSNumber* key = [NSNumber numberWithLongLong:akey];
    
    //key = (uint64_t) 618540564709;
    NSLog(@"fetching tile (%d -%llu- %d -%@- %@)", tx, zy, _tile.zoom,key);
    
    // fetch the image from the db
    NSString *cmd = @"select image from Tiles where layerKey=1 and key = ?";
    if (viewA) {
        cmd = @"select image from Tiles where layerKey=0 and key = ?";
    }
    [queue inDatabase:^(FMDatabase *db)
     {
         FMResultSet *results = [db executeQuery:cmd, key];
         
         if ([db hadError]){
             NSLog(@"[db lastErrorMessage] %@",[db lastErrorMessage]);
             
             tilesImage = nil;
         }
         [results next];
         
         tilesImage = [self getDecriptedImageFromEncriptedData:[results dataForColumn:@"image"]];

         [results close];
     }];
    
    
    return tilesImage;

}

#define kEncriptionKey @"eAT11!GrEenTraiLsXMAPpS19732010a"
#define kEncriptionIV @"@1B2c3D4e5F6g7H8"

-(UIImage*)getDecriptedImageFromEncriptedData:(NSData*)encriptedData
{
    NSMutableData *objNSData = [NSMutableData dataWithData:encriptedData];
    NSString *key = kEncriptionKey;
    char keyPtr[33];
    bzero( keyPtr, sizeof(keyPtr) );
    [key getCString: keyPtr maxLength: sizeof(keyPtr) encoding: NSUTF8StringEncoding];
    
    NSString *iv = kEncriptionIV;
    char ivPtr[17];
    bzero( ivPtr, sizeof(ivPtr) );
    [iv getCString: ivPtr maxLength: sizeof(ivPtr) encoding: NSUTF8StringEncoding];
    
    size_t numBytesEncrypted = 0;
    NSUInteger dataLength = [objNSData length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    CCCryptorStatus result = CCCrypt( kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                     keyPtr, kCCKeySizeAES256,
                                     ivPtr,
                                     [objNSData mutableBytes], [objNSData length],
                                     buffer, bufferSize,
                                     &numBytesEncrypted );
    
    
    NSMutableData *output = [[NSMutableData alloc] initWithBytesNoCopy:buffer length:numBytesEncrypted];
    if( result == kCCSuccess ) {
        UIImage *upperLayer = [[UIImage alloc] initWithData:output];
        return upperLayer;
    }
    return nil;
}
@end
