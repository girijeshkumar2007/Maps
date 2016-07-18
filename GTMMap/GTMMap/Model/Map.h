//
//  Map.h
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface Map : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
- (void)updateMapInfoStoredWithDic: (NSDictionary*)postInfo;

@end

NS_ASSUME_NONNULL_END

#import "Map+CoreDataProperties.h"
