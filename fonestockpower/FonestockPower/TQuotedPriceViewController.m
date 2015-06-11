//
//  TRankingViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/7.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TQuotedPriceViewController.h"
#import "SKCustomTableViewCell.h"
#import "TQuotedTableViewCell.h"
#import "TQuotedPriceLeftCell.h"

@interface TQuotedPriceViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
{
    UITableView *leftTableView;
    UITableView *midTableView;
    UITableView *rightTableView;
    NSMutableArray *tQuotedCellArray;
    NSString *targetIdentCodeSymbol;
    NSString *targetName;
    FSDataModelProc *model;
    EquitySnapshotDecompressed *snapShot;
    NSMutableArray *dataArray;
    NSMutableArray *contentArray;
    CGPoint offset;
    
    UILabel *subjectWarrantTitle;
    FSUIButton *subjectWarrantBtn;
    UILabel *subjectPriceTitle;
    UILabel *subjectPriceContent;
    UILabel *hvTitle;
    UILabel *hvContent;
    UILabel *brokersTitle;
    FSUIButton *brokersBtn;
    UILabel *changeTitle;
    UILabel *changeContent;
    UILabel *changeRatioTitle;
    UILabel *changeRatioContent;
    
    UIView *topView;
    UILabel *topLeftLabel;
    UILabel *topRightLabel;
    
    NSMutableArray *brokersArray;
    UIActionSheet *brokersSheet;
    
    NSString *brokersFormula;
    
}
@end

@implementation TQuotedPriceViewController

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
    [self initArray];
    [self initModel];
    [self initView];
	[self initTableView];
    [self updateViewConstraints];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    subjectWarrantTitle = [[UILabel alloc] init];
    subjectWarrantTitle.text = NSLocalizedStringFromTable(@"權證標的", @"Warrant", nil);
    subjectWarrantTitle.textColor = [UIColor blueColor];
    subjectWarrantTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subjectWarrantTitle];
    
    subjectWarrantBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [subjectWarrantBtn setTitle:targetName forState:UIControlStateNormal];
    subjectWarrantBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subjectWarrantBtn];
    
    subjectPriceTitle = [[UILabel alloc] init];
    subjectPriceTitle.text = NSLocalizedStringFromTable(@"標的現價", @"Warrant" , nil);
    subjectPriceTitle.textColor = [UIColor blueColor];
    subjectPriceTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subjectPriceTitle];
    
    subjectPriceContent = [[UILabel alloc] init];
    subjectPriceContent.textAlignment = NSTextAlignmentCenter;
    subjectPriceContent.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:subjectPriceContent];
    
    hvTitle = [[UILabel alloc] init];
    hvTitle.text = NSLocalizedStringFromTable(@"歷史波動", @"Warrant", nil);
    hvTitle.textColor = [UIColor blueColor];
    hvTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hvTitle];
    
    hvContent = [[UILabel alloc] init];
    hvContent.textAlignment = NSTextAlignmentCenter;
    hvContent.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:hvContent];
    
    brokersTitle = [[UILabel alloc] init];
    brokersTitle.text = NSLocalizedStringFromTable(@"券商", @"Warrant", nil);
    brokersTitle.textColor = [UIColor blueColor];
    brokersTitle.textAlignment = NSTextAlignmentCenter;
    brokersTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:brokersTitle];
    
    brokersBtn = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    [brokersBtn addTarget:self action:@selector(brokersHandler) forControlEvents:UIControlEventTouchUpInside];
    [brokersBtn setTitle:NSLocalizedStringFromTable(@"全部", @"Warrant", nil) forState:UIControlStateNormal];
    brokersBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:brokersBtn];
    
    changeTitle = [[UILabel alloc] init];
    changeTitle.text = NSLocalizedStringFromTable(@"漲跌", @"Warrant", nil);
    changeTitle.textColor = [UIColor blueColor];
    changeTitle.textAlignment = NSTextAlignmentCenter;
    changeTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:changeTitle];
    
    changeContent = [[UILabel alloc] init];
    changeContent.textAlignment = NSTextAlignmentCenter;
    changeContent.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:changeContent];
    
    changeRatioTitle = [[UILabel alloc] init];
    changeRatioTitle.text = NSLocalizedStringFromTable(@"漲幅", @"Warrant", nil);
    changeRatioTitle.textColor = [UIColor blueColor];
    changeRatioTitle.textAlignment = NSTextAlignmentCenter;
    changeRatioTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:changeRatioTitle];
    
    changeRatioContent = [[UILabel alloc] init];
    changeRatioContent.textAlignment = NSTextAlignmentCenter;
    changeRatioContent.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:changeRatioContent];
    
    topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor colorWithRed:12.0/255.0 green:95.0/255.0 blue:255.0/255.0 alpha:1];
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topView];
    
    topRightLabel = [[UILabel alloc] init];
    topRightLabel.text = NSLocalizedStringFromTable(@"認售", @"Warrant", nil);
    topRightLabel.textColor = [UIColor whiteColor];
    topRightLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    topRightLabel.textAlignment = NSTextAlignmentCenter;
    topRightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:topRightLabel];
    
    topLeftLabel = [[UILabel alloc] init];
    topLeftLabel.text = NSLocalizedStringFromTable(@"認購", @"Warrant", nil);
    topLeftLabel.textColor = [UIColor whiteColor];
    topLeftLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    topLeftLabel.textAlignment = NSTextAlignmentCenter;
    topLeftLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:topLeftLabel];
}

