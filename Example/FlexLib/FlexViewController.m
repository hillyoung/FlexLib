/**
 * Copyright (c) 2017-present, zhenglibao, Inc.
 * email: 798393829@qq.com
 * All rights reserved.
 *
 * This source code is licensed under the MIT-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "FlexViewController.h"
#import "TestVC.h"
#import "TestTableVC.h"
#import "TestScrollVC.h"
#import "TestModalVC.h"

@interface FlexViewController ()

@end

@implementation FlexViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"FlexLib Demo";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onTest:(id)sender {
    
    TestVC* vc=[[TestVC alloc]init];
    
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)onTestTable:(id)sender {
    TestTableVC* vc=[[TestTableVC alloc]init];
    
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)onTestScrollView:(id)sender {
    TestScrollVC* vc=[[TestScrollVC alloc]init];
    
    [self presentViewController:vc animated:YES completion:nil];
}
- (IBAction)onTestModalView:(id)sender {
    TestModalVC* vc=[[TestModalVC alloc]init];
    
    [self presentViewController:vc animated:YES completion:nil];
}

@end