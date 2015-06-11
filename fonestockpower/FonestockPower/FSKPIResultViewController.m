//
//  FSKPIResultViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/12/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSKPIResultViewController.h"

@interface FSKPIResultViewController (){
    NSMutableArray *layoutContraints;
}

@end

@implementation FSKPIResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    layoutContraints = [[NSMutableArray alloc] init];
    [self initView];
    [self.view setNeedsUpdateConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView{

}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    [self.view removeConstraints:layoutContraints];
    [layoutContraints removeAllObjects];
//    NSDictionary *viewControllers = NSDictionaryOfVariableBindings();

    [self.view addConstraints:layoutContraints];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
