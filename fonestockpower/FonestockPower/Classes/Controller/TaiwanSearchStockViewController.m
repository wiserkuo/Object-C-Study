//
//  TaiwanSearchStockViewController.m
//  Bullseye
//
//  Created by Neil on 13/9/17.
//
//

#import "TaiwanSearchStockViewController.h"
#import "BtnCollectionView.h"
#import "FSActionPlanDatabase.h"

@interface TaiwanSearchStockViewController (){
    

}

@end

@implementation TaiwanSearchStockViewController
@synthesize storeArray, totalCount, count;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    count = 0;
    _userStockArray = [[NSMutableArray alloc]init];
    _userICArray = [[NSMutableArray alloc]init];
    
    [self initView];
}

- (void)initView{
    
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _titleLabel.textColor = [UIColor blueColor];
    _titleLabel.font = [UIFont systemFontOfSize:20.0f];
    
    if (_changeStock) {
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取股票", @"SecuritySearch", nil)];
    } else {
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取幾隻股票", @"SecuritySearch", nil), count];
    }
    [self.view addSubview:_titleLabel];
    
    
    UICollectionViewFlowLayout *aFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    aFlowLayout.itemSize = CGSizeMake(102, 40);
    aFlowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
    aFlowLayout.minimumInteritemSpacing = 1.0f;
    aFlowLayout.minimumLineSpacing = 1.0f;
    
    _collectionView = [[BtnCollectionView alloc]initWithFrame:CGRectMake(3, 10, 314, 200) collectionViewLayout:aFlowLayout];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    [_collectionView setCollectionViewLayout:aFlowLayout animated:YES];
    _collectionView.myDelegate = self;
    _collectionView.layer.borderColor = [UIColor blackColor].CGColor;
    _collectionView.layer.borderWidth = 1.0f;
    [self.view addSubview:_collectionView];
    
    
    
    _noStockLabel = [[UILabel alloc]init];
    _noStockLabel.hidden = YES;
    _noStockLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _noStockLabel.text = NSLocalizedStringFromTable(@"無相符個股", @"SecuritySearch", nil);
    _noStockLabel.font = [UIFont systemFontOfSize:20.0f];
    [self.view addSubview:_noStockLabel];
    
    
    
    _backToListBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    _backToListBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_backToListBtn setTitle:NSLocalizedStringFromTable(@"回到列表", @"SecuritySearch", nil) forState:UIControlStateNormal];
    [_backToListBtn addTarget:self action:@selector(backToListBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_backToListBtn];
    
    
    _backToListBtn.hidden = YES;
    _titleLabel.hidden = YES;
    
    [self.view setNeedsUpdateConstraints];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    totalCount = [dataModal.securitySearchModel countUserStockNum];
}

-(void)reloadButton{
    _collectionView.btnArray = _data1Array;
    
    
    if(_changeStock){
        _collectionView.chooseArray = [[NSMutableArray alloc]init];
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取股票", @"SecuritySearch", nil)];
    }else{
        _collectionView.chooseArray = [self changeBtnColor];
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取幾隻股票", @"SecuritySearch", nil),count];
    }
    _collectionView.holdBtn = 99999;
    [_collectionView reloadData];
}

-(NSMutableArray *)changeBtnColor{
    count = 0;
    NSMutableArray * array = [[NSMutableArray alloc]init];
    for (int i=0; i<[_dataIdArray count]; i++) {
        for (int j=0; j<[_userStockArray count]; j++) {
            if ([[_dataIdArray objectAtIndex:i] isEqual:[_userStockArray objectAtIndex:j]] &&
                [[_dataICArray objectAtIndex:i] isEqual:[_userICArray objectAtIndex:j]]) {
                [array addObject:[NSNumber numberWithInt:i]];
                count +=1;
            }
        }
    }
    return array;
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_titleLabel, _collectionView, _backToListBtn);
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_titleLabel]-2-[_collectionView]-2-[_backToListBtn(44)]-1-|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_titleLabel]-5-|" options:0 metrics:nil views:viewControllers]];
    

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[_collectionView]-3-|" options:0 metrics:nil views:viewControllers]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_backToListBtn(70)]|" options:0 metrics:nil views:viewControllers]];
    
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:_noStockLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_collectionView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    [self replaceCustomizeConstraints:constraints];
    
}

//- (void)viewDidLayoutSubviews {
////    _backToListBtn.hidden = NO;
////    _titleLabel.hidden = NO;
//    NSLog(@"viewDidLayoutSubviews");
//}


