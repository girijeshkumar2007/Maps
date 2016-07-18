//
//  FMWrapperOldDb.m
//  TestFMDB
//
//  Created by Girijesh Kumar on 15/05/16.
//  Copyright © 2016 Girijesh Kumar. All rights reserved.
//

#import "FMWrapperOldDb.h"
#import <CommonCrypto/CommonCryptor.h>
#import "FMWrapperClass.h"
#import "AppUtility.h"

@implementation FMWrapperOldDb

#define kMBTilesDefaultMinTileZoom 0
#define kMBTilesDefaultMaxTileZoom 22
#define kMBTilesDefaultLatLonBoundingBox ((RMSphericalTrapezium){.northEast = {.latitude = 90, .longitude = 180}, .southWest = {.latitude = -90, .longitude = -180}})
// optional preference keys for the attribution
#define kShortNameKey @"map.shortName"
#define kLongDescriptionKey @"map.longDescription"
#define kShortAttributionKey @"map.shortAttribution"
#define kLongAttributionKey @"map.longAttribution"

- (id)initWithTileSetResource:(NSString *)name ofType:(NSString *)extension showSideA:(BOOL)sideA
{
    NSString *filPath =[[NSBundle mainBundle] pathForResource:name ofType:extension];
    NSURL *fileUrl =[NSURL fileURLWithPath:filPath];
    
    return [self initWithTileSetURL:fileUrl showSideA:sideA];
}
- (id)initWithTileSetURL:(NSURL *)tileSetURL showSideA:(BOOL)sideA
{
    if ( ! (self = [super init]))
        return nil;
    
    _viewSideA = sideA;
    _fmdb = [[FMDatabase alloc] initWithPath:tileSetURL.path];
    queue = [FMDatabaseQueue databaseQueueWithPath:[tileSetURL path]];
    if ( ! queue)
        return nil;
    
    [queue inDatabase:^(FMDatabase *db) {
        [db setShouldCacheStatements:YES];
        [self initilizedTiles:db];
    }];
    return self;
}

