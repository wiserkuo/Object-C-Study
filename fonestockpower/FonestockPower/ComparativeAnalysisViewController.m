//
//  ComparativeAnalysisViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "ComparativeAnalysisViewController.h"
#import "ComparativeAnalysisDrawView.h"
#import "ComparativeTableViewCell.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "WarrantMainViewController.h"
@interface ComparativeAnalysisViewController ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
{
    UILabel *targetLabel;
    UILabel *brokersLabel;
    UILabel *YLabel;
    UILabel *XLabel;
    
    FSUIButton *targetButton;
    FSUIButton *brokersButton;
    FSUIButton *typeButton;
    FSUIButton *YButton;
    FSUIButton *XButton;
    UITableView *mainTableView;
    
    ComparativeAnalysisDrawView *drawView;
    NSMutableArray *dataArray;
    
    NSString *targetName;
    NSString *targetIdentCodeSymbol;
    
    FSDataModelProc *model;
    EquitySnapshotDecompressed *snapShot;
    
    UIActionSheet *brokersSheet;
    NSMutableArray *brokersOptionArray;
    UIActionSheet *typeSheet;
    NSMutableArray *typeOptionArray;
    UIActionSheet *ySheet;
    NSMutableArray *yOptionArray;
    UIActionSheet *xSheet;
    NSMutableArray *xOptionArray;
    NSString *xFormula;
    NSString *yFormula;
    NSString *brokersFormula;
    NSString *typeFormula;
    NSString *formula;
    NSMutableArray *drawArray;
    BOOL firstFlag;
}
@end

@implementation ComparativeAnalysisViewController

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
    [self initOptionArray];
	[self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    
    xFormula = @"ExercisePrice";
    yFormula = @"Date";
    formula = @"";
    brokersFormula = @"";
    typeFormula = @"";
}
-(void)initOptionArray
{
    typeOptionArray = [[NSMutableArray alloc] initWithObjects:NSLocalizedStringFromTable(@"全部", @"Warrant", nil), NSLocalizedStringFromTable(@"認購", @"Warrant", nil), NSLocalizedStringFromTable(@"認售", @"Warrant", nil) , nil];
    yOptionArray = [[NSMutableArray alloc] initWithObjects:NSLocalizedStringFromTable(@"剩餘天數", @"Warrant", nil), NSLocalizedStringFromTable(@"實質槓桿", @"Warrant", nil), NSLocalizedStringFromTable(@"隱含波動", @"Warrant", nil), NSLocalizedStringFromTable(@"距損平%", @"Warrant", nil), NSLocalizedStringFromTable(@"Delta", @"Warrant", nil), nil];
    xOptionArray = [[NSMutableArray alloc] initWithObjects:NSLocalizedStringFromTable(@"履約價", @"Warrant", nil), NSLocalizedStringFromTable(@"價內外%", @"Warrant", nil), nil];
}

-(void)sendHandler
{
    snapShot = [model.portfolioTickBank getSnapshotFromIdentCodeSymbol:targetIdentCodeSymbol];
    [model.warrant setTarget:self];
    [model.warrant.warrantArray removeAllObjects];
    [model.warrant sendIdentSymbol:targetIdentCodeSymbol function:6 fullName:targetName targetPrice:snapShot.ceilingPrice];
}

-(void)notifyData
{
    dataArray = [model.warrant getXYData:formula xText:xFormula yText:yFormula];
    drawView.dataArray = dataArray;
    [drawView setNeedsDisplay];
}

-(void)initView
{
    targetLabel = [[UILabel alloc] init];
    targetLabel.text = NSLocalizedStringFromTable(@"權證標的", @"Warrant", nil);
    targetLabel.textColor = [UIColor blueColor];
    targetLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetLabel];
    
    brokersLabel = [[UILabel alloc] init];
    brokersLabel.text = NSLocalizedStringFromTable(@"券商", @"Warrant", nil);
    brokersLabel.textColor = [UIColor blueColor];
    brokersLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:brokersLabel];
    
    YLabel = [[UILabel alloc] init];
    YLabel.text = NSLocalizedStringFromTable(@"Y軸", @"Warrant", nil);
    YLabel.textColor = [UIColor blueColor];
    YLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:YLabel];
    
    XLabel = [[UILabel alloc] init];
    XLabel.text = NSLocalizedStringFromTable(@"X軸", @"Warrant", nil);
    XLabel.textColor = [UIColor blueColor];
    XLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:XLabel];
    
    targetButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    [targetButton setTitle:@"三陽" forState:UIControlStateNormal];
    targetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetButton];
    
    brokersButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    [brokersButton setTitle:@"全部" forState:UIControlStateNormal];
    [brokersButton addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    brokersButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:brokersButton];
    
    typeButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    [typeButton setTitle:@"全部" forState:UIControlStateNormal];
    [typeButton addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    typeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:typeButton];
    
    YButton= [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    [YButton setTitle:@"剩餘天數" forState:UIControlStateNormal];
    [YButton addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    YButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:YButton];
    
    XButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    [XButton setTitle:@"履約價" forState:UIControlStateNormal];
    [XButton addTarget:self action:@selector(btnHandler:) forControlEvents:UIControlEventTouchUpInside];
    XButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:XButton];
    
    drawView = [[ComparativeAnalysisDrawView alloc] init];
    drawView.backgroundColor = [UIColor clearColor];
    [drawView setTarget:self];
    drawView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:drawView];
    
    mainTableView = [[UITableView alloc] init];
    
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.hidden = YES;
    mainTableView.bounces = NO;
    mainTableView.layer.borderWidth = 1.0f;
    [self.view addSubview:mainTableView];
    
    [self.view setNeedsUpdateConstraints];
}

