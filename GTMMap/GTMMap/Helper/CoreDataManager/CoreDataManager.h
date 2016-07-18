//
//  CoreDataManager.h
//  CoreDataManager
//
//  Created by Saurabh Verma on 09/07/14.
//  Copyright (c) 2014 Copper Mobile Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define ENABLE_LOGGING    0
#define DATABASE_NAME     @"GTMMap"

@class NSManagedObject;
/**
 *	'CoreDataManager' creates the persistent store, managed object context objects and responsible
 *	for insert, fetch, update, delete coredata models.
 *	NOTE: Shared manager, Do not alloc init this class and do not inherit this class.
 */
@interface CoreDataManager : NSObject
/*
 *	returns the main thread managed object context.
 */
@property (nonatomic, retain) NSManagedObjectContext* mainThreadManagedObjectContext;
/**
 Creates the Singleton Object of 'CoreDataManager'.
 @return singleton Object of 'CoreDataManager'.
 */
+ (instancetype)sharedCoreManager;
/**
 * @details Save the context in coredata.
 **/
- (void)saveContext;
/**
 *	Fetch the Stored Entity from coredate given name and predicate. Sort the result on given |sortKey|
 *	@param entityName Name of the Entity to be fetched.
 *	@param predicate to be set on Fetch request.
 *	@param sortKey Sort the result on sortKey.
 *	@return NSManagedObject object.
 */
- (NSManagedObject*)getStoredEntityWithName:(NSString*)entityName
																	predicate:(NSPredicate*)predicate
																		sortKey:(NSString*)sortKey;
/**
 *	Fetch all the Stored Entity from coredate given name and predicate. Sort the result on given |sortKey|
 *	@param entityName Name of the Entity to be fetched.
 *	@param predicate to be set on Fetch request.
 *	@param sortKey Sort the result on sortKey.
 *	@return NSArray object.
 */
- (NSArray*)getListofEntityWithName:(NSString*)entityName
																	predicate:(NSPredicate*)predicate
																		sortKey:(NSString*)sortKey;
/**
 *  Fetch the total number of Stored Entity from coredate given name and predicate.
 *
 *  @param entityName Name of the Entity to be fetched
 *  @param predicate  to be set on Fetch request.
 *
 *  @return total number of count
 */
- (NSInteger)totalObjectsCountFromEntity:(NSString *)entityName
                           withPredicate:(NSPredicate *)predicate;
/**
 *	Create new entity by name in managed object context.
 *	@param entityName Name of the entity
 *	@return NSManagedObject object.
 */
- (NSManagedObject*)createEntityWithName:(NSString*)entityName;
/**
 * @details Delete NSManagedObject from NSManagedObjectContext and save the context.
 * @param entity NSManagedObject to delete.
 **/
- (void)deleteEntity:(NSManagedObject*)entity;
/**
 *	@details Delete NSManagedObject from Main Thread NSManagedObjectContext and save the context.
 *	@param entity NSManagedObject to delete.
 */
- (void)deleteEntityFromMainThreadContext:(NSManagedObject*)entity;
/**
 *	Delete entities from NSManagedObjectContext and save the context.
 *	@param entities array of 'NSManagedObject' objects.
 *	@param block A block to be called when |entities| are deleted.
 */
- (void)deleteEntities:(NSArray*)entities withCompletionBlock:(void (^)())block;
/**
 *  Remove the Dart.sqlite file from library directory and set persistentStore and context as nil.
 */
- (void)resetDatabase;
-(void)fetchFromLocalDataBaseBlock:(void (^)(NSMutableArray *arrOfList))block;
-(void)parseMapListData:(NSArray*)arrOfMapList block:(void (^)(NSMutableArray *arrOfList))block;
- (void)updateDownlaodStatusMapinfo: (NSString*)appleID;

@end