-(void)brokersHandler
{
    brokersSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"選擇券商", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    brokersSheet.delegate = self;
    brokersArray = [model.warrant getTQuotedBrokers];
    for(int i = 0; i<[brokersArray count]; i++){
        [brokersSheet addButtonWithTitle:[brokersArray objectAtIndex:i]];
    }
    [brokersSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
    brokersSheet.cancelButtonIndex = [brokersArray count];
    [self showActionSheet:brokersSheet];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex !=[brokersArray count]){
        [brokersBtn setTitle:[brokersArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
        if(buttonIndex == 0){
            brokersFormula = @"";
        }else{
            brokersFormula = [NSString stringWithFormat:@"Where Brokers ='%@'", [brokersArray objectAtIndex:buttonIndex]];
        }
    }
    dataArray = [model.warrant getTQuotedData:brokersFormula];
    [rightTableView reloadData];
    [midTableView reloadData];
    [leftTableView reloadData];
}

-(void)initArray
{
    contentArray = [[NSMutableArray alloc] init];
    tQuotedCellArray = [[NSMutableArray alloc] initWithObjects:NSLocalizedStringFromTable(@"買價", @"Warrant", nil), NSLocalizedStringFromTable(@"賣價", @"Warrant", nil), NSLocalizedStringFromTable(@"成交", @"Warrant", nil), NSLocalizedStringFromTable(@"漲跌", @"Warrant", nil), NSLocalizedStringFromTable(@"IV", @"Warrant", nil), NSLocalizedStringFromTable(@"天數", @"Warrant", nil), NSLocalizedStringFromTable(@"距損平點", @"Warrant", nil), nil];

}

-(void)initModel
{
    targetIdentCodeSymbol = @"TW 2206";
    targetName = @"三陽";
    model = [FSDataModelProc sharedInstance];
    [model.portfolioData setTarget:self];
    
    NewSymbolObject * symbolObj = [[NewSymbolObject alloc] init];
    symbolObj.identCode = [targetIdentCodeSymbol substringToIndex:2];
    symbolObj.symbol = [targetIdentCodeSymbol substringFromIndex:3];
    symbolObj.fullName = targetName;
    [model.portfolioData addWatchListItemNewSymbolObjArray:@[symbolObj]];
}

-(void)sendHandler
{
    snapShot = [model.portfolioTickBank getSnapshotFromIdentCodeSymbol:targetIdentCodeSymbol];
    [model.warrant setTarget:self];
    [model.warrant.warrantArray removeAllObjects];
    [model.warrant sendIdentSymbol:targetIdentCodeSymbol function:4 fullName:targetName targetPrice:snapShot.ceilingPrice];
}

-(void)initTableView
{
    
    leftTableView = [[UITableView alloc] init];
    leftTableView.delegate = self;
    leftTableView.dataSource = self;
    leftTableView.bounces = NO;
    [leftTableView setShowsVerticalScrollIndicator:NO];
    leftTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:leftTableView];
    
    midTableView = [[UITableView alloc] init];
    midTableView.bounces = NO;
    midTableView.dataSource = self;
    midTableView.delegate = self;
    [midTableView setShowsVerticalScrollIndicator:NO];
    midTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:midTableView];
    
    rightTableView = [[UITableView alloc] init];
    rightTableView.delegate = self;
    rightTableView.dataSource = self;
    rightTableView.bounces = NO;
    [rightTableView setShowsVerticalScrollIndicator:NO];
    rightTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:rightTableView];
}


