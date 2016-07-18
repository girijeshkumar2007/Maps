//
//  CoreDataManager.m
//  CoreDataManager
//
//  Created by Saurabh Verma on 09/07/14.
//  Copyright (c) 2014 Copper Mobile Inc. All rights reserved.
//

#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "NetworkURLs.h"
#import "MapModel.h"
#import "Map+CoreDataProperties.h"
#import "Map.h"
#import "MKStoreKit.h"
#import "GTMDownloadingFile.h"

@interface CoreDataManager ()
@property (readonly, strong, nonatomic) NSManagedObjectContext *writerManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectContext *privateManagedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator* persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectModel* managedObjectModel;
/** 
 *	Returns the managed object model for the application.
 *	If the model doesn't exist, it is created from the application's model.
 *	@return Object of 'NSManagedObjectModel' class.
 */
- (NSManagedObjectModel *)managedObjectModel;
/**
 *	Returns the main thread managed object context for the application.
 *	If the context doesn't exist, it is created and bound to the persistent store coordinator for
 *	the application.
 *	@return Object of 'NSManagedObjectContext' class.
 */
- (NSManagedObjectContext *)mainThreadManagedObjectContext;
/*
 *	Parent Context.
 */
- (NSManagedObjectContext *)writerManagedObjectContext;
/**
 *	Private Context.
 */
- (NSManagedObjectContext *)privateManagedObjectContext;
/**
 *	Returns the persistent store coordinator for the application.
 *	If the coordinator doesn't already exist, it is created and the application's store added to it.
 *	@return Object of 'NSPersistentStoreCoordinator' class.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

/**
 *	Returns the URL of Application/Library directory
 *	@return Object of 'NSURL' class.
 */
- (NSURL *)applicationLibraryDirectory;
@end

@implementation CoreDataManager
@synthesize mainThreadManagedObjectContext = _mainThreadManagedObjectContext;
@synthesize writerManagedObjectContext = _writerManagedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize privateManagedObjectContext = _privateManagedObjectContext;

static CoreDataManager *manager;
#pragma mark - Alloc Singleton Class Object
+ (instancetype)sharedCoreManager
{
#if ENABLE_LOGGING
  TRC_ENTRY()
#endif
  
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		manager = [[CoreDataManager alloc] init];
		
		[[NSNotificationCenter defaultCenter] addObserver:manager
																						 selector:@selector(contextDidSavePrivateQueueContext:)
																								 name:NSManagedObjectContextDidSaveNotification
																							 object:[manager privateManagedObjectContext]];
		[[NSNotificationCenter defaultCenter] addObserver:manager
																						 selector:@selector(contextDidSaveMainQueueContext:)
																								 name:NSManagedObjectContextDidSaveNotification
																							 object:[manager mainThreadManagedObjectContext]];
		
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
- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - PRIVATE METHODS
#pragma mark Core Data stack
- (NSManagedObjectContext *)mainThreadManagedObjectContext
{
	#if ENABLE_LOGGING
  TRC_ENTRY()
#endif
	if (_mainThreadManagedObjectContext != nil) {
		return _mainThreadManagedObjectContext;
	}
	
	_mainThreadManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	_mainThreadManagedObjectContext.parentContext = [self writerManagedObjectContext];
	
	return _mainThreadManagedObjectContext;
}
- (NSManagedObjectContext *)writerManagedObjectContext {
	if (_writerManagedObjectContext != nil) {
		return _writerManagedObjectContext;
	}
	
	NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (coordinator != nil) {
		_writerManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
		[_writerManagedObjectContext setPersistentStoreCoordinator:coordinator];
	}
	return _writerManagedObjectContext;
}
- (NSManagedObjectContext *)privateManagedObjectContext {
	if (_privateManagedObjectContext != nil) {
		return _privateManagedObjectContext;
	}
	
	_privateManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	_privateManagedObjectContext.parentContext = [self mainThreadManagedObjectContext];
	
	return _privateManagedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel
{
	#if ENABLE_LOGGING
  TRC_ENTRY()
#endif
	if (_managedObjectModel != nil) {
		return _managedObjectModel;
	}
	NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DATABASE_NAME withExtension:@"momd"];
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
	return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
	#if ENABLE_LOGGING
  TRC_ENTRY()
#endif
	if (_persistentStoreCoordinator != nil) {
		return _persistentStoreCoordinator;
	}
	
	NSURL *storeURL = [[self applicationLibraryDirectory] URLByAppendingPathComponent:[DATABASE_NAME stringByAppendingString:@".sqlite"]];
    NSLog(@"%@",storeURL);
    
	NSError *error = nil;
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
	if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
		
#if ENABLE_LOGGING
    DDLogWarn(@"Coredata Migration is not handled.");
#endif
		//TODO: Handle Migration here
		NSAssert(0, @"Coredata Migration is not handled.");
	}
	
	return _persistentStoreCoordinator;
}
- (NSURL *)applicationLibraryDirectory
{
	return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}
