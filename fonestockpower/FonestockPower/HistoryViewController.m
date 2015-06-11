//
//  HistoryViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/20.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "HistoryViewController.h"
#import "HistoryDrawTopView.h"
#import "HistoryDrawMidView.h"
#import "HistoryDrawBottomView.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "HistoryModel.h"

@interface HistoryViewController ()<UIScrollViewDelegate>
{
    UIScrollView *topScrollView;
    UIScrollView *midScrollView;
    UIScrollView *bottomScrollView;
    HistoryDrawTopView *drawTopView;
    HistoryDrawMidView *drawMidView;
    HistoryDrawBottomView *drawBottomView;
    UIView *topRightView;
    UIView *midRightView;
    UIView *bottomRightView;
    
    UILabel *topTitleLabel;
    UILabel *midTitleLabel;
    UILabel *bottomTitleLabel;
    
    FSDataModelProc *model;
    HistoryModel *historyModel;
    PortfolioItem *portfolioItem;
    PortfolioItem *comparedPortfolioItem;
    
    NSMutableArray *itemArray;
    NSMutableArray *comparedItemArray;
    NSMutableArray *newDataArray;
    
    NSMutableArray *layoutContains;
    
    UILabel *nameLabel;
    UILabel *comparedNameLabel;
}
@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initModel];
    [self initView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initModel
{
    itemArray = [[NSMutableArray alloc] init];
    comparedItemArray = [[NSMutableArray alloc] init];
    newDataArray = [[NSMutableArray alloc] init];
    
    model = [FSDataModelProc sharedInstance];
    historyModel = [[HistoryModel alloc] init];
    [historyModel setTarget:self];
    portfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].portfolioItem;
    comparedPortfolioItem = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio].comparedPortfolioItem;

    [historyModel getDLine:[NSString stringWithFormat:@"%c%c %@", portfolioItem->identCode[0], portfolioItem->identCode[1], portfolioItem->symbol]];
}