-(void)groupButtonClick:(FSUIButton *)button Object:(BtnCollectionView *)scrl{
    NSLog(@"%@:%@",button.titleLabel.text,[_dataIdArray objectAtIndex:button.tag]);
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    NSString *targetIdentCode = @"TW";
#ifdef PatternPowerCN
    targetIdentCode = _dataICArray[button.tag];
#endif
    if (_changeStock) {
        NSString * symbolStr = [NSString stringWithFormat:@"%@ %@",targetIdentCode,[_dataIdArray objectAtIndex:button.tag]];
        [dataModal.portfolioData addWatchListItemByIdentSymbolArray:@[symbolStr]];
        PortfolioItem *portfolioItem = [dataModal.portfolioData findItemByIdentCodeSymbol:symbolStr];
        
        [_delegate changeStockWithPortfolioItem:portfolioItem];
    }else{
        storeArray = [[NSMutableArray alloc]init];
        [storeArray addObject:[NSString stringWithFormat:@"%@ %@",targetIdentCode,[_dataIdArray objectAtIndex:button.tag]]];
        [storeArray addObject:[NSNumber numberWithInt:_searchGroup]];
        if (button.selected == NO) {
            BOOL existFlag = NO;
            NSMutableArray *actionPlan = [[FSActionPlanDatabase sharedInstances] searchActionPlanIdentCodeSymbol];
            for (int i = 0; i < [actionPlan count]; i++) {
                if ([[storeArray objectAtIndex:0] isEqualToString:[actionPlan objectAtIndex:i]]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"我的自選" message:@"此檔股票已在交易計劃清單當中\n若要移除\n請先至交易計劃刪除此檔股票\n再回到我的自選做刪除" delegate:self cancelButtonTitle:@"確認" otherButtonTitles:nil];
                    [alert show];
                    existFlag = YES;
                }
            }
            if (!existFlag) {
                button.titleLabel.textColor = [UIColor blackColor];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                //delete 自選股
                SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",targetIdentCode,[_dataIdArray objectAtIndex:button.tag]]];
                [dataModal.portfolioData RemoveItem:secu->identCode andSymbol:secu->symbol];
                totalCount-=1;
                count-=1;
            }
            
        }else{
            if (totalCount<[[FSFonestock sharedInstance]portfolioQuota]) {
                //判斷是否已加入自選
                NSMutableArray * totalCountArray = [[NSMutableArray alloc]init];
                
                FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
                FSDatabaseAgent *dbAgent = dataModel.mainDB;
                
                [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
                    FMResultSet *  message = [db executeQuery:@"SELECT count(IdentCodeSymbol) as count FROM groupPortfolio where  IdentCodeSymbol = ? ",[storeArray objectAtIndex:0]];
                    while ([message next]) {
                        [totalCountArray addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
                    }
                }];
                if ([(NSNumber *)[totalCountArray objectAtIndex:0]intValue]==0) { //未加入
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",targetIdentCode,[_dataIdArray objectAtIndex:button.tag]]];
                    //加入Item & DB
                    [dataModal.portfolioData AddItem:secu];
                    totalCount+=1;
                    count+=1;
                }else{ //加入
                    _storeBtn = button;
                    NSArray *numArray = @[@"", @"一", @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九", @"十"];
                    _existAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedStringFromTable(@"此檔股票已存在確定要移到自選嗎",@"SecuritySearch",nil), [numArray objectAtIndex:[(NSNumber *)[storeArray objectAtIndex:1] intValue]]] message:nil delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"SecuritySearch", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"SecuritySearch", nil), nil];
                    [_existAlert show];
                    return;
                }
            }else{
                UIAlertView * alert = [[UIAlertView alloc]initWithTitle:NSLocalizedStringFromTable(@"警告", @"SecuritySearch", nil) message:NSLocalizedStringFromTable(@"自選股已達上限", @"SecuritySearch", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"SecuritySearch", nil) otherButtonTitles:nil];
                [alert show];
            }
        }
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取幾隻股票", @"SecuritySearch", nil),count];
        [dataModal.securitySearchModel setChooseTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchGroup] waitUntilDone:NO];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView isEqual:_existAlert]) {
        NSString *targetIdentCode = @"TW";
#ifdef PatternPowerCN
        targetIdentCode = _dataICArray[buttonIndex];
#endif
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        if (buttonIndex == 1) {
            [_storeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //判斷是否已存在 如已加入則修改
            [dataModal.securitySearchModel setEditChooseTarget:self];
            [dataModal.securitySearchModel performSelector:@selector(editUserStock:) onThread:dataModal.thread withObject:storeArray waitUntilDone:NO];
            
            SecurityName* secu = [dataModal.securityName securityNameWithIdentCodeSymbol:[NSString stringWithFormat:@"%@ %@",targetIdentCode, [_dataIdArray objectAtIndex:_storeBtn.tag]]];
            //加入Item & DB
            [dataModal.portfolioData AddItem:secu];
            totalCount+=1;
            count+=1;
        }
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取幾隻股票", @"SecuritySearch", nil),count];
        [dataModal.securitySearchModel setChooseTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchGroup] waitUntilDone:NO];
    }
}

-(void)editTotalCount:(NSNumber *)count{
    
}

-(void)backToListBtnClick{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(backToList)]){
        [_delegate backToList];
    }
    
    _backToListBtn.hidden = NO;
    _titleLabel.hidden = NO;
}

-(void)setSearchGroup{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.portfolioData selectGroupID: _searchGroup];
    [self changeGroup];
}

-(void)changeGroup{
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setChooseTarget:self];
    if (_searchGroup == 0) {
        _searchGroup = 1;
    }
//    [dataModal.securitySearchModel performSelector:@selector(searchUserStockWithGroup:) onThread:dataModal.thread withObject:[NSNumber numberWithInt:_searchGroup] waitUntilDone:NO];
    [self notifyDataArrive:[dataModal.securitySearchModel searchUserStockWithGroup2:[NSNumber numberWithInt:_searchGroup]]];
    
}
-(void)notifyDataArrive:(NSMutableArray *)array{
    //    _dataNameArray = [array objectAtIndex:0];
    _userStockArray = [array objectAtIndex:1];
    _userICArray = [array objectAtIndex:2];
    
    
    
    if(_changeStock){
        _collectionView.chooseArray = [[NSMutableArray alloc]init];
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取股票", @"SecuritySearch", nil)];
    }else{
        _collectionView.chooseArray = [self changeBtnColor];
        _titleLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"選取幾隻股票", @"SecuritySearch", nil),count];
    }
    _collectionView.holdBtn = 99999;
    [_collectionView reloadData];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
