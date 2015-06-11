//
//  WarrantMainViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/15.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantMainViewController.h"
#import "WarrantBasicViewController.h"
#import "WarrantChartViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "ValueAnalysisViewController.h"
#import "HistoryViewController.h"
@interface WarrantMainViewController ()
{
    FSUIButton *symbolButton;
    FSUIButton *instantButton;
    FSUIButton *historyButton;
    FSUIButton *basicButton;
    FSUIButton *valueButton;
    FSUIButton *sheetButton;
    UILabel *topLabel;
    UILabel *bottomLabel;
    NSMutableDictionary *objDictionary;
    
    UIView *rootView;
    NSString *stringV;
    NSString *stringH;
    UIViewController *transferController;
    WarrantChartViewController *warrantChartViewController;
    WarrantBasicViewController *warrantBasicViewController;
    ValueAnalysisViewController *valueAnalysisViewController;
    HistoryViewController *historyViewController;
    NSMutableArray *layoutConstraints;
    FSDataModelProc *model;
    PortfolioItem *portfolioItem;
}

@end

@implementation WarrantMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initModel];
	[self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initModel
{
    model = [FSDataModelProc sharedInstance];
    portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem;
}

-(void)initView
{
    layoutConstraints = [[NSMutableArray alloc] init];
    
    symbolButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    symbolButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:symbolButton];
    
    topLabel = [[UILabel alloc] init];
    topLabel.textColor = [UIColor whiteColor];
    topLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    topLabel.text = portfolioItem->fullName;
    topLabel.textAlignment = NSTextAlignmentCenter;
    topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [symbolButton addSubview:topLabel];
    
    bottomLabel = [[UILabel alloc] init];
    bottomLabel.textColor = [UIColor whiteColor];
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.font = [UIFont systemFontOfSize:15.0f];
    bottomLabel.text = portfolioItem->symbol;
    bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [symbolButton addSubview:bottomLabel];
    
    instantButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    instantButton.selected = YES;
    instantButton.titleLabel.numberOfLines = 0;
    instantButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [instantButton addTarget:self action:@selector(buttonHandler:) forControlEvents:UIControlEventTouchUpInside];
    instantButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [instantButton setTitle:NSLocalizedStringFromTable(@"即時\n對照", @"Warrant", nil) forState:UIControlStateNormal];
    instantButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:instantButton];
    
    historyButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    historyButton.titleLabel.numberOfLines = 0;
    historyButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [historyButton addTarget:self action:@selector(buttonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [historyButton setTitle:NSLocalizedStringFromTable(@"歷史\n對照", @"Warrant", nil) forState:UIControlStateNormal];
    historyButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:historyButton];
    
    basicButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    basicButton.titleLabel.numberOfLines = 0;
    basicButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [basicButton setTitle:NSLocalizedStringFromTable(@"基本\n資料", @"Warrant", nil) forState:UIControlStateNormal];
    [basicButton addTarget:self action:@selector(buttonHandler:) forControlEvents:UIControlEventTouchUpInside];
    basicButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:basicButton];
    
    valueButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    valueButton.titleLabel.numberOfLines = 0;
    valueButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [valueButton setTitle:NSLocalizedStringFromTable(@"價值\n分析", @"Warrant", nil) forState:UIControlStateNormal];
    [valueButton addTarget:self action:@selector(buttonHandler:) forControlEvents:UIControlEventTouchUpInside];
    valueButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:valueButton];
    
    sheetButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    sheetButton.titleLabel.numberOfLines = 0;
    sheetButton.titleEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [sheetButton setTitle:NSLocalizedStringFromTable(@"情境\n試算", @"Warrant", nil) forState:UIControlStateNormal];
    sheetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:sheetButton];
    
    rootView = [[UIView alloc ]init];
    rootView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:rootView];
    
    objDictionary = [[NSMutableDictionary alloc]init];

    warrantChartViewController = [[WarrantChartViewController alloc] init];
    transferController = warrantChartViewController;
    warrantChartViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:warrantChartViewController];
    [objDictionary setObject:warrantChartViewController.view forKey:@"warrantChartViewController"];
    [rootView addSubview:warrantChartViewController.view];
    
    stringV = @"V:|[warrantChartViewController]|";
    stringH = @"H:|[warrantChartViewController]|";
    
    [self.view setNeedsUpdateConstraints];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    [self.view removeConstraints:layoutConstraints];
    
    [layoutConstraints removeAllObjects];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[symbolButton(44)][rootView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(symbolButton, rootView)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[symbolButton(80)][instantButton][historyButton(==instantButton)][basicButton(==instantButton)][valueButton(==instantButton)][sheetButton(==instantButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(symbolButton, instantButton, historyButton, basicButton, valueButton, sheetButton)]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[rootView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rootView)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:stringV options:0 metrics:nil views:objDictionary]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:stringH options:0 metrics:nil views:objDictionary]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:topLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:symbolButton attribute:NSLayoutAttributeTop multiplier:0 constant:3]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:topLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:symbolButton attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:topLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:symbolButton attribute:NSLayoutAttributeWidth multiplier:1 constant:-16]];
    
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:bottomLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:symbolButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-3]];
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:bottomLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:symbolButton attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraints:layoutConstraints];
}

