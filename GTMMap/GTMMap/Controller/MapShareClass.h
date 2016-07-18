//
//  MapShareClass.h
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol MapCustomDeletagte <NSObject>

-(void)reloadTableView;
-(void)downloadingMapId:(NSString*)mapId status:(float)downloding;
-(void)updateCellWithMapId:(NSString*)mapAppleId;

@end

@interface MapShareClass : NSObject
{
    
}
@property(nonatomic,assign)id<MapCustomDeletagte> delegate;
@property(nonatomic,strong)NSArray *arrOfMapList;
@property(nonatomic,strong)NSArray *arrOfMapIndexList;
@property(nonatomic,strong)NSMutableArray *arrOfMapFullList;

+ (instancetype) sharedMapShareClass;
-(void)fetchMapListFromServer;

@end
