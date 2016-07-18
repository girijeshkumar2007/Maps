//
//  ChatViewController.m
//  GTMMap
//
//  Created by mac on 13/07/16.
//  Copyright © 2016 Girijesh. All rights reserved.
//

#import "ChatViewController.h"
#import <Charts/Charts-Swift.h>

@interface ChatViewController ()
{
    
}
@property (nonatomic, strong) IBOutlet LineChartView *chartView;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    // Do any additional setup after loading the view.
    NSArray *months= @[@"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun"];
    NSArray *unitsSold= @[@20.0, @4.0, @6.0, @3.0, @12.0, @16.0];

//    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun"]
//    let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0]
//    setChart(months, values: unitsSold)
    [self setchartWithDataPoint:months value:unitsSold];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setchartWithDataPoint:(NSArray*)dataPoint value:(NSArray*)values
{
    
}

//func setChart(dataPoints: [String], values: [Double]) {
//    
//    var dataEntries: [ChartDataEntry] = []
//    
//    for i in 0..<dataPoints.count {
//        let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
//        dataEntries.append(dataEntry)
//    }
//    
//    let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Units Sold")
//    let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
//    pieChartView.data = pieChartData
//    
//    var colors: [UIColor] = []
//    
//    for i in 0..<dataPoints.count {
//        let red = Double(arc4random_uniform(256))
//        let green = Double(arc4random_uniform(256))
//        let blue = Double(arc4random_uniform(256))
//        
//        let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
//        colors.append(color)
//    }
//    
//    pieChartDataSet.colors = colors
//    
//    
//    let lineChartDataSet = LineChartDataSet(yVals: dataEntries, label: "Units Sold")
//    let lineChartData = LineChartData(xVals: dataPoints, dataSet: lineChartDataSet)
//    lineChartView.data = lineChartData
//    
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
