//
//  EODTrackPatternsViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/11/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "TrackPatternsViewController.h"
#import "TrackPatternsTableViewCell.h"
#import "EODTargetModel.h"
#import "FigureSearchMyProfileModel.h"
#import "FigureTrackListViewController.h"
#import "UIViewController+CustomNavigationBar.h"
@interface TrackPatternsViewController ()<UITableViewDataSource, UITableViewDelegate, TrackTableViewCellDelegate>
{
    UITableView *mainTableView;
    EODTargetModel *model;
    FSUIButton *moreOptionButton;
    FSUIButton *zeroOptionButton;
    NSMutableArray *moreArray;
    NSMutableArray *zeroArray;
    SystemObject * obj;
    FigureSearchMyProfileModel * customModel;
}
@end

@implementation TrackPatternsViewController

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
    self.title =NSLocalizedStringFromTable(@"型態追蹤", @"FigureSearch", nil);
    [self setUpImageBackButton];
    [self initModel];
	[self initView];
    [self initMoreOption];
    [self initZeroOption];
    [self updateViewConstraints];
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initModel
{
    model = [[EODTargetModel alloc] init];
    customModel = [[FigureSearchMyProfileModel alloc]init];
    moreArray = [model getLongSystem];
    zeroArray = [model getShortSystem];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [mainTableView reloadData];
}

-(void)initView
{
    mainTableView = [[UITableView alloc] init];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
}

-(void)initMoreOption
{
    NSString *moreOptionTitle = NSLocalizedStringFromTable(@"多方選股", @"FigureSearch", nil);
    
    moreOptionButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    moreOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [moreOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    moreOptionButton.selected = YES;
    [moreOptionButton setTitle:moreOptionTitle forState:UIControlStateNormal];
    [moreOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:moreOptionButton];
}

-(void)initZeroOption
{
    NSString *zeroOptionTitle = NSLocalizedStringFromTable(@"空方選股", @"FigureSearch", nil);
    
    zeroOptionButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    zeroOptionButton.translatesAutoresizingMaskIntoConstraints = NO;
    [zeroOptionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [zeroOptionButton setTitle:zeroOptionTitle forState:UIControlStateNormal];
    [zeroOptionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zeroOptionButton];
}

-(void)optionButtonClick:(FSUIButton *)sender
{
    moreOptionButton.selected = NO;
    zeroOptionButton.selected = NO;
    sender.selected = YES;
    [mainTableView reloadData];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"EDOTrackCell";
    TrackPatternsTableViewCell *cell = (TrackPatternsTableViewCell *)[mainTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[TrackPatternsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.layer.borderWidth = 0.5f;
    if(moreOptionButton.selected){
        obj = [moreArray objectAtIndex:indexPath.row];
    }else{
        obj = [zeroArray objectAtIndex:indexPath.row];
    }
    cell.leftImage.image = [UIImage imageWithData:obj.imageData];
    cell.imageName.text = NSLocalizedStringFromTable(obj.imageNmae, @"FigureSearch", nil);
    cell.delegate = self;
    cell.tag = indexPath.row;
    
    cell.dayContentLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d檔追蹤標的", @"FigureSearch", nil), (int)[[customModel searchAllTrackWithFigureSearchId:[NSNumber numberWithInt:obj.imageID] RangeType:NSLocalizedStringFromTable(@"Day", @"FigureSearch", nil)]count]];
    cell.weekContentLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d檔追蹤標的", @"FigureSearch", nil), (int)[[customModel searchAllTrackWithFigureSearchId:[NSNumber numberWithInt:obj.imageID] RangeType:NSLocalizedStringFromTable(@"Week", @"FigureSearch", nil)]count]];
    cell.monthContentLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%d檔追蹤標的", @"FigureSearch", nil), (int)[[customModel searchAllTrackWithFigureSearchId:[NSNumber numberWithInt:obj.imageID] RangeType:NSLocalizedStringFromTable(@"Month", @"FigureSearch", nil)]count]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    
    
    if([[customModel searchAllTrackWithFigureSearchId:[NSNumber numberWithInt:obj.imageID] RangeType:NSLocalizedStringFromTable(@"Day", @"FigureSearch", nil)]count] != 0){
        cell.dayLabel.textColor = [UIColor blueColor];
        cell.dayContentLabel.textColor = [UIColor blueColor];
    }else{
        cell.dayLabel.textColor = [UIColor blackColor];
        cell.dayContentLabel.textColor = [UIColor blackColor];
    }
    if([[customModel searchAllTrackWithFigureSearchId:[NSNumber numberWithInt:obj.imageID] RangeType:NSLocalizedStringFromTable(@"Week", @"FigureSearch", nil)]count] != 0){
        cell.weekLabel.textColor = [UIColor blueColor];
        cell.weekContentLabel.textColor = [UIColor blueColor];
    }else{
        cell.weekLabel.textColor = [UIColor blackColor];
        cell.weekContentLabel.textColor = [UIColor blackColor];
    }
    if([[customModel searchAllTrackWithFigureSearchId:[NSNumber numberWithInt:obj.imageID] RangeType:NSLocalizedStringFromTable(@"Month", @"FigureSearch", nil)]count] != 0){
        cell.monthLabel.textColor = [UIColor blueColor];
        cell.monthContentLabel.textColor = [UIColor blueColor];
    }else{
        cell.monthLabel.textColor = [UIColor blackColor];
        cell.monthContentLabel.textColor = [UIColor blackColor];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(mainTableView, moreOptionButton, zeroOptionButton);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[moreOptionButton]-3-[mainTableView]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[moreOptionButton]-3-[zeroOptionButton(==moreOptionButton)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewDictionary]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0f;
}

-(void)trackBeClick:(UITableViewCell *)cell Btn:(FSUIButton *)sender Row:(NSInteger)row
{
    TrackPatternsTableViewCell *trackCell = (TrackPatternsTableViewCell *)cell;
    if(moreOptionButton.selected){
        obj = [moreArray objectAtIndex:row];
    }else{
        obj = [zeroArray objectAtIndex:row];
    }
    
    NSString *range;
    if([sender isEqual:trackCell.topBtn]){
        range = NSLocalizedStringFromTable(@"Day", @"FigureSearch", nil);
    }else if([sender isEqual:trackCell.centerBtn]){
        range = NSLocalizedStringFromTable(@"Week", @"FigureSearch", nil);
    }else{
        range = NSLocalizedStringFromTable(@"Month", @"FigureSearch", nil);
    }
    
    NSMutableArray *trackArray = [customModel searchAllTrackWithFigureSearchId:[NSNumber numberWithInt:obj.imageID] RangeType:range];
    if (![trackArray count]==0) {
        FigureTrackListViewController * trackList = [[FigureTrackListViewController alloc]initWithTrackUpArray:trackArray FigureSearchName:obj.imageNmae FigureSearchId:[NSNumber numberWithInt:obj.imageID]  Range:range];
        [self.navigationController pushViewController:trackList animated:NO];
    }
}
@end
