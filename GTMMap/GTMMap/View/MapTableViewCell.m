//
//  MapTableViewCell.m
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import "MapTableViewCell.h"
#import "MKStoreKit.h"
#import <StoreKit/StoreKit.h>
#import "GTMDownloadingFile.h"
#import "CoreDataManager.h"
#import "AppDelegate.h"

@interface MapTableViewCell ()
{
    IBOutlet UILabel *storeConnectLabel;
    IBOutlet UILabel *mapNameLabel;
    IBOutlet UILabel *mapInfoLabel;
    IBOutlet UILabel *mapSizeLabel;
    IBOutlet UILabel *mapNumberLabel;
    IBOutlet UILabel *pubDateLabel;
    IBOutlet UIButton *purchaseBut;
    IBOutlet FFCircularProgressView *circularProgressView;
    IBOutlet UIButton *downloadingBtn;
    IBOutlet UIActivityIndicatorView * spinner;
}
@property (nonatomic, assign)int cellType;
@property (nonatomic, strong)MapModel *mapModel;
@property (strong, nonatomic)ProgessBlock progressBlock;
@property (strong, nonatomic)CompleteBlock completionBlock;
@end

@implementation MapTableViewCell

-(void)updateCell
{
    
    [purchaseBut setTitleColor:[UIColor colorWithRed:37.0/255.0 green:161.0/255.0 blue:85.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [purchaseBut.layer setBorderWidth:1.0];
    [purchaseBut.layer setMasksToBounds:YES];
    [purchaseBut.layer setCornerRadius:5.0];
    [purchaseBut.layer setBorderColor:[UIColor colorWithRed:37.0/255.0 green:161.0/255.0 blue:85.0/255.0 alpha:1.0].CGColor];
    
    if(_mapModel.mapStatus == kMapNotPurchased){
        
        [storeConnectLabel setHidden:YES];
        [purchaseBut setHidden:NO];
        [purchaseBut setUserInteractionEnabled:YES];
        [mapSizeLabel setHidden:YES];
        [spinner setHidden:YES];
        [spinner stopAnimating];
        [circularProgressView setHidden:YES];
        [downloadingBtn setHidden:YES];

    }
    else if(_mapModel.mapStatus == kMapInPurchase || _mapModel.mapStatus == kMapHasNoIAPInfo){
        
        if(_mapModel.mapStatus == kMapHasNoIAPInfo){
            
            [storeConnectLabel setHidden:NO];
        }
        else{
            
            [storeConnectLabel setHidden:YES];
        }
        
        [mapSizeLabel setHidden:YES];
        [spinner setHidden:NO];
        [spinner startAnimating];
        [circularProgressView setHidden:YES];
        [downloadingBtn setHidden:YES];
        [purchaseBut setHidden:YES];
    }
    else if(_mapModel.mapStatus == kMapInDownload||_mapModel.mapStatus == kMapPurchased){
        
        [circularProgressView setHidden:NO];
        [downloadingBtn setHidden:NO];
        [storeConnectLabel setHidden:YES];
        [purchaseBut setHidden:YES];
        [mapSizeLabel setHidden:NO];
        [spinner setHidden:YES];
        
        if (_mapModel.mapStatus == kMapPurchased) {
            
            [[GTMDownloadingFile sharedCoreManager] startDownloadingWithMap:_mapModel];
        }
    }
    else if(_mapModel.mapStatus == kMapDownloadPushed){
        
        [circularProgressView stopSpinProgressBackgroundLayer];
        [circularProgressView setHidden:NO];
        [downloadingBtn setHidden:NO];
        
        [storeConnectLabel setHidden:YES];
        [purchaseBut setHidden:YES];
        [mapSizeLabel setHidden:NO];
        [spinner setHidden:YES];
    }
    else if(_mapModel.mapStatus == kMapAvailable)
    {
        [circularProgressView setHidden:YES];
        [storeConnectLabel setHidden:YES];
        [mapSizeLabel setHidden:YES];
        [spinner setHidden:YES];
        [spinner stopAnimating];
        [mapSizeLabel setHidden:YES];
        
        [purchaseBut setHidden:NO];
        [purchaseBut setTitle:@"View" forState:UIControlStateNormal];
        [purchaseBut setTitle:@"View" forState:UIControlStateHighlighted];
        [purchaseBut setTitle:@"View" forState:UIControlStateSelected];
        [purchaseBut setUserInteractionEnabled:YES];
    }
}

// is this needed anymore?
- (void)timeout:(id)arg {
    
    if(_mapModel.mapStatus == kMapInPurchase)
    {
        _mapModel.mapStatus = kMapNotPurchased;
        NSLog(@"Timeout!");
        [self updateCell];
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - User Intraction
-(IBAction)MapInfoButtonPressed {

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:_mapModel.name message:_mapModel.mapNotes   preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    AppDelegate *appdel = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [appdel.window.rootViewController presentViewController:alert animated:YES completion:nil];
}
-(IBAction)purchaseMapPressed {
    
    switch (_mapModel.mapStatus) {
            
        case kMapHasNoIAPInfo:
            [self updateCell];
            break;
        case kMapNotPurchased:{
            
            [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:_mapModel.appleID];
            _mapModel.mapStatus=kMapInPurchase;
            [self updateCell];
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:60*7];
        }
            break;
        case kMapAvailable:
            
            break;
        default:
            
            break;
    }
}

-(IBAction)downloadingButtonPressed:(id)sender
{
    
    switch (_mapModel.mapStatus) {
            
        case kMapPurchased:{
            
            [[GTMDownloadingFile sharedCoreManager] startDownloadingWithMap:_mapModel];
        }
            break;
            
        case kMapInDownload:
            [[GTMDownloadingFile sharedCoreManager] pushDownloadingWithMap:_mapModel];
            break;
        case kMapDownloadPushed:
            [[GTMDownloadingFile sharedCoreManager] resumeDownloadingWithMap:_mapModel];
            break;
        default:
            
            break;
    }
}

#pragma mark - Private Method
- (ProgessBlock)progressBlock {
    
    __weak typeof(self)weakSelf = self;
    return ^void(float progress, NSString *appleId){
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            // do something with the progress on the cell!
            
            if ([strongSelf.mapModel.appleID isEqualToString:appleId]) {
                
                [strongSelf->circularProgressView setProgress:progress];
                NSString *downloadStr = [NSString stringWithFormat:@"%0.2f%@",progress*100,@"%"];
                [strongSelf->mapSizeLabel setText:downloadStr];
            }
        });
    };
}

- (CompleteBlock)completionBlock {
    
    __weak typeof(self)weakSelf = self;
    return ^void(BOOL sucess,NSString *appleId, NSError *Error){
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (Error.code==-999) { // Task is Pushed
                
            }
            else if(sucess) {
                
                // do something
                
                if ([strongSelf.mapModel.appleID isEqualToString:appleId]) {
                    
                    [strongSelf->circularProgressView stopSpinProgressBackgroundLayer];
                    [strongSelf->mapSizeLabel setText:[[@(100) stringValue] stringByAppendingString:@"%"]];
                    [[CoreDataManager sharedCoreManager]updateDownlaodStatusMapinfo:appleId];
                }
            }
            [strongSelf updateCell];
        });
    };
}

