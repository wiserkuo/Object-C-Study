//
//  FSKPIRootViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/12/29.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSKPIRootViewController.h"
#import "FSKPIConditionViewController.h"
#import "FSKPIResultViewController.h"
#import "FSRadioButtonSet.h"

@interface FSKPIRootViewController () <FSRadioButtonSetDelegate>{
    FSRadioButtonSet *radioBtnSet;
    FSUIButton *conditionBtn;
    FSUIButton *resultBtn;
    FSUIButton *detailBtn;
    FSUIButton *changeBtn;
    
    UIView *mainframeView;
    FSKPIConditionViewController *conditionView;
    FSKPIResultViewController *resultView;
    NSMutableArray *layoutContraints;
}

@end

@implementation FSKPIRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    layoutContraints = [[NSMutableArray alloc] init];
    [self setUpImageBackButton];
    [self.navigationItem setTitle:NSLocalizedStringFromTable(@"KPI選股", @"", nil)];
    
    [self initView];
    
    [self.view setNeedsUpdateConstraints];
    radioBtnSet.selectedIndex = 0;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView{
    conditionBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    conditionBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [conditionBtn setTitle:@"條件" forState:UIControlStateNormal];
    [self.view addSubview:conditionBtn];
    
    resultBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    resultBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [resultBtn setTitle:@"結果" forState:UIControlStateNormal];
    [self.view addSubview:resultBtn];
    
    detailBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    detailBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [detailBtn setTitle:@"明細" forState:UIControlStateNormal];
    [self.view addSubview:detailBtn];
    
    changeBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    changeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [changeBtn setTitle:@"換股" forState:UIControlStateNormal];
    [self.view addSubview:changeBtn];
    
    radioBtnSet = [[FSRadioButtonSet alloc] initWithButtonArray:@[conditionBtn, resultBtn, detailBtn, changeBtn] andDelegate:self];
    
    mainframeView = [[UIView alloc] init];
    mainframeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainframeView];
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    [self.view removeConstraints:layoutContraints];
    [layoutContraints removeAllObjects];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(conditionBtn, resultBtn, detailBtn, changeBtn, mainframeView);
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[conditionBtn][resultBtn(conditionBtn)][detailBtn(resultBtn)][changeBtn(detailBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainframeView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[conditionBtn]-2-[mainframeView]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:layoutContraints];
    
}

- (void)insertViewControllerInMainFrameView:(UIViewController *)newController {
    // mainframe移除所有view和controller
    [[mainframeView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_mainViewController removeFromParentViewController];
    newController.view.frame = mainframeView.bounds;
    newController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // mainframe新增view和controller
    _mainViewController = newController;
    [newController willMoveToParentViewController:self];
    [self addChildViewController:newController];
    [newController didMoveToParentViewController:self];
    [mainframeView addSubview:newController.view];
}

-(void)radioButtonSet:(FSRadioButtonSet *)controller didSelectButtonAtIndex:(NSUInteger)selectedIndex{
    conditionBtn.selected = NO;
    resultBtn.selected = NO;
    detailBtn.selected = NO;
    changeBtn.selected = NO;
    if (selectedIndex == 0) {
        conditionBtn.selected = YES;
        conditionView = [[FSKPIConditionViewController alloc] init];
        [self insertViewControllerInMainFrameView:conditionView];
    }
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
