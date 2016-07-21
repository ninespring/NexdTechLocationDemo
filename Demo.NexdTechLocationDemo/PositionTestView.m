//
//  UIViewController+PositionTestView.m
//  Demo.NexdTechLocationDemo
//
//  Created by Ninespring on 16/7/21.
//  Copyright © 2016年 Ninespring. All rights reserved.
//

#import "PositionTestView.h"

@implementation PositionTestView

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.resultOutput = [[UITextView alloc] init];
    self.resultOutput.text = @"MiaoPaSi";
    [self testCompiledLibrary];
    // Do any additional setup after loading the view, typically from a nib.
}



- (void)testCompiledLibrary{
    
    NSString *bid = @"101001200002";
    
    LocationEngine *locationEngine = [[LocationEngine alloc] initWithDefaultBuildingID:bid];
    
    
    double *input_test = (double *)malloc(locationEngine.getEngine.col * sizeof(double));
    int i = 0;
    for (i = 0; i<locationEngine.getEngine.col; i++) {
        input_test[i] = 0.0;
    }
    
    double *res = [locationEngine locatePositionWithInputArray:input_test];
    NSLog(@"Result = %f, %f", res[0], res[1]);
    
    NSString *result = [NSString stringWithFormat:@"Result = %f, %f", res[0], res[1]];
    self.resultOutput.text = result;
    [locationEngine freeParams];
}




- (void) testOverWifiList{
    NSURL *wifilistFileUrl = [[NSBundle mainBundle] URLForResource:@"101001200002" withExtension:@"wifilist"];
    NSString *wifilistLine = [NSString stringWithContentsOfURL:wifilistFileUrl encoding:NSUTF8StringEncoding error:nil];
    NSArray *wifilist = [wifilistLine componentsSeparatedByString:@","];
    for (int i = 0; i < wifilist.count; i++) {
        NSLog(wifilist[i]);
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