-(void)initilizedTiles:(FMDatabase*)db
{
    
        NSString *cmd = @"SELECT l.zoomMin, l.zoomMax, l.boundsW, l.boundsE, l.boundsN, l.boundsS, l.datumShiftLongitude, l.datumShiftLatitude, g.minX, g.maxX, g.minY, g.maxY, g.maxResolution, g.tileWidth, g.tileHeight, g.yInverted, g.proj4InitString FROM Layers l JOIN Maps m on l.mapID = m.mapID JOIN Grids g on m.gridID=g.gridID WHERE l.layerKey = 1";
        
        if ([self viewSideA]) {
            cmd = @"SELECT l.zoomMin, l.zoomMax, l.boundsW, l.boundsE, l.boundsN, l.boundsS, l.datumShiftLongitude, l.datumShiftLatitude, g.minX, g.maxX, g.minY, g.maxY, g.maxResolution, g.tileWidth, g.tileHeight, g.yInverted, g.proj4InitString FROM Layers l JOIN Maps m on l.mapID = m.mapID JOIN Grids g on m.gridID=g.gridID WHERE l.layerKey = 0";
        }
        FMResultSet* rs = [db executeQuery:cmd];
        
        if ([rs next]) {
            boundsI = [rs stringForColumn:@"proj4InitString"];
            tileSideLength = [rs intForColumn:@"tileWidth"];
            minZoom = [rs longForColumn:@"zoomMin"];
            maxZoom = [rs longForColumn:@"zoomMax"];
            startX = ([rs doubleForColumn:@"boundsE"] + [rs doubleForColumn:@"boundsW"]) / 2;
            startY = ([rs doubleForColumn:@"boundsN"] + [rs doubleForColumn:@"boundsS"]) / 2;
            datumShiftLng = [rs doubleForColumn:@"datumShiftLongitude"];
            datumShiftLat = [rs doubleForColumn:@"datumShiftLatitude"];
            startZ = [rs longForColumn:@"zoomMax"];
            boundsX = [rs doubleForColumn:@"minX"];
            boundsY = [rs doubleForColumn:@"minY"];
            boundsW = [rs doubleForColumn:@"maxX"] - boundsX;
            boundsH = [rs doubleForColumn:@"maxY"] - boundsY;
            
        //    RMProjectedRect theBounds = RMMakeProjectedRect([self boundsX], [self boundsY], [self boundsW], [self boundsH]);
            
//            gridProjection = [[RMProjection alloc] initWithString:[self boundsI] InBounds:theBounds];
//            
//            tileProjection = [[RMFractalTileProjection alloc] initFromProjection:[[self projection] retain]
//                                                                  tileSideLength:tileSideLength
//                                                                         maxZoom:maxZoom minZoom:minZoom];
//            
//            if ([self viewSideA]) {
//                cmd = @"SELECT z, minTX, maxTX, minTY, maxTY FROM ZoomLevels WHERE layerKey = 0";
//            } else {
//                cmd = @"SELECT z, minTX, maxTX, minTY, maxTY FROM ZoomLevels WHERE layerKey = 1";
//            }
            
           // FMResultSet * rs2 = [db executeQuery:cmd];
          //  while ([rs2 next]) {
              //  long long unsigned int tz = [rs2 longForColumn:@"z"] ;
              //  long long unsigned int tyMax = pow(2,tz) - (1 + [rs2 intForColumn:@"minTY"]);
               // long long unsigned int tyMin = pow(2,tz) - (1 + [rs2 intForColumn:@"maxTY"]);
//                [tileProjection setZoomBounds:tz xMin:[rs2 intForColumn:@"minTX"] xMax:[rs2 intForColumn:@"maxTX"]  yMin:tyMin yMax:tyMax];
          //  }
            
           // [rs2 close];
        } else if([db hadError]) {
            NSLog(@"DB Error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
        }
        [rs close];
}

- (UIImage*)imageFromOldDataBasewithTiles:(RMTile)_tile {
    
    __block UIImage *tilesImage = nil;
    // get the unique key for the tile
    long long unsigned int zoom = (int) _tile.zoom;
    long long unsigned int tx = _tile.x;
    long long unsigned int zy = _tile.y;
    long long unsigned int ty = pow(2,(float) zoom) - (1 + (int)_tile.y);
    //NSNumber* akey = (zoom << 36) | (x << 18) | (y << 0);
    long long unsigned int akey = zoom * pow(2,36) + tx * pow(2,18) + ty;
    
    NSNumber* key = [NSNumber numberWithLongLong:akey];
    
    //key = (uint64_t) 618540564709;
    NSLog(@"fetching tile (%d -%llu- %d -%d- %d)", tx, zy, _tile.zoom,key);
    
    // fetch the image from the db
    NSString *cmd = @"select image from Tiles where layerKey=1 and key = ?";
    if ([self viewSideA]) {
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

-(int)tileSideLength {
    return tileSideLength;
}


#pragma mark RMTileSource methods

-(float) minZoom {
    return minZoom;
}

-(float) maxZoom {
    return maxZoom;
}


-(NSString*) tileURL: (RMTile) tile {
    return nil;
}

-(NSString*) tileFile: (RMTile) tile {
    return nil;
}

-(NSString*) tilePath {
    return nil;
}

//-(RMTileImage *)tileImage:(RMTile)tile {
//    
//    tile = [tileProjection normaliseTile:tile];
//    //return [RMTileImage imageWithTile:tile FromDB:db withTemplate:@""];
//    return [RMTileImage imageWithTile:tile FromDB:db sideA:viewSideA withTemplate:tmsTemplate];
//}

//-(id<RMMercatorToTileProjection>) mercatorToTileProjection {
//    return [[tileProjection retain] autorelease];
//}

//-(RMProjection *) projection {
//    return [[gridProjection retain] autorelease];
//}

-(BOOL)isInitialized {
    return isInitialized;
}
-(float)datumShiftLng {
    return datumShiftLng;
}
-(float)datumShiftLat {
    return datumShiftLat;
}
-(float)startX {
    return startX;
}
-(float)startY {
    return startY;
}
-(float)startZ {
    return startZ;
}
-(float)boundsX {
    return boundsX;
}
-(float)boundsY {
    return boundsY;
}
-(float)boundsW {
    return boundsW;
}
-(float)boundsH {
    return boundsH;
}
-(NSString*) boundsI
{
    return boundsI;
}

-(NSString*) uniqueTilecacheKey {
    return nil;
}

-(NSString *)shortName {
    
    return [self getPreferenceAsString:kShortNameKey];
}

-(NSString *)longDescription {
    return [self getPreferenceAsString:kLongDescriptionKey];
}

-(NSString *)shortAttribution {
    return [self getPreferenceAsString:kShortAttributionKey];
}

-(NSString *)longAttribution {
    return [self getPreferenceAsString:kLongAttributionKey];
}

-(void)removeAllCachedImages {
    // no-op
}

#pragma mark preference methods

-(NSString*)getPreferenceAsString:(NSString*)name {
    
     NSString* value = nil;
     FMResultSet *results = [_fmdb executeQuery:@"select value from preferences where name = ?", name];
     if ([results next]) {
         value = [results stringForColumn:@"value"];
     }
     [results close];
     return value;
}

-(float)getPreferenceAsFloat:(NSString*)name {
    NSString* value = [self getPreferenceAsString:name];
    return (value == nil) ? INT_MIN : [value floatValue];
}

-(int)getPreferenceAsInt:(NSString*)name {
    NSString* value = [self getPreferenceAsString:name];
    return (value == nil) ? INT_MIN : [value intValue];
}

@end