- (NSFetchRequest *)getBasicRequestForEntityName:(NSString *)entityName
{
#if ENABLE_LOGGING
  TRC_ENTRY()
#endif
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
																						inManagedObjectContext:self.privateManagedObjectContext];
	[request setEntity:entity];
	
	return request;
}
#pragma mark NOTIFICATION METHODS
- (void)contextDidSavePrivateQueueContext:(NSNotification *)notification
{
	dispatch_sync(dispatch_get_main_queue(), ^{
		@synchronized(self) {
			[self.mainThreadManagedObjectContext performBlockAndWait:^{
                
				[self.mainThreadManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
				NSError *error = nil;
				[self.mainThreadManagedObjectContext save:&error];
			}];
		}
	});
}

- (void)contextDidSaveMainQueueContext:(NSNotification *)notification
{
		@synchronized(self) {
			[self.writerManagedObjectContext performBlock:^{
				[self.writerManagedObjectContext mergeChangesFromContextDidSaveNotification:notification];
				NSError *error = nil;
				[self.writerManagedObjectContext save:&error];
			}];
		}
}
#pragma mark - PUBLIC METHODS
- (void)saveContext
{
#if ENABLE_LOGGING
  TRC_ENTRY()
#endif
	[_privateManagedObjectContext performBlock:^{
		// Save the context.
		NSError *error = nil;
		if (![_privateManagedObjectContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
#if ENABLE_LOGGING
      DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		}
	}];
	
#if ENABLE_LOGGING
  TRC_EXIT()
#endif
}
- (void)deleteEntity:(NSManagedObject*)entity {

	if (!entity) {
    return;
	}
	[_privateManagedObjectContext performBlock:^ {
		[self.privateManagedObjectContext deleteObject:entity];
		
		// Save the context.
		NSError *error = nil;
		if (![_privateManagedObjectContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
#if ENABLE_LOGGING
      DDLogError(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
		}
	}];
}
- (void)deleteEntityFromMainThreadContext:(NSManagedObject*)entity {
	
	[_mainThreadManagedObjectContext performBlock:^ {
		[self.mainThreadManagedObjectContext deleteObject:entity];
		
		[self saveContext];
	}];
}
- (void)deleteEntities:(NSArray*)entities withCompletionBlock:(void (^)())block {
	
	[_privateManagedObjectContext performBlock:^ {
		
		for (NSManagedObject* entity in entities) {
            
			[_privateManagedObjectContext deleteObject:entity];
		}
		
		// Save the context.
		NSError *error = nil;
		if (![_privateManagedObjectContext save:&error]) {
			// Replace this implementation with code to handle the error appropriately.
			// abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//#if ENABLE_LOGGING
      NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//#endif
		}
	}];
}
- (NSManagedObject*)getStoredEntityWithName:(NSString*)entityName
																	predicate:(NSPredicate*)predicate
																		sortKey:(NSString*)sortKey
{
#if ENABLE_LOGGING
  TRC_ENTRY()
#endif
	__block NSManagedObject* entity = nil;
		
		NSFetchRequest *request = [self getBasicRequestForEntityName:entityName];
		if (predicate) {
			[request setPredicate:predicate];
		}
		if (sortKey) {
			NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:NO];
			NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
			[request setSortDescriptors:sortDescriptors];
		}
		
		NSError* error = nil;
		NSArray* results = [self.privateManagedObjectContext executeFetchRequest:request error:&error];
		
		if (error) {
#if ENABLE_LOGGING
      DDLogError(@"Fetch request error on %@: %@",entityName, [error localizedDescription]);
#endif
		}
		else {
			entity = [results firstObject];
		}
	
	#if ENABLE_LOGGING
  TRC_EXIT()
#endif
	return entity;
}
- (NSArray*)getListofEntityWithName:(NSString*)entityName
                          predicate:(NSPredicate*)predicate
                            sortKey:(NSString*)sortKey {
  #if ENABLE_LOGGING
  TRC_ENTRY()
#endif
	__block NSArray* entities = nil;
  
  NSFetchRequest *request = [self getBasicRequestForEntityName:entityName];
  if (predicate) {
    [request setPredicate:predicate];
  }
  if (sortKey) {
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [request setSortDescriptors:sortDescriptors];
  }
  
  NSError* error = nil;
  NSArray* results = [self.privateManagedObjectContext executeFetchRequest:request error:&error];
  
  if (error) {
#if ENABLE_LOGGING
    DDLogError(@"Fetch request error on %@: %@",entityName, [error localizedDescription]);
#endif
  }
  else {
    entities = [NSArray arrayWithArray:results];
  }
	
	#if ENABLE_LOGGING
  TRC_EXIT()
#endif
  return entities;
}
- (NSInteger)totalObjectsCountFromEntity:(NSString *)entityName
                          withPredicate:(NSPredicate *)predicate {
  #if ENABLE_LOGGING
  TRC_ENTRY()
#endif
  NSFetchRequest *request = [self getBasicRequestForEntityName:entityName];
  if (predicate != nil)
    [request setPredicate: predicate];
  
  [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
  
  NSError *error = nil;
  NSUInteger count = [self.privateManagedObjectContext countForFetchRequest:request error:&error];
  
  if (count == NSNotFound) {
    // Handle error
    return 0;
  } else {
    return count;
  }
}
- (NSManagedObject*)createEntityWithName:(NSString*)entityName
{
	#if ENABLE_LOGGING
  TRC_ENTRY()
#endif
	__block NSManagedObject* entity = nil;
		
	entity = [NSEntityDescription insertNewObjectForEntityForName:entityName
																					 inManagedObjectContext:self.privateManagedObjectContext];
	#if ENABLE_LOGGING
  TRC_EXIT()
#endif
	return entity;
}
- (void)resetDatabase
{
  NSArray *stores = [_persistentStoreCoordinator persistentStores];
  
  for(NSPersistentStore *store in stores) {
    [_persistentStoreCoordinator removePersistentStore:store error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
  }
  _persistentStoreCoordinator = nil;
  _writerManagedObjectContext = nil;
  _privateManagedObjectContext = nil;
  _mainThreadManagedObjectContext = nil;
  _managedObjectModel = nil;
	
  //D-i15 is fixed
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[[NSNotificationCenter defaultCenter] addObserver:manager
																					 selector:@selector(contextDidSavePrivateQueueContext:)
																							 name:NSManagedObjectContextDidSaveNotification
																						 object:[manager privateManagedObjectContext]];
	[[NSNotificationCenter defaultCenter] addObserver:manager
																					 selector:@selector(contextDidSaveMainQueueContext:)
																							 name:NSManagedObjectContextDidSaveNotification
																						 object:[manager mainThreadManagedObjectContext]];
}

#pragma mark - Fetch Model Object
-(void)fetchFromLocalDataBaseBlock:(void (^)(NSMutableArray *arrOfList))block
{
    NSMutableArray *arrOfList = [NSMutableArray array];
    NSArray *arr = [self getListofEntityWithName:@"Map" predicate:nil sortKey:nil];
    for (Map *map  in arr) {
        
        MapModel *mapModel=[self createMapModelObjectWith:map];
        [arrOfList addObject:mapModel];
    }
    block(arrOfList);
}
#pragma mark -- Parse MapList
-(void)parseMapListData:(NSArray*)arrOfMapList block:(void (^)(NSMutableArray *arrOfList))block
{
    NSMutableArray *arrOfList = [NSMutableArray array];
    if (![arrOfMapList isKindOfClass:[NSArray class]]|| arrOfMapList.count==0) {
        block(arrOfList);
    }
    for (NSDictionary *mapDic in arrOfMapList) {
        
        Map *map = [self parseMapListInfoStored:mapDic];
        if (map){
            MapModel *mapModel=[self createMapModelObjectWith:map];
            [arrOfList addObject:mapModel];
        }
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (appleID IN %@)",[arrOfList valueForKey:@"appleID"]];
    NSArray *deleteMaps = [self getListofEntityWithName:@"Map" predicate:predicate sortKey:nil];
    if (deleteMaps.count==0) {
        [self saveContext];
        dispatch_async(dispatch_get_main_queue(), ^{
            block(arrOfList);
         });
    }
    else{
        
        for (Map *map in deleteMaps) {
            
            if ([[GTMDownloadingFile sharedCoreManager] fileExistsForUrl:map.mapUrl]) {
                
               BOOL isDel= [[GTMDownloadingFile sharedCoreManager] deleteFileForUrl:map.mapUrl];
                if (isDel) {
                    NSLog(@"isDel %@",map.mapUrl);
                }
                else{
                    NSLog(@"Not isDel %@",map.mapUrl);
                }
            } 
        }
        
        
        [self deleteEntities:deleteMaps withCompletionBlock:^{
            [self saveContext];
            dispatch_async(dispatch_get_main_queue(), ^{
            block(arrOfList);
            });
        }];
    }
}




-(MapModel*)createMapModelObjectWith:(Map*)mapObj{
    
    MapModel *mapModel=[[MapModel alloc] initWithFileTitle:mapObj.mapNumber andDownloadSource:mapObj.mapUrl];
    [mapModel updateMapModelObjectWith:mapObj];
    return mapModel;
}



//{
//    addedOn = "2016-06-21 15:18:47";
//    appleID = "com.greentrailsmaps.inappHI03.mbtiles";
//    checksum = 1546;
//    company = "Dharma Maps";
//    coverage = "";
//    "current_Issue" = 2006;
//    datum = WGS84;
//    id = 2;
//    index = 8;
//    "is_new" = yes;
//    location = "";
//    mapSourceLabels = "";
//    mapSourceMode = "";
//    mapSourceOpacities = "";
//    mapSourceTMSTemplate = "";
//    name = Kuauai;
//    notes = "";
//    "original_Issue" = 2006;
//    price = "0.99";
//    projection = UTM;
//    pubDate = "0000-00-00";
//    region = "Pacific Ocean";
//    scale = "1:100000";
//    series = "";
//    size = "";
//    state = Hawaii;
//    status = "";
//    tapSearchMode = "";
//    url = "http://www.dharmamaps.com/gtm/MapList/HI03.mbtiles";
//    version = "1.0";
//}

- (Map*)parseMapListInfoStored: (NSDictionary*)postInfo{
    
    //    DLog(@"%@", postInfo);
    NSString *appleID=[postInfo objectForKey:@"appleID"];
    if (appleID==nil) {
        return nil;
    }
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"appleID=%@",appleID];
    Map* mapObj = (Map*)[self getStoredEntityWithName:@"Map" predicate:predicate sortKey:nil];
    if (mapObj == nil) {
        
        mapObj = [NSEntityDescription
                     insertNewObjectForEntityForName:@"Map"
                     inManagedObjectContext: self.privateManagedObjectContext];
    }
    [mapObj updateMapInfoStoredWithDic:postInfo];
    return mapObj;
}

- (void)updateDownlaodStatusMapinfo: (NSString*)appleID{
    
    //    DLog(@"%@", postInfo);
    if (appleID==nil) {
        return ;
    }
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"appleID=%@",appleID];
    Map* mapObj = (Map*)[self getStoredEntityWithName:@"Map" predicate:predicate sortKey:nil];
    if (mapObj) {
        mapObj.isPurchased=@(1);
        mapObj.isDownload=@(1);
    }
    [self saveContext];
}

#pragma mark - Fetch All Objects
- (NSArray *)fetchObjectsFromModel:(NSString*)model withPredicate:(NSPredicate*)predicate andSortKey: (NSString*)key page:(int)page pageSize: (int) pageSize
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    // Edit the entity name as appropriate.
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:model
                                                         inManagedObjectContext:[self mainThreadManagedObjectContext]];
    [fetchRequest setEntity:entityDescription];
    
    // Set the batch size to a suitable number.
    //[fetchRequest setFetchBatchSize:0];
    if (pageSize != 0) {
        [fetchRequest setFetchLimit:pageSize];
    }
    if (page > 0) {
        [fetchRequest setFetchOffset:(page - 1) *pageSize];
    }
    
    if(predicate != nil)
        [fetchRequest setPredicate: predicate];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey: (key) ? key : @"dateTime" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[self mainThreadManagedObjectContext] sectionNameKeyPath:nil cacheName:@"Master"];
    
    
    NSError *error = nil;
    if (![aFetchedResultsController performFetch:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return [aFetchedResultsController fetchedObjects];
}

- (NSInteger)totalObjectsCountFromModel:(NSString* )model withPredicate:(NSPredicate*)predicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:model inManagedObjectContext:[self mainThreadManagedObjectContext]]];
    
    if(predicate != nil)
        [request setPredicate: predicate];
    
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)
    
    NSError *error = nil;
    
    
    NSUInteger count = [self.mainThreadManagedObjectContext countForFetchRequest:request error:&error];
    
    if(count == NSNotFound)
    {
        //Handle error
        return 0;
    }
    else
    {
        return count;
    }
}

@end
