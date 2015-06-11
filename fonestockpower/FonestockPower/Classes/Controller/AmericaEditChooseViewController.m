//
//  AmericaEditChooseViewController.m
//  WirtsLeg
//
//  Created by Neil on 13/10/14.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "AmericaEditChooseViewController.h"
#import "FSUIButton.h"
#import "BtnCollectionView.h"

@interface AmericaEditChooseViewController ()

@property (strong) UILabel * titleLabel;
@property (strong) UILabel * bottomLabel;
@property (strong) BtnCollectionView * collectionView;

@property (strong) NSString * identSymbol;





@property (nonatomic) int totalCount;
@end

@implementation AmericaEditChooseViewController

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
    
    [self initView];
	// Do any additional setup after loading the view.
}


-(void)initView{
    self.dataArray = [[NSMutableArray alloc]init];
    self.dataIdArray = [[NSMutableArray alloc]init];
    self.dataIdentCodeArray = [[NSMutableArray alloc]init];
    self.chooseArray = [[NSMutableArray alloc]init];
    _totalCount = 0;
    
    self.titleLabel = [[UILabel alloc]init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.text = NSLocalizedStringFromTable(@"由下列標的物選取股票", @"SecuritySearch", nil);
    _titleLabel.textColor = [UIColor blueColor];
    _titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_titleLabel];
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    aFlowLayout.itemSize = CGSizeMake(308, 40);
    aFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    aFlowLayout.minimumInteritemSpacing = 1.0f;
    aFlowLayout.minimumLineSpacing = 1.0f;
    
    _collectionView = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 314, 200) collectionViewLayout:aFlowLayout];
    _collectionView.btnFlag=1;
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView setCollectionViewLayout:aFlowLayout animated:YES];
    _collectionView.myDelegate = self;
    _collectionView.searchGroup =1;
    
    _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    _collectionView.layer.borderWidth = 1.0f;
    _collectionView.aligment = UIControlContentHorizontalAlignmentLeft;
    
    [self.view addSubview:_collectionView];
    
    self.bottomLabel = [[UILabel alloc]init];
    _bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _bottomLabel.text = NSLocalizedStringFromTable(@"自選股數", @"SecuritySearch", nil);
    _bottomLabel.textColor = [UIColor blueColor];
    _bottomLabel.font = [UIFont systemFontOfSize:18.0f];
    [self.view addSubview:_bottomLabel];
    
    self.noStockLabel = [[UILabel alloc]init];
    _noStockLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _noStockLabel.text = NSLocalizedStringFromTable(@"無相符個股", @"SecuritySearch", nil);
    _noStockLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_noStockLabel];
    _noStockLabel.hidden = YES;
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints {
    
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_titleLabel,_collectionView,_bottomLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_titleLabel]-2-[_collectionView]-2-[_bottomLabel(45)]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_titleLabel]-5-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_collectionView]-3-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_bottomLabel]-5-|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    [super updateViewConstraints];
}

-(void)reloadBtn{
    _collectionView.btnArray=_dataArray;
    _collectionView.chooseArray = _chooseArray;
    _collectionView.holdBtn = 99999;
    [_collectionView reloadData];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self registerTickDataNotificationCallBack:self seletor:@selector(TickDataNotification)];
    [self registerLoginNotificationCallBack:self seletor:@selector(TickDataNotification)];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setEditChooseTarget:self];
    [dataModal.securitySearchModel performSelector:@selector(countUserStock) onThread:dataModal.thread withObject:nil waitUntilDone:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self unRegisterTickDataNotificationCallBack:nil];
    [self unregisterLoginNotificationCallBack:nil];
}

-(void)totalCount:(NSNumber *)count{
    _totalCount = [count intValue];
    _bottomLabel.text =[NSString stringWithFormat:@"(%@)",NSLocalizedStringFromTable(@"橘色為已加入自選股", @"SecuritySearch", nil)];
}

-(void)editTotalCount:(NSNumber *)count{
    _totalCount += [count intValue];
    _bottomLabel.text =[NSString stringWithFormat:@"(%@)",NSLocalizedStringFromTable(@"橘色為已加入自選股", @"SecuritySearch", nil)];
}


-(void)titleButtonClick:(FSUIButton *)button{
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    NSMutableArray * array = [[NSMutableArray alloc]init];
    [array addObject:[NSString stringWithFormat:@"%@ %@",[_dataIdentCodeArray objectAtIndex:button.tag],[_dataIdArray objectAtIndex:button.tag]]];
    [array addObject:[NSNumber numberWithInt:_searchGroupId]];
    if (button.selected == YES) {
        button.selected = NO;
        button.titleLabel.textColor = [UIColor blackColor];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //delete 自選股
        [self.chooseArray removeObject:[NSNumber numberWithInt:(int)button.tag]];
        SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",[_dataIdentCodeArray objectAtIndex:button.tag],[_dataIdArray objectAtIndex:button.tag]]];
        [dataModal.portfolioData RemoveItem:secu->identCode andSymbol:secu->symbol];
        [self editTotalCount:[NSNumber numberWithInt:-1]];
        _totalCount-=1;
//            DataModalProc *dataModal = [DataModalProc getDataModal];
//            [dataModal.securitySearchModel setEditChooseTarget:self];
//            [dataModal.securitySearchModel performSelector:@selector(deleteUserStock:) onThread:dataModal.thread withObject:array waitUntilDone:NO];
    }else{
        if (_totalCount/2<[[FSFonestock sharedInstance]portfolioQuota]) {
            button.selected = YES;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //判斷是否已存在 如已加入則修改
            FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
            [dataModal.securitySearchModel setEditChooseTarget:self];
            [dataModal.securitySearchModel performSelector:@selector(editUserStock:) onThread:dataModal.thread withObject:array waitUntilDone:NO];
            [self.chooseArray addObject:[NSNumber numberWithInt:(int)button.tag]];
            
            SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",[_dataIdentCodeArray objectAtIndex:button.tag],[_dataIdArray objectAtIndex:button.tag]]];
            _identSymbol = [NSString stringWithFormat:@"%@ %@",[_dataIdentCodeArray objectAtIndex:button.tag],[_dataIdArray objectAtIndex:button.tag]];
            [dataModal.portfolioData AddItem:secu];
            _totalCount+=1;
        }else{
            UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedStringFromTable(@"自選股已達上限", @"SecuritySearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"SecuritySearch", nil) otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)TickDataNotification{
    PortfolioTick *tickBank_P = [[FSDataModelProc sharedInstance]portfolioTickBank];
    
    if (_identSymbol != nil) {
        [tickBank_P goGetTickByIdentSymbolForStock:_identSymbol];

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
