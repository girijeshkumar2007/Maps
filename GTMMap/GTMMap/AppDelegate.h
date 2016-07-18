//
//  AppDelegate.h
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, copy) void(^backgroundTransferCompletionHandler)();

@end