-(void)initView
{
    layoutContains = [[NSMutableArray alloc] init];
    
    topScrollView = [[UIScrollView alloc] init];
    topScrollView.delegate = self;
    topScrollView.layer.borderWidth = 0.5;
    topScrollView.bounces = NO;
    [topScrollView setShowsHorizontalScrollIndicator:NO];
    topScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topScrollView];
    
    midScrollView = [[UIScrollView alloc] init];
    midScrollView.delegate = self;
    midScrollView.layer.borderWidth = 0.5;
    midScrollView.bounces = NO;
    [midScrollView setShowsHorizontalScrollIndicator:NO];
    midScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:midScrollView];
    
    bottomScrollView = [[UIScrollView alloc]init];
    bottomScrollView.delegate = self;
    bottomScrollView.layer.borderWidth = 0.5;
    bottomScrollView.bounces = NO;
    [bottomScrollView setShowsHorizontalScrollIndicator:NO];
    bottomScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bottomScrollView];
    
    drawTopView = [[HistoryDrawTopView alloc] init];
    drawTopView.backgroundColor = [UIColor clearColor];
    [topScrollView addSubview:drawTopView];
    
    drawMidView = [[HistoryDrawMidView alloc] init];
    drawMidView.backgroundColor = [UIColor clearColor];
    [midScrollView addSubview:drawMidView];
    
    drawBottomView = [[HistoryDrawBottomView alloc] init];
    drawBottomView.backgroundColor = [UIColor clearColor];
    [bottomScrollView addSubview:drawBottomView];
    
    topRightView = [[UIView alloc] init];
    topRightView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topRightView];
    
    midRightView = [[UIView alloc] init];
    midRightView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:midRightView];
    
    bottomRightView = [[UIView alloc] init];
    bottomRightView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bottomRightView];
    
    UIFont *font = [UIFont boldSystemFontOfSize:14.0f];
    
    topTitleLabel = [[UILabel alloc] init];
    topTitleLabel.font = font;
    topTitleLabel.textColor = [UIColor whiteColor];
    topTitleLabel.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:124.0/255.0 blue:206.0/255.0 alpha:1];
    topTitleLabel.text = NSLocalizedStringFromTable(@"雙股", @"Warrant", nil);
    topTitleLabel.textAlignment = NSTextAlignmentCenter;
    topTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [topRightView addSubview:topTitleLabel];
    
    midTitleLabel = [[UILabel alloc] init];
    midTitleLabel.font = font;
    midTitleLabel.textColor = [UIColor whiteColor];
    midTitleLabel.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:124.0/255.0 blue:206.0/255.0 alpha:1];
    midTitleLabel.text = NSLocalizedStringFromTable(@"成交量", @"Warrant", nil);
    midTitleLabel.textAlignment = NSTextAlignmentCenter;
    midTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [midRightView addSubview:midTitleLabel];
    
    bottomTitleLabel = [[UILabel alloc] init];
    bottomTitleLabel.font = font;
    bottomTitleLabel.textColor = [UIColor whiteColor];
    bottomTitleLabel.backgroundColor = [UIColor colorWithRed:26.0/255.0 green:124.0/255.0 blue:206.0/255.0 alpha:1];
    bottomTitleLabel.text = NSLocalizedStringFromTable(@"成交量", @"Warrant", nil);
    bottomTitleLabel.textAlignment = NSTextAlignmentCenter;
    bottomTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomRightView addSubview:bottomTitleLabel];
    
    UIFont *nameFont = [UIFont systemFontOfSize:15.0f];
    nameLabel = [[UILabel alloc] init];
    nameLabel.font = nameFont;
    [midScrollView addSubview:nameLabel];
    
    comparedNameLabel = [[UILabel alloc] init];
    comparedNameLabel.font = nameFont;
    [bottomScrollView addSubview:comparedNameLabel];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    [self.view removeConstraints:layoutContains];
    [layoutContains removeAllObjects];
    
    NSDictionary *metrics = @{@"heightRange":@((self.view.frame.size.height-30)/5)};
    
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topScrollView][topRightView(70)]|" options:NSLayoutFormatAlignAllCenterY metrics:0 views:NSDictionaryOfVariableBindings(topScrollView, topRightView)]];
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[midScrollView][midRightView(70)]|" options:NSLayoutFormatAlignAllCenterY metrics:0 views:NSDictionaryOfVariableBindings(midScrollView, midRightView)]];
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomScrollView][bottomRightView(70)]|" options:NSLayoutFormatAlignAllCenterY metrics:0 views:NSDictionaryOfVariableBindings(bottomScrollView, bottomRightView)]];
    
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topScrollView][midScrollView(==heightRange)][bottomScrollView(==heightRange)]|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:NSDictionaryOfVariableBindings(topScrollView, midScrollView, bottomScrollView)]];
    
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topRightView][midRightView(==heightRange)][bottomRightView(==heightRange)]|" options:NSLayoutFormatAlignAllCenterX metrics:metrics views:NSDictionaryOfVariableBindings(topRightView, midRightView, bottomRightView)]];
    
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topTitleLabel(20)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(topTitleLabel)]];
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[midTitleLabel(20)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(midTitleLabel)]];
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[bottomTitleLabel(20)]" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bottomTitleLabel)]];
    
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topTitleLabel]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(topTitleLabel)]];
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[midTitleLabel]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(midTitleLabel)]];
    [layoutContains addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bottomTitleLabel]|" options:0 metrics:metrics views:NSDictionaryOfVariableBindings(bottomTitleLabel)]];
    [self.view addConstraints:layoutContains];
}

