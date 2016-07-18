//
//  MapShareClass.m
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import "MapShareClass.h"
#import "MKStoreKit.h"
#import "NetworkManager.h"
#import "SVProgressHUD.h"
#import "CoreDataManager.h"
#import "MKStoreKit.h"
#import "MapModel.h"
@import StoreKit;

@implementation MapShareClass

+ (instancetype) sharedMapShareClass {
    
    static dispatch_once_t pred = 0;
    static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    
    if (self = [super init]) {
        
        _arrOfMapFullList = [NSMutableArray array];
        [self coreDataMapListSaveNotification];
    }
    return self;
}

#pragma mark - Public Method
-(void)fetchMapListFromServer
{
    [self initilizeIAPInfo];
   [SVProgressHUD showWithStatus:KParamKeyLoading];
    NSDictionary *param=@{};
   [[NetworkManager manager] requestApiWithName:kAllMaps requestType:kHTTPMethodGET postData:param callBackBlock:^(id response, NSError *error) {
       if (error) {
           
           NSLog(@"error-> %@",error.description);
           [[CoreDataManager sharedCoreManager] fetchFromLocalDataBaseBlock:^(NSMutableArray *arrOfList) {
               
               [self parseDataReponseArray:arrOfList];
           }];
       }
       else{
           
           [_arrOfMapFullList removeAllObjects];
           [[CoreDataManager sharedCoreManager] parseMapListData:response[@"data"] block:^(NSMutableArray *arrOfList) {
               
               [self parseDataReponseArray:arrOfList];
           }];
       }
       [SVProgressHUD dismiss];
   }];
}
-(void)refreshData
{
    [_arrOfMapFullList removeAllObjects];
    _arrOfMapList=nil;
    _arrOfMapIndexList=nil;

    if ([_delegate respondsToSelector:@selector(reloadTableView)]) {
        
        [_delegate reloadTableView];
    }
    [self fetchMapListFromServer];
}

#pragma mark - Private Methods
-(void)parseDataReponseArray:(NSArray*)arrOfList
{
    
    [_arrOfMapFullList addObjectsFromArray:arrOfList];
    _arrOfMapList=_arrOfMapFullList;
    [self updateIndexArray];
    [[MKStoreKit sharedKit] startProductRequest];
    if ([_delegate respondsToSelector:@selector(reloadTableView)]) {

        [_delegate reloadTableView];
    }
}


-(void)coreDataMapListSaveNotification{
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:[[CoreDataManager sharedCoreManager] mainThreadManagedObjectContext] queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       
        NSLog(@"coreDataMapListSaveNotification %@",note);
    }];
}
-(void)initilizeIAPInfo
{
    [[MKStoreKit sharedKit] startProductRequest];
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        NSLog(@"kMKStoreKitProductsAvailableNotification %@",note.object);

        for (SKProduct *product in note.object) {
            
            NSPredicate *predicate =[NSPredicate predicateWithFormat:@"appleID==%@",product.productIdentifier];
            NSArray *filter =[self.arrOfMapFullList filteredArrayUsingPredicate:predicate];
            if (filter.count) {
                MapModel *model =[filter lastObject];
                model.mapStatus=kMapNotPurchased;
            }
        }
        [_delegate reloadTableView];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       
        NSLog(@"Purchased Notification %@",note.object);
        SKPaymentTransaction *payment = note.object;
        [self updateProductWithAppId:payment.payment.productIdentifier isPuchased:YES];

    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseFailedNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        SKPaymentTransaction *payment = note.object;
        NSLog(@"product Identifier %@",payment.payment.productIdentifier);
        [self updateProductWithAppId:payment.payment.productIdentifier isPuchased:NO];

    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseDeferredNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        
        NSLog(@"Deferred Notification %@",note.object);
        SKPaymentTransaction *payment = note.object;
        [self updateProductWithAppId:payment.payment.productIdentifier isPuchased:NO];
    }];
}

-(void)updateProductWithAppId:(NSString*)productIdentifier isPuchased:(BOOL)isPurchsed{
    
    NSLog(@"Failed productIdentifier %@",productIdentifier);
    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"appleID==%@",productIdentifier];
    NSArray *filter =[self.arrOfMapFullList filteredArrayUsingPredicate:predicate];
    if (filter.count) {
        MapModel *model =[filter lastObject];
        model.mapStatus=(isPurchsed)?kMapPurchased:kMapNotPurchased;
        [_delegate updateCellWithMapId:model.appleID];
    }
    [self updateIndexArray];
}
-(void)updateIndexArray
{
    NSPredicate *purchasedPredicate =[NSPredicate predicateWithFormat:@"mapStatus==%d",kMapAvailable];
    NSArray *purFilter =[self.arrOfMapFullList filteredArrayUsingPredicate:purchasedPredicate];
    _arrOfMapIndexList = purFilter;
}
@end
