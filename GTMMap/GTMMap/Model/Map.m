//
//  Map.m
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import "Map.h"
#import "MKStoreKit.h"
#import "CoreDataManager.h"

@implementation Map

// Insert code here to add functionality to your managed object subclass

- (void)updateMapInfoStoredWithDic: (NSDictionary*)postInfo{
    
    // These Are STAddress attributes
    if ([postInfo objectForKey:@"appleID"] && ![[postInfo objectForKey:@"appleID"] isKindOfClass:[NSNull class]]) {
        self.appleID = [postInfo objectForKey: @"appleID"];
    }
    if ([postInfo objectForKey:@"name"] && ![[postInfo objectForKey:@"name"] isKindOfClass:[NSNull class]]) {
        self.name = [postInfo objectForKey: @"name"] ;
    }
    if ([postInfo objectForKey:@"mapNo"] && ![[postInfo objectForKey:@"mapNo"] isKindOfClass:[NSNull class]]) {
        
        self.mapNumber = [postInfo objectForKey: @"mapNo"];
    }
    if ([postInfo objectForKey:@"company"] && ![[postInfo objectForKey:@"company"] isKindOfClass:[NSNull class]]) {
        self.company = [postInfo objectForKey: @"company"] ;
    }
    if ([postInfo objectForKey:@"state"] && ![[postInfo objectForKey:@"state"] isKindOfClass:[NSNull class]]) {
        self.state = [postInfo objectForKey: @"state"];
    }
    if ([postInfo objectForKey:@"region"] && ![[postInfo objectForKey:@"region"] isKindOfClass:[NSNull class]]) {
        self.region = [postInfo objectForKey: @"region"];
    }
    if ([postInfo objectForKey:@"url"] && ![[postInfo objectForKey:@"url"] isKindOfClass:[NSNull class]]) {
        self.mapUrl = [postInfo objectForKey: @"url"];
    }
    if ([postInfo objectForKey:@"index"] && ![[postInfo objectForKey:@"index"] isKindOfClass:[NSNull class]]) {
        NSDictionary *dicIndex = [postInfo objectForKey:@"index"];
        if ([dicIndex objectForKey:@"mapindex"]) {
            self.index = [dicIndex objectForKey:@"mapindex"];
        }
    }
    if ([postInfo objectForKey:@"notes"] && ![[postInfo objectForKey:@"notes"] isKindOfClass:[NSNull class]]) {
        self.mapNotes = [postInfo objectForKey: @"notes"];
    }
    if ([postInfo objectForKey:@"is_new"] && ![[postInfo objectForKey:@"is_new"] isKindOfClass:[NSNull class]]) {
        self.isNew = @([[postInfo objectForKey: @"is_new"] boolValue]);
    }
    
    if ([postInfo objectForKey:@"mapSourceMode"] && ![[postInfo objectForKey:@"mapSourceMode"] isKindOfClass:[NSNull class]]) {
        self.mapSourceMode = [postInfo objectForKey: @"mapSourceMode"];
    }
    
    if ([postInfo objectForKey:@"location"] && [[postInfo objectForKey:@"location"] isKindOfClass:[NSArray class]]) {
        
        NSError *error=nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[postInfo objectForKey: @"location"] options:NSJSONWritingPrettyPrinted error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //        NSLog(@"jsonData as string:\n%@", jsonString);
        self.mapLocations = jsonString;
    }
    if ([postInfo objectForKey:@"current_Issue"] && ![[postInfo objectForKey:@"current_Issue"] isKindOfClass:[NSNull class]]) {
        
        self.pubDate = [postInfo objectForKey: @"current_Issue"];
    }
    self.isPurchased = @([[MKStoreKit sharedKit]isProductPurchased:self.appleID]);
    
    self.isPurchased=@(1);
}
@end