-(void)btnHandler:(FSUIButton *)target
{
    if([target isEqual:brokersButton]){
        brokersSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"選擇券商", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        brokersOptionArray = [model.warrant getComparativeBrokers];
        for(int i =0; i<[brokersOptionArray count]; i++){
            [brokersSheet addButtonWithTitle:[brokersOptionArray objectAtIndex:i]];
        }
        [brokersSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
        brokersSheet.cancelButtonIndex = [brokersOptionArray count];
        [self showActionSheet:brokersSheet];
    }else if([target isEqual:typeButton]){
        typeSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"顯示方式", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        for(int i =0; i<[typeOptionArray count]; i++){
            [typeSheet addButtonWithTitle:[typeOptionArray objectAtIndex:i]];
        }
        [typeSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
        typeSheet.cancelButtonIndex = [typeOptionArray count];
        [self showActionSheet:typeSheet];
    }else if([target isEqual:YButton]){
        ySheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"Y軸", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        for(int i =0; i<[yOptionArray count]; i++){
            [ySheet addButtonWithTitle:[yOptionArray objectAtIndex:i]];
        }
        [ySheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
        ySheet.cancelButtonIndex = [yOptionArray count];
        [self showActionSheet:ySheet];
    }else if([target isEqual:XButton]){
        xSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"X軸", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        for(int i =0; i<[xOptionArray count]; i++){
            [xSheet addButtonWithTitle:[xOptionArray objectAtIndex:i]];
        }
        [xSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
        xSheet.cancelButtonIndex = [xOptionArray count];
        [self showActionSheet:xSheet];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if([actionSheet isEqual:brokersSheet]){
        if(buttonIndex !=[brokersOptionArray count]){
            [brokersButton setTitle:[brokersOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            if(buttonIndex == 0){
                brokersFormula = @"";
            }else{
                brokersFormula = [NSString stringWithFormat:@"Brokers = '%@'",[brokersOptionArray objectAtIndex:buttonIndex]];
            }
        }
    }else if([actionSheet isEqual:typeSheet]){
        if(buttonIndex !=[typeOptionArray count]){
            [typeButton setTitle:[typeOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            if(buttonIndex == 0){
                typeFormula = @"";
            }else{
                typeFormula = [NSString stringWithFormat:@"Type = '%@'",[typeOptionArray objectAtIndex:buttonIndex]];
            }
        }
    }else if([actionSheet isEqual:xSheet]){
        if(buttonIndex !=[xOptionArray count]){
            [XButton setTitle:[xOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            switch (buttonIndex) {
                case 0:
                    xFormula = @"ExercisePrice";
                    break;
                case 1:
                    xFormula = @"InOutMoney";
                    break;
            }
        }
        
    }else if([actionSheet isEqual:ySheet]){
        if(buttonIndex !=[yOptionArray count]){
            [YButton setTitle:[yOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            switch (buttonIndex) {
                case 0:
                    yFormula = @"Date";
                    break;
                case 1:
                    yFormula = @"Gearingratio";
                    break;
                case 2:
                    yFormula = @"IV";
                    break;
                case 3:
                    yFormula = @"FlatSpot";
                    break;
                case 4:
                    
                    break;
            }
        }

    }
    
    if(![brokersFormula isEqualToString:@""]){
        if(!firstFlag){
            formula = [NSString stringWithFormat:@"Where %@", brokersFormula];
        }else{
            formula = [NSString stringWithFormat:@"%@ and %@", formula, brokersFormula];
        }
    }
    
    if(![typeFormula isEqualToString:@""]){
        if(!firstFlag){
            formula = [NSString stringWithFormat:@"Where %@", typeFormula];
            firstFlag = YES;
        }else{
            formula = [NSString stringWithFormat:@"%@ and %@", formula, typeFormula];
        }
    }
    
    if([yFormula isEqualToString:@"Gearingratio"]){
        if(!firstFlag){
            formula = [NSString stringWithFormat:@"Where Price > 0"];
            firstFlag = YES;
        }else{
            formula = [NSString stringWithFormat:@"%@ and Price > 0", formula];
        }
    }
    
    firstFlag = NO;
    
    dataArray = [model.warrant getXYData:formula xText:xFormula yText:yFormula];
    drawView.dataArray = dataArray;
    [drawView setNeedsDisplay];

    formula = @"";
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary * heightDictionary = @{@"drawViewHeight":@((self.view.frame.size.height-66))};
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(targetLabel, targetButton, brokersLabel, brokersButton, typeButton, YLabel, YButton, XLabel, XButton, drawView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[targetLabel(33)][typeButton(33)][drawView(drawViewHeight)]" options:0 metrics:heightDictionary views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[targetLabel][targetButton(80)][brokersLabel(==targetLabel)][brokersButton(100)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[typeButton(60)][YLabel][YButton(100)][XLabel(==YLabel)][XButton(80)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[drawView]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[targetButton(==typeButton)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[YButton(==typeButton)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[brokersButton(==typeButton)]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[XButton(==typeButton)]" options:0 metrics:nil views:viewDictionary]];
    
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Cell = @"Cell";
    ComparativeTableViewCell *cell = (ComparativeTableViewCell *)[mainTableView dequeueReusableCellWithIdentifier:Cell];
    if(cell == nil){
        cell = [[ComparativeTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cell];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if([drawArray count] != 0){
        ComparativeObject *obj = [drawArray objectAtIndex:indexPath.row];
        cell.leftLabel.text = obj->warrantSymbol;
        if([obj->type isEqualToString:@"認購"]){
            cell.rightLabel.text = @"購";
            cell.rightLabel.textColor = [UIColor redColor];
        }else{
            cell.rightLabel.text = @"售";
            cell.rightLabel.textColor = [UIColor greenColor];
        }
        
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [drawArray count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:19.0/255.0 green:85.0/255.0 blue:115.0/255.0 alpha:1];
    
    UILabel *title = [[UILabel alloc] init];
    title.text = NSLocalizedStringFromTable(@"權證", @"Warrant", nil);
    title.textColor = [UIColor whiteColor];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:title];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [closeBtn setTitle:@"Ⅹ" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [closeBtn addTarget:self action:@selector(closeHandler:) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:closeBtn];
    
    
    NSDictionary *headerDictionary = NSDictionaryOfVariableBindings(title, closeBtn);
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[title]|" options:0 metrics:nil views:headerDictionary]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[title][closeBtn]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:headerDictionary]];
    
    return headerView;
}

-(void)closeHandler:(UIButton *)target
{
    mainTableView.hidden = YES;
}

-(void)reload:(NSMutableArray *)saveArray touchPoint:(double)pointX
{
    drawArray = saveArray;
    if([drawArray count]!=0){
        [mainTableView setContentSize:CGSizeMake(100, 33+25*[drawArray count])];
        [mainTableView reloadData];
        mainTableView.hidden = NO;
        
        if(pointX < 40 +(self.view.frame.size.width-50)/2){
            [mainTableView setFrame:CGRectMake(drawView.frame.size.width-110, self.view.frame.size.height - drawView.frame.size.height+20, 100, 30+25*[drawArray count])];
        }else{
            [mainTableView setFrame:CGRectMake(40, self.view.frame.size.height - drawView.frame.size.height+20, 100, 30+25*[drawArray count])];
        }
    }else{
        mainTableView.hidden = YES;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ComparativeObject * obj = [drawArray objectAtIndex:indexPath.row];
    NewSymbolObject * symbolObj = [[NewSymbolObject alloc] init];
    symbolObj.identCode = [obj->warrantIdentCodeSymbol substringToIndex:2];
    symbolObj.symbol = [obj->warrantIdentCodeSymbol substringFromIndex:3];
    symbolObj.fullName = obj->warrantSymbol;
    [model.portfolioData addWatchListItemNewSymbolObjArray:@[symbolObj]];
    PortfolioItem *portfolio = [model.portfolioData findItemByIdentCodeSymbol:targetIdentCodeSymbol];
    PortfolioItem *comparedPortfolio =[model.portfolioData findItemByIdentCodeSymbol:obj->warrantIdentCodeSymbol];
    FSInstantInfoWatchedPortfolio * watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    watchPortfolio.portfolioItem = portfolio;
    watchPortfolio.comparedPortfolioItem = comparedPortfolio;
    WarrantMainViewController *warrantMainViewController = [[WarrantMainViewController alloc] init];
    [self.navigationController pushViewController:warrantMainViewController animated:NO];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 25.0f;
}
@end
