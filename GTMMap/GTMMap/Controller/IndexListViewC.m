//
//  IndexListViewC.m
//  GTMMap
//
//  Created by mac on 18/06/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import "IndexListViewC.h"
#import "MapShareClass.h"
#import "MapTableViewCell.h"
#import "MapModel.h"

@interface IndexListViewC ()<UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate,MapCustomDeletagte>
{
    
}
@property (nonatomic, strong)IBOutlet UITableView *tblViewMap;
@property (nonatomic, strong)IBOutlet UISearchBar *searchBar;
@end

@implementation IndexListViewC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setUpView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark --- Public Method

#pragma mark --- Private Method
-(void)setUpView
{
    [[MapShareClass sharedMapShareClass] setDelegate:self];
    UINib *cellNib = [UINib nibWithNibName:@"MapTableViewCell" bundle:nil];
    [_tblViewMap registerNib:cellNib forCellReuseIdentifier:@"cellMapList"];
    [_tblViewMap setTableFooterView:[[UIView alloc]init]];
    [_tblViewMap reloadData];
}

#pragma mark - MapCustomDeletagte
-(void)reloadTableView
{
    //NSLog(@"%@",[[MapShareClass sharedMapShareClass] arrOfMapFullList]);
    //  NSLog(@"%@",[[MapShareClass sharedMapShareClass] arrOfMapList]);
    [_tblViewMap reloadData];
}
-(void)downloadingMapId:(NSString*)mapId status:(float)downloding
{
    
}
-(void)updateCellWithMapId:(NSString*)mapAppleId
{
    
}

#pragma mark --- UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 80;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // [tableView setEditing:(tableView.editing)?NO:YES];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark --- UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [[MapShareClass sharedMapShareClass] arrOfMapIndexList].count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MapTableViewCell *cell = (MapTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cellMapList"];
    NSArray *mapListArr = [[MapShareClass sharedMapShareClass] arrOfMapIndexList];
    MapModel *whichMap=[mapListArr objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell configureCellWithType:kTypeIndexCell Object:whichMap];
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
}
// Data manipulation - reorder / moving support

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark --- UISearchBarDelegate
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    
    [self.view endEditing:YES];
    return YES;
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    
    [self updateSearchData];
}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self updateSearchData];
    [self.view endEditing:YES];
}

-(void)updateSearchData
{
    //    MapModel
    if (_searchBar.text.length==0) {
        
        [MapShareClass sharedMapShareClass].arrOfMapList = [MapShareClass sharedMapShareClass].arrOfMapFullList;
        [_tblViewMap reloadData];
        return;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(name CONTAINS[cd] %@||state CONTAINS[cd] %@||region CONTAINS[cd] %@)&& mapStatus==%d",_searchBar.text,_searchBar.text,_searchBar.text,kMapAvailable];
    NSArray *filter = [[[MapShareClass sharedMapShareClass] arrOfMapFullList] filteredArrayUsingPredicate:predicate];
    [MapShareClass sharedMapShareClass].arrOfMapIndexList = filter;
    [_tblViewMap reloadData];
}

@end