-(void)getItemArray:(NSMutableArray *)dataArray identCodeSymbol:(NSString *)ics
{
    if([ics isEqualToString:portfolioItem->symbol]){
        itemArray = dataArray;
        [historyModel getDLine:[NSString stringWithFormat:@"%c%c %@", comparedPortfolioItem->identCode[0], comparedPortfolioItem->identCode[1], comparedPortfolioItem->symbol]];
    }else if([ics isEqualToString:comparedPortfolioItem->symbol]){
        comparedItemArray = dataArray;

        for (int i = 0; i<[comparedItemArray count]; i++){
            HistoryDrawObject *comparedObj = [comparedItemArray objectAtIndex:i];
            for(int z = 0; z<[itemArray count]; z++){
                HistoryDrawObject *obj = [itemArray objectAtIndex:z];
                if(obj->date == comparedObj->date){
                    [newDataArray addObject:obj];
                    break;
                }
            }
        }
        drawTopView.itemArray = newDataArray;
        drawTopView.comparedItemArray = comparedItemArray;
        drawMidView.dataArray = newDataArray;
        drawBottomView.dataArray = comparedItemArray;
        
        if([newDataArray count] * 4 > topScrollView.frame.size.width){
            [topScrollView setContentSize:CGSizeMake([newDataArray count]*4, topScrollView.frame.size.height)];
            [drawTopView setFrame:CGRectMake(topScrollView.contentSize.width - ([newDataArray count]*4), 0, [newDataArray count]*4, topScrollView.frame.size.height)];
            topScrollView.contentOffset = CGPointMake(topScrollView.contentSize.width - topScrollView.frame.size.width, topScrollView.contentOffset.y);
            
            [midScrollView setContentSize:CGSizeMake([newDataArray count]*4, midScrollView.frame.size.height)];
            [drawMidView setFrame:CGRectMake(midScrollView.contentSize.width - ([newDataArray count]*4), 0, [newDataArray count]*4, midScrollView.frame.size.height)];
            midScrollView.contentOffset = CGPointMake(midScrollView.contentSize.width - midScrollView.frame.size.width, midScrollView.contentOffset.y);
            
            [bottomScrollView setContentSize:CGSizeMake([newDataArray count]*4, bottomScrollView.frame.size.height)];
            [drawBottomView setFrame:CGRectMake(bottomScrollView.contentSize.width - ([newDataArray count]*4), 0, [newDataArray count]*4, bottomScrollView.frame.size.height)];
            bottomScrollView.contentOffset = CGPointMake(bottomScrollView.contentSize.width - bottomScrollView.frame.size.width, bottomScrollView.contentOffset.y);
        }else{
            [topScrollView setContentSize:CGSizeMake(topScrollView.frame.size.width, topScrollView.frame.size.height)];
            [drawTopView setFrame:CGRectMake(0, 0, topScrollView.frame.size.width, topScrollView.frame.size.height)];
            
            [midScrollView setContentSize:CGSizeMake(midScrollView.frame.size.width, midScrollView.frame.size.height)];
            [drawMidView setFrame:CGRectMake(0, 0, midScrollView.frame.size.width, midScrollView.frame.size.height)];
            
            [bottomScrollView setContentSize:CGSizeMake(bottomScrollView.frame.size.width, bottomScrollView.frame.size.height)];
            [drawBottomView setFrame:CGRectMake(0, 0, bottomScrollView.frame.size.width, bottomScrollView.frame.size.height)];
        }
        
        drawTopView.contentOffSet = topScrollView.contentOffset.x;
        drawTopView.contentSize = topScrollView.contentSize.width;
        drawTopView.viewWidth = topScrollView.frame.size.width;
        [drawTopView setNeedsDisplay];
        [drawMidView setNeedsDisplay];
        [drawBottomView setNeedsDisplay];
    }
}

-(void)viewDidLayoutSubviews
{
    [self setNameLabel];
}

-(void)setNameLabel
{
    nameLabel.text = portfolioItem->fullName;
    comparedNameLabel.text = comparedPortfolioItem->fullName;
    
    [nameLabel setFrame:CGRectMake(midScrollView.contentOffset.x, 0, 80, 20)];
    [comparedNameLabel setFrame:CGRectMake(bottomScrollView.contentOffset.x, 0, 80, 20)];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    topScrollView.contentOffset = scrollView.contentOffset;
    midScrollView.contentOffset = scrollView.contentOffset;
    bottomScrollView.contentOffset = scrollView.contentOffset;
    [nameLabel setFrame:CGRectMake(midScrollView.contentOffset.x, 0, 80, 20)];
    [comparedNameLabel setFrame:CGRectMake(bottomScrollView.contentOffset.x, 0, 80, 20)];
    
    drawTopView.contentOffSet = topScrollView.contentOffset.x;
    [drawTopView setNeedsDisplay];
}
@end