//-(void)setRootViewAutoLayout
//{
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:stringV options:0 metrics:nil views:objDictionary]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:stringH options:0 metrics:nil views:objDictionary]];
//}

-(void)buttonHandler:(FSUIButton *)target
{
    if([target isEqual:instantButton]){
        if(!instantButton.selected){
            [warrantChartViewController willMoveToParentViewController:nil];
            [self transitionFromViewController:transferController toViewController:warrantChartViewController duration:0.0f options:UIViewAnimationOptionCurveLinear    animations:^{} completion:^(BOOL finished){
                stringV = @"V:|[warrantChartViewController]|";
                stringH = @"H:|[warrantChartViewController]|";
                [self.view setNeedsUpdateConstraints];
                transferController = warrantChartViewController;
            }];
        }
    }else if([target isEqual:basicButton]){
        if(!basicButton.selected){
            if(!warrantBasicViewController){
                warrantBasicViewController = [[WarrantBasicViewController alloc] init];
                warrantBasicViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
                [self addChildViewController:warrantBasicViewController];
                [objDictionary setObject:warrantBasicViewController.view forKey:@"warrantBasicViewController"];
                [rootView addSubview:warrantBasicViewController.view];
            }
            [warrantBasicViewController willMoveToParentViewController:nil];
            [self transitionFromViewController:transferController toViewController:warrantBasicViewController duration:0.0f options:    UIViewAnimationOptionCurveLinear    animations:^{} completion:^(BOOL finished){
                stringV = @"V:|[warrantBasicViewController]|";
                stringH = @"H:|[warrantBasicViewController]|";
                [self.view setNeedsUpdateConstraints];
                transferController = warrantBasicViewController;
            }];
        }
    }else if([target isEqual:valueButton]){
        if(!valueButton.selected){
            if(!valueAnalysisViewController){
                valueAnalysisViewController = [[ValueAnalysisViewController alloc] init];
                valueAnalysisViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
                [self addChildViewController:valueAnalysisViewController];
                [objDictionary setObject:valueAnalysisViewController.view forKey:@"valueAnalysisViewController"];
                [rootView addSubview:valueAnalysisViewController.view];
            }
            [valueAnalysisViewController willMoveToParentViewController:nil];
            [self transitionFromViewController:transferController toViewController:valueAnalysisViewController duration:0.0f options:    UIViewAnimationOptionCurveLinear    animations:^{} completion:^(BOOL finished){
                stringV = @"V:|[valueAnalysisViewController]|";
                stringH = @"H:|[valueAnalysisViewController]|";
                [self.view setNeedsUpdateConstraints];
                transferController = valueAnalysisViewController;
            }];
        }
    }else if([target isEqual:historyButton]){
        if(!historyButton.selected){
            if(!historyViewController){
                historyViewController = [[HistoryViewController alloc] init];
                historyViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
                [self addChildViewController:historyViewController];
                [objDictionary setObject:historyViewController.view forKey:@"historyViewController"];
                [rootView addSubview:historyViewController.view];
            }
            [historyViewController willMoveToParentViewController:nil];
            [self transitionFromViewController:transferController toViewController:historyViewController duration:0.0f options:    UIViewAnimationOptionCurveLinear    animations:^{} completion:^(BOOL finished){
                stringV = @"V:|[historyViewController]|";
                stringH = @"H:|[historyViewController]|";
                [self.view setNeedsUpdateConstraints];
                transferController = historyViewController;
            }];
        }
    }
    historyButton.selected = NO;
    instantButton.selected = NO;
    basicButton.selected = NO;
    sheetButton.selected = NO;
    valueButton.selected = NO;
    target.selected = YES;
}
@end
