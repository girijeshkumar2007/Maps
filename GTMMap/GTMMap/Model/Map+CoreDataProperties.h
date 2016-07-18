//
//  Map+CoreDataProperties.h
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Map.h"

NS_ASSUME_NONNULL_BEGIN

@interface Map (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *appleID;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *mapNumber;
@property (nullable, nonatomic, retain) NSString *company;
@property (nullable, nonatomic, retain) NSString *state;
@property (nullable, nonatomic, retain) NSString *region;
@property (nullable, nonatomic, retain) NSString *index;
@property (nullable, nonatomic, retain) NSString *mapUrl;
@property (nullable, nonatomic, retain) NSString *mapNotes;
@property (nullable, nonatomic, retain) NSNumber *isNew;
@property (nullable, nonatomic, retain) NSString *mapSourceMode;
@property (nullable, nonatomic, retain) NSString *mapLocations;
@property (nullable, nonatomic, retain) NSString *pubDate;
@property (nullable, nonatomic, strong) NSNumber *size;
@property (nullable, nonatomic, strong) NSNumber *isPurchased;
@property (nonatomic, assign) NSNumber *isDownload;

@end

NS_ASSUME_NONNULL_END
