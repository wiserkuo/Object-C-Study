//
//  ValueAnalysisViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "ValueAnalysisViewController.h"


@interface ValueAnalysisViewController ()
{
    FSUIButton *summaryBtn;
    FSUIButton *volatilityBtn;
    FSUIButton *mainBtn;
    
    NSMutableArray *layoutConstraints;
    
    ValueSummaryViewController *valueSummaryViewController;
    VolatilityViewController *volatilityViewController;
    
    UIViewController *transferController;
    NSMutableDictionary *objDictionary;
    
    UIView *rootView;
    NSString *stringV;
    NSString *stringH;
}
@end

@implementation ValueAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self.view setNeedsUpdateConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    layoutConstraints = [[NSMutableArray alloc] init];
    
    summaryBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [summaryBtn setTitle:NSLocalizedStringFromTable(@"總表", @"Warrant", nil) forState:UIControlStateNormal];
    [summaryBtn addTarget:self action:@selector(buttonHandler:) forControlEvents:UIControlEventTouchUpInside];
    summaryBtn.translatesAutoresizingMaskIntoConstraints = NO;
    summaryBtn.selected = YES;
    [self.view addSubview:summaryBtn];
    
    volatilityBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [volatilityBtn addTarget:self action:@selector(buttonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [volatilityBtn setTitle:NSLocalizedStringFromTable(@"波動率分析", @"Warrant", nil) forState:UIControlStateNormal];
    volatilityBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:volatilityBtn];
    
    mainBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [mainBtn setTitle:NSLocalizedStringFromTable(@"主力", @"Warrant", nil) forState:UIControlStateNormal];
    mainBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainBtn];
    
    rootView = [[UIView alloc ]init];
    rootView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:rootView];
    
    objDictionary = [[NSMutableDictionary alloc]init];
    
    valueSummaryViewController = [[ValueSummaryViewController alloc] init];
    transferController = valueSummaryViewController;
    valueSummaryViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:valueSummaryViewController];
    [objDictionary setObject:valueSummaryViewController.view forKey:@"valueSummaryViewController"];
    [rootView addSubview:valueSummaryViewController.view];
    
    stringV = @"V:|[valueSummaryViewController]|";
    stringH = @"H:|[valueSummaryViewController]|";
    
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.view removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[summaryBtn][rootView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(summaryBtn, rootView)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[summaryBtn][volatilityBtn(150)][mainBtn(==summaryBtn)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(summaryBtn, volatilityBtn, mainBtn)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rootView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rootView)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:stringV options:0 metrics:nil views:objDictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:stringH options:0 metrics:nil views:objDictionary]];
    
    [self.view addConstraints:layoutConstraints];
}


-(void)buttonHandler:(FSUIButton *)target
{
    
    if([target isEqual:summaryBtn]){
        if(!summaryBtn.selected){
            [valueSummaryViewController willMoveToParentViewController:nil];
            [self transitionFromViewController:transferController toViewController:valueSummaryViewController duration:0.0f options:UIViewAnimationOptionCurveLinear    animations:^{} completion:^(BOOL finished){
                stringV = @"V:|[valueSummaryViewController]|";
                stringH = @"H:|[valueSummaryViewController]|";
                [self.view setNeedsUpdateConstraints];
                transferController = valueSummaryViewController;
            }];
        }
    }else if([target isEqual:volatilityBtn]){
        if(!volatilityBtn.selected){
            if(!volatilityViewController){
                volatilityViewController = [[VolatilityViewController alloc] initWithViewHeight:rootView.frame.size.height];
                volatilityViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
                [self addChildViewController:volatilityViewController];
                [objDictionary setObject:volatilityViewController.view forKey:@"volatilityViewController"];
                [rootView addSubview:volatilityViewController.view];
            }
            [volatilityViewController willMoveToParentViewController:nil];
            [self transitionFromViewController:transferController toViewController:volatilityViewController duration:0.0f options:    UIViewAnimationOptionCurveLinear    animations:^{} completion:^(BOOL finished){
                stringV = @"V:|[volatilityViewController]|";
                stringH = @"H:|[volatilityViewController]|";
                [self.view setNeedsUpdateConstraints];
                transferController = volatilityViewController;
            }];
        }
    }
    summaryBtn.selected = NO;
    volatilityBtn.selected = NO;
    mainBtn.selected = NO;
    target.selected = YES;
}

@end
