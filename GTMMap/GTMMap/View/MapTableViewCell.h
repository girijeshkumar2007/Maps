//
//  MapTableViewCell.h
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapModel.h"
#import "FFCircularProgressView.h"

typedef NS_ENUM(NSInteger, CellType) {
    
    kTypeMapCell,
    kTypeIndexCell
};

@interface MapTableViewCell : UITableViewCell
{
   
}
-(void)configureCellWithType:(CellType)cellType Object:(MapModel*)mapObject;

@end