-(void)prepareForReuse {
    
    self.progressBlock = nil;
    self.completionBlock = nil;

}

-(void)configureCellWithType:(CellType)cellType Object:(MapModel*)mapObject
{
    _cellType=cellType;
    _mapModel = mapObject;
    [mapObject setProgressBlock:[self progressBlock]];
    [mapObject setCompletionBlock:[self completionBlock]];
    [self->mapNameLabel setText:mapObject.name];
    NSString *mapinfo = [NSString stringWithFormat:@"%@,%@",mapObject.region,mapObject.state];
    [self->mapInfoLabel setText:mapinfo];
    [self->mapNumberLabel setText:[mapObject mapNumber]];
    [self->pubDateLabel setText:[mapObject pubDate]];

    if(_mapModel.mapStatus==kMapNotPurchased){
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productIdentifier=%@",[_mapModel appleID]];
        NSArray *filterArr = [[MKStoreKit sharedKit].availableProducts filteredArrayUsingPredicate:predicate];
        if (filterArr.count>0) {
            
            SKProduct * product = filterArr.lastObject;
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:product.priceLocale];
            NSString *formattedString = [numberFormatter stringFromNumber:product.price];
            [purchaseBut setTitle:formattedString forState:UIControlStateNormal];
        }
        else{
            [purchaseBut setTitle:@"DL" forState:UIControlStateNormal];
        }
    }
    else if(_mapModel.mapStatus==kMapInDownload||_mapModel.mapStatus==kMapDownloadPushed)
    {

    }
    [self updateCell];
}

@end