-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(subjectWarrantTitle, subjectWarrantBtn, subjectPriceTitle, subjectPriceContent, hvTitle, hvContent, brokersTitle, brokersBtn, changeTitle, changeContent, changeRatioTitle, changeRatioContent ,leftTableView, midTableView, rightTableView, topView, topLeftLabel, topRightLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subjectWarrantTitle][subjectWarrantBtn(==subjectWarrantTitle)][brokersTitle(==subjectWarrantTitle)][brokersBtn(==subjectWarrantTitle)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subjectPriceTitle][subjectPriceContent(==subjectPriceTitle)][changeTitle(==subjectPriceTitle)][changeContent(==subjectPriceTitle)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[hvTitle][hvContent(==hvTitle)][changeRatioTitle(==hvTitle)][changeRatioContent(==hvTitle)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topView]|" options:0 metrics:nil views:viewDictionary]];
    
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topLeftLabel][topRightLabel(==topLeftLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topLeftLabel]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subjectWarrantTitle(35)][subjectPriceTitle(==subjectWarrantTitle)][hvTitle(==subjectWarrantTitle)][topView(==subjectWarrantTitle)][leftTableView]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subjectWarrantTitle(35)][subjectPriceTitle(==subjectWarrantTitle)][hvTitle(==subjectWarrantTitle)][topView(==subjectWarrantTitle)][rightTableView]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subjectWarrantTitle(35)][subjectPriceTitle(==subjectWarrantTitle)][hvTitle(==subjectWarrantTitle)][topView(==subjectWarrantTitle)][midTableView]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftTableView][midTableView(100)][rightTableView(==leftTableView)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[subjectWarrantBtn(35)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[brokersBtn(35)]" options:0 metrics:nil views:viewDictionary]];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(dataArray == nil){
        static NSString *DefaultCell = @"DefaultCell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:DefaultCell];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DefaultCell];
        }
        return cell;
    }

    
    
    WarrantObject *obj = [dataArray objectAtIndex:indexPath.row];
    
    if([tableView isEqual:midTableView]){
        static NSString *MidCell = @"MidCell";
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:MidCell];
        if(cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MidCell];
        }
    
    
        cell.textLabel.text = [NSString stringWithFormat:@"%.2f", obj->exercisePrice];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor blueColor];
        return cell;
    }else if([tableView isEqual:leftTableView]){
        if([obj->type isEqualToString:@"認售"]){
            static NSString *LeftCell = @"LeftCell";
            TQuotedPriceLeftCell *cell = (TQuotedPriceLeftCell *)[tableView dequeueReusableCellWithIdentifier:LeftCell];
            if(cell == nil){
                cell = [[TQuotedPriceLeftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LeftCell CellWidth:rightTableView.frame.size.width Type:1] ;
                
            }
            cell.nameLabel.text = obj->warrantSymbol;
            return cell;
        }else{
            TQuotedTableViewCell *cell = nil;
            static NSString *LeftContentCell = @"LeftContentCell";
            cell = (TQuotedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:LeftContentCell];
            if(cell == nil){
                cell = [[TQuotedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LeftContentCell AndLabelArray:[contentArray objectAtIndex:indexPath.row]];
                
            }
            cell.scrollView.tag = indexPath.row+1;
            cell.scrollView.contentOffset = offset;;
            cell.scrollView.delegate = self;
            return cell;
        }
    }else{
        if([obj->type isEqualToString:@"認購"]){
            static NSString *RightCell = @"RightCell";
            TQuotedPriceLeftCell *cell = (TQuotedPriceLeftCell *)[tableView dequeueReusableCellWithIdentifier:RightCell];
            if(cell == nil){
                cell = [[TQuotedPriceLeftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RightCell CellWidth:rightTableView.frame.size.width Type:2] ;
                
            }
            cell.nameLabel.text = obj->warrantSymbol;
            return cell;
        }else{
            TQuotedTableViewCell *cell = nil;
            static NSString *RightContentCell = @"RightContentCell";
            cell = (TQuotedTableViewCell *)[tableView dequeueReusableCellWithIdentifier:RightContentCell];
            if(cell == nil){
                cell = [[TQuotedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RightContentCell AndLabelArray:[contentArray objectAtIndex:indexPath.row]] ;
                
            }
            cell.scrollView.tag = indexPath.row+1;
            cell.scrollView.contentOffset = offset;
            cell.scrollView.delegate = self;
            return cell;
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([rightTableView isEqual:scrollView] || [midTableView isEqual:scrollView] || [leftTableView isEqual:scrollView]){
        CGPoint TableViewoffset = scrollView.contentOffset;
        rightTableView.contentOffset = TableViewoffset;
        midTableView.contentOffset = TableViewoffset;
        leftTableView.contentOffset = TableViewoffset;
    }else{
        offset = scrollView.contentOffset;
        if([dataArray count] !=0){
            NSIndexPath *startInt = [[midTableView indexPathsForVisibleRows] objectAtIndex:0];
            NSIndexPath *endInt = [[midTableView indexPathsForVisibleRows] lastObject];
            for(NSUInteger i = startInt.row+1; i<=endInt.row+1; i++){
                UIScrollView *cellScrollView = (UIScrollView *)[self.view viewWithTag:i];
                cellScrollView.contentOffset = offset;
            }
            UIScrollView *headerLScrollView = (UIScrollView *)[self.view viewWithTag:9999];
            headerLScrollView.contentOffset = offset;
            UIScrollView *headerRScrollView = (UIScrollView *)[self.view viewWithTag:9998];
            headerRScrollView.contentOffset = offset;
        }
    }
}


-(void)notifyData
{
    dataArray = [model.warrant getTQuotedData:@""];
    for(int i = 0; i<[dataArray count]; i++){
        WarrantObject *obj = [dataArray objectAtIndex:i];
        NSMutableArray *data = [[NSMutableArray alloc] initWithObjects:[NSString stringWithFormat:@"%.2f", obj->buyPrice], [NSString stringWithFormat:@"%.2f", obj->sellPrice], [NSString stringWithFormat:@"%.2f", obj->price], @"----", [NSString stringWithFormat:@"%.2f", obj->IV], [NSString stringWithFormat:@"%d天", obj->date], [NSString stringWithFormat:@"%.2f", obj->flatSpot], nil];
        [contentArray addObject:data];
    }
    [rightTableView reloadData];
    [midTableView reloadData];
    [leftTableView reloadData];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([tableView isEqual:midTableView]){
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:12.0/255.0 green:95.0/255.0 blue:255.0/255.0 alpha:1];
        
        UILabel *title = [[UILabel alloc] init];
        title.text = NSLocalizedStringFromTable(@"履約價", @"Warrant", nil);
        title.textColor = [UIColor whiteColor];
        title.textAlignment = NSTextAlignmentCenter;
        title.font = [UIFont boldSystemFontOfSize:20.0f];
        title.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:title];
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(title);
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]|" options:0 metrics:nil views:viewDictionary]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title]|" options:0 metrics:nil views:viewDictionary]];
        
        return view;
    }else if([tableView isEqual:leftTableView]){
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:12.0/255.0 green:95.0/255.0 blue:255.0/255.0 alpha:1];
        
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.delegate = self;
        [scrollView setShowsHorizontalScrollIndicator:NO];
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:scrollView];
        
        for (int i = 0; i< [tQuotedCellArray count]; i++){
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*80, 0, 80, 35)];
            label.text = [tQuotedCellArray objectAtIndex:i];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:20.0f];
            label.textAlignment = NSTextAlignmentCenter;
            [scrollView addSubview:label];
        }
        scrollView.tag = 9999;
        [scrollView setContentSize:CGSizeMake([tQuotedCellArray count]*80, 0)];
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(scrollView);
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:viewDictionary]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:viewDictionary]];
        
        return view;
    }else{
        UIView *view = [[UIView alloc] init];
        view.backgroundColor = [UIColor colorWithRed:12.0/255.0 green:95.0/255.0 blue:255.0/255.0 alpha:1];
        
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.delegate = self;
        [scrollView setShowsHorizontalScrollIndicator:NO];
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        [view addSubview:scrollView];
        
        for (int i = 0; i< [tQuotedCellArray count]; i++){
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(i*80, 0, 80, 35)];
            label.text = [tQuotedCellArray objectAtIndex:i];
            label.textColor = [UIColor whiteColor];
            label.font = [UIFont boldSystemFontOfSize:20.0f];
            label.textAlignment = NSTextAlignmentCenter;
            [scrollView addSubview:label];
        }
        scrollView.tag = 9998;
        [scrollView setContentSize:CGSizeMake([tQuotedCellArray count]*80, 0)];
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(scrollView);
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|" options:0 metrics:nil views:viewDictionary]];
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollView]|" options:0 metrics:nil views:viewDictionary]];
        
        return view;
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35.0f;
}

@end
