//
//  WarrantViewController.m
//  WirtsLeg
//
//  Created by Connor on 13/9/26.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "WarrantViewController.h"
#import "FSUIButton.h"
#import "SKCustomTableView.h"
#import "StockConstant.h"
#import "WarrantQueryIn.h"
#import "WarrantChangeViewController.h"
#import "WarrantChartViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "WarrantMainViewController.h"

@interface WarrantViewController () <UIActionSheetDelegate>
{
    UIActionSheet *typeOptionSheet;
    UIActionSheet *brokersSheet;
    UIActionSheet *priceInOutSheet;
    UIActionSheet *lossBalanceSheet;
    UIActionSheet *dateSheet;
    UIActionSheet *IVSheet;
    UIActionSheet *IV_HVSheet;
    EquitySnapshotDecompressed *snapShot;
    NSMutableArray *warrantArray;
    NSString *formula;
    BOOL formulaFlag;
    
    NSString *brokersFormula;
    NSString *typeFormula;
    NSString *priceFormula;
    NSString *flatSpotFormula;
    NSString *dateFormula;
    NSString *IVFormula;
    NSString *IV_HVFormula;
    int objNum;
    NSMutableArray *layoutConstraints;
    NSString *comparedSymbol;
}

@property (strong, nonatomic) FSDataModelProc *dataModel;
@property (strong, nonatomic) UILabel *warrantTargetLabel;
@property (strong, nonatomic) UILabel *brokersLabel;
@property (strong, nonatomic) UILabel *typeLabel;
@property (strong, nonatomic) UILabel *priceInOutLabel;
@property (strong, nonatomic) UILabel *lossBalanceLabel;
@property (strong, nonatomic) UILabel *remainingDayLabel;
@property (strong, nonatomic) UILabel *IVLabel;
@property (strong, nonatomic) UILabel *IVHVLabel;

@property (strong, nonatomic) UILabel *openPriceLabel;
@property (strong, nonatomic) UILabel *priceChangeLabel;
@property (strong, nonatomic) UILabel *stockVolumeLabel;


@property (strong, nonatomic) FSUIButton *warrantTargetButton;
@property (strong, nonatomic) FSUIButton *brokersButton;
@property (strong, nonatomic) FSUIButton *typeButton;
@property (strong, nonatomic) FSUIButton *priceInOutButton;
@property (strong, nonatomic) FSUIButton *lossBalanceButton;
@property (strong, nonatomic) FSUIButton *remainingDayButton;
@property (strong, nonatomic) FSUIButton *IVButton;
@property (strong, nonatomic) FSUIButton *IVHVButton;
@property (strong, nonatomic) FSUIButton *stockInfoButton;

@property (strong, nonatomic) NSArray *brokersOptionArray;
@property (strong, nonatomic) NSArray *typeOptionArray;
@property (strong, nonatomic) NSArray *priceInOutOptionArray;
@property (strong, nonatomic) NSArray *lossBalanceOptionArray;
@property (strong, nonatomic) NSArray *remainingDayOptionArray;
@property (strong, nonatomic) NSArray *IVOptionArray;
@property (strong, nonatomic) NSArray *IVHVOptionArray;
@property (strong, nonatomic) NSArray *stockInfoOptionArray;

@property (unsafe_unretained, nonatomic) NSInteger warrantTargetButtonSelectIndex;
@property (unsafe_unretained, nonatomic) NSInteger brokersButtonSelectIndex;
@property (unsafe_unretained, nonatomic) NSInteger typeButtonSelectIndex;
@property (unsafe_unretained, nonatomic) NSInteger priceInOutButtonSelectIndex;
@property (unsafe_unretained, nonatomic) NSInteger lossBalanceButtonSelectIndex;
@property (unsafe_unretained, nonatomic) NSInteger remainingDayButtonSelectIndex;
@property (unsafe_unretained, nonatomic) NSInteger IVButtonSelectIndex;
@property (unsafe_unretained, nonatomic) NSInteger IVHVButtonSelectIndex;
@property (unsafe_unretained, nonatomic) NSInteger stockInfoButtonSelectIndex;

@property (strong, nonatomic) SKCustomTableView *mainTableView;

@end

@implementation WarrantViewController

@synthesize dataModel;
@synthesize targetStockName;
@synthesize targetSymbol;
@synthesize targetIdentCode;
@synthesize targetIdentCodeSymbol;

@synthesize name;
@synthesize symbol;
@synthesize identCode;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"權證";
        formula = @"";
        brokersFormula = @"";
        typeFormula = @"";
        priceFormula = @"";
        flatSpotFormula = @"";
        dateFormula = @"";
        IVFormula = @"";
        IV_HVFormula = @"";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    layoutConstraints = [[NSMutableArray alloc] init];
    [self initModel];
    [self initSelectedConditionIndex];
    
    [self initOption];
    [self initBrokersOption];
    [self initTypeOption];
    [self initPriceInOutOption];
    [self initLossBalanceOption];
    [self initRemainingDayOption];
    [self initIVOption];
    [self initIVHVOption];

    [self initMainTableView];
    [self initHeaderLabelsText];
    [self.view setNeedsUpdateConstraints];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self selectTargetWarrant];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [dataModel.portfolioData setTarget:nil];
}

-(void)initModel
{
    self.targetStockName = @"台積電";
    self.targetIdentCode = @"TW";
    self.targetSymbol = @"2330";
    
    identCode = malloc(2*sizeof(char));
    identCode[0]= 'T';
    identCode[1]= 'W';
    
    self.symbol = @"2330";
    self.name = @"台積電";
}

- (void)updateViewConstraints {
    
    [super updateViewConstraints];
    
    [self.view removeConstraints:layoutConstraints];
    
    [layoutConstraints removeAllObjects];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_warrantTargetLabel][_warrantTargetButton(==_warrantTargetLabel)][_brokersLabel(==_warrantTargetLabel)][_brokersButton(==_warrantTargetLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_warrantTargetLabel, _warrantTargetButton, _brokersLabel, _brokersButton)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_warrantTargetLabel(33)][_typeLabel(==_warrantTargetLabel)][_lossBalanceLabel(==_warrantTargetLabel)][_IVLabel(==_warrantTargetLabel)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(_warrantTargetLabel, _typeLabel, _lossBalanceLabel, _IVLabel)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_typeLabel][_typeButton(==_typeLabel)][_priceInOutLabel(==_typeLabel)][_priceInOutButton(==_typeLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_typeLabel, _typeButton, _priceInOutLabel, _priceInOutButton)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_lossBalanceLabel][_lossBalanceButton(==_lossBalanceLabel)][_remainingDayLabel(==_lossBalanceLabel)][_remainingDayButton(==_lossBalanceLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_lossBalanceLabel, _lossBalanceButton, _remainingDayLabel, _remainingDayButton)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_IVLabel][_IVButton(==_IVLabel)][_IVHVLabel(==_IVLabel)][_IVHVButton(==_IVLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_IVLabel, _IVButton, _IVHVLabel, _IVHVButton)]];
    
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_warrantTargetButton(33)][_typeButton(==_warrantTargetButton)][_lossBalanceButton(==_warrantTargetButton)][_IVButton(==_warrantTargetButton)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(_warrantTargetButton, _typeButton, _lossBalanceButton, _IVButton)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_brokersButton][_priceInOutButton(==_brokersButton)][_remainingDayButton(==_brokersButton)][_IVHVButton(==_brokersButton)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:NSDictionaryOfVariableBindings(_brokersButton, _priceInOutButton, _remainingDayButton, _IVHVButton)]];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_stockInfoButton(85)][_openPriceLabel][_priceChangeLabel(==_openPriceLabel)][_stockVolumeLabel(==_openPriceLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_stockInfoButton, _openPriceLabel, _priceChangeLabel, _stockVolumeLabel)]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_IVHVButton][_stockInfoButton]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_IVHVButton, _stockInfoButton)]];

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mainTableView]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:NSDictionaryOfVariableBindings(_mainTableView)]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_stockInfoButton][_mainTableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_stockInfoButton, _mainTableView)]];
    
    [self.view addConstraints:layoutConstraints];
}


- (void)initSelectedConditionIndex {
    self.warrantTargetButtonSelectIndex = 0;
    self.brokersButtonSelectIndex = 0;
    self.typeButtonSelectIndex = 0;
    self.priceInOutButtonSelectIndex = 0;
    self.lossBalanceButtonSelectIndex = 0;
    self.remainingDayButtonSelectIndex = 0;
    self.IVButtonSelectIndex = 0;
    self.IVHVButtonSelectIndex = 0;
    self.stockInfoButtonSelectIndex = 0;
}

#define WARRANT_NODE_ID 650
- (void)initOption {
    
    
    self.warrantTargetLabel = [[UILabel alloc] init];
    self.warrantTargetLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.warrantTargetLabel.textColor = [UIColor blueColor];
    [self.view addSubview:self.warrantTargetLabel];
    
    self.warrantTargetButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeActionPlanRed];
    self.warrantTargetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.warrantTargetButton addTarget:self action:@selector(warrantTargetHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.warrantTargetButton];
    
    self.stockInfoButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    self.stockInfoButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.stockInfoButton];
    
    self.openPriceLabel = [[UILabel alloc] init];
    self.openPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.openPriceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.openPriceLabel];
    
    self.priceChangeLabel = [[UILabel alloc] init];
    self.priceChangeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.priceChangeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.priceChangeLabel];
    
    self.stockVolumeLabel = [[UILabel alloc] init];
    self.stockVolumeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.stockVolumeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.stockVolumeLabel];
    
    [self.warrantTargetButton setTitle:self.targetStockName forState:UIControlStateNormal];
    [self.stockInfoButton setTitle:self.targetStockName forState:UIControlStateNormal];
}

-(void)warrantTargetHandler:(FSUIButton *)target
{
    [self.navigationController pushViewController:[[WarrantChangeViewController alloc] initWithTarget:self] animated:NO];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    formula = @"";
    formulaFlag = NO;
    //類型
    if([actionSheet isEqual:typeOptionSheet]){
        if(buttonIndex !=[_typeOptionArray count]){
            [self.typeButton setTitle:[_typeOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            if(buttonIndex == 0){
                typeFormula = @"";
            }else{
                typeFormula = [NSString stringWithFormat:@"Type = '%@'",[_typeOptionArray objectAtIndex:buttonIndex]];
            }
        }
    //券商
    }else if([actionSheet isEqual:brokersSheet]){
        if(buttonIndex !=[_brokersOptionArray count]){
            [self.brokersButton setTitle:[_brokersOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            if(buttonIndex == 0){
                brokersFormula = @"";
            }else{
                brokersFormula = [NSString stringWithFormat:@"Brokers = '%@'", [_brokersOptionArray objectAtIndex:buttonIndex]];
            }
        }
    //價內價外
    }else if([actionSheet isEqual:priceInOutSheet]){
        if(buttonIndex !=[_priceInOutOptionArray count]){
            [self.priceInOutButton setTitle:[_priceInOutOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            if(buttonIndex == 0){
                priceFormula = @"";
            }else{
                switch (buttonIndex) {
                    case 1:
                        priceFormula = @"InOutMoney > 0.2";
                        break;
                    case 2:
                        priceFormula = @"InOutMoney > 0.1 and InOutMoney < 0.2";
                        break;
                    case 3:
                        priceFormula = @"InOutMoney > 0 and InOutMoney < 0.1";
                        break;
                    case 4:
                        priceFormula = @"InOutMoney < 0 and InOutMoney > -0.1";
                        break;
                    case 5:
                        priceFormula = @"InOutMoney < -0.1 and InOutMoney > -0.2";
                        break;
                    case 6:
                        priceFormula = @"InOutMoney < -0.2";
                        break;
                }
            }
        }
    //距損平點
    }else if([actionSheet isEqual:lossBalanceSheet]){
        if(buttonIndex !=[_lossBalanceOptionArray count]){
            [self.lossBalanceButton setTitle:[_lossBalanceOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            if(buttonIndex == 0){
                flatSpotFormula = @"";
            }else{
                switch (buttonIndex) {
                    case 1:
                        flatSpotFormula = [NSString stringWithFormat:@"FlatSpot <= 0.05"];
                        break;
                    case 2:
                        flatSpotFormula = [NSString stringWithFormat:@"FlatSpot <= 0.1"];
                        break;
                    case 3:
                        flatSpotFormula = [NSString stringWithFormat:@"FlatSpot <= 0.2"];
                        break;
                    case 4:
                        flatSpotFormula = [NSString stringWithFormat:@"FlatSpot <= 0.3"];
                        break;
                    case 5:
                        flatSpotFormula = [NSString stringWithFormat:@"FlatSpot <= 0.4"];
                        break;
                }
            }
        }
    //剩餘天數
    }else if([actionSheet isEqual:dateSheet]){
        if(buttonIndex !=[_remainingDayOptionArray count]){
            [self.remainingDayButton setTitle:[_remainingDayOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            if(buttonIndex == 0){
                dateFormula = @"";
            }else{
                NSDate *date = [[NSDate alloc] init];
                UInt16 dateInt = [date uint16Value];
                switch (buttonIndex) {
                    case 1:
                        dateFormula = [NSString stringWithFormat:@"Date-%d <= 30", dateInt];
                        break;
                    case 2:
                        dateFormula = [NSString stringWithFormat:@"Date-%d <= 60", dateInt];
                        break;
                    case 3:
                        dateFormula = [NSString stringWithFormat:@"Date-%d <= 90", dateInt];
                        break;
                    case 4:
                        dateFormula = [NSString stringWithFormat:@"Date-%d >= 91", dateInt];
                        break;
                }
            }
        }
    //IV
    }else if([actionSheet isEqual:IVSheet]){
        if(buttonIndex !=[_IVOptionArray count]){
            [self.IVButton setTitle:[_IVOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            if(buttonIndex == 0){
                IVFormula = @"";
            }else{
                switch (buttonIndex) {
                    case 1:
                        IVFormula = [NSString stringWithFormat:@"IV <= 0.2"];
                        break;
                    case 2:
                        IVFormula = [NSString stringWithFormat:@"IV <= 0.3"];
                        break;
                    case 3:
                        IVFormula = [NSString stringWithFormat:@"IV <= 0.4"];
                        break;
                    case 4:
                        IVFormula = [NSString stringWithFormat:@"IV <= 0.5"];
                        break;
                    case 5:
                        IVFormula = [NSString stringWithFormat:@"IV <= 0.6"];
                        break;
                    case 6:
                        IVFormula = [NSString stringWithFormat:@"IV <= 0.7"];
                        break;
                    case 7:
                        IVFormula = [NSString stringWithFormat:@"IV >= 0.7"];
                        break;
                }
            }
        }
    //IV-HV
    }else if([actionSheet isEqual:IV_HVSheet]){
        if(buttonIndex !=[_IVHVOptionArray count]){
            [self.IVHVButton setTitle:[_IVHVOptionArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
            if(buttonIndex == 0){
                IV_HVFormula = @"";
            }else{
                switch (buttonIndex) {
                    case 1:
                        IV_HVFormula = [NSString stringWithFormat:@"IV_HV <= 0"];
                        break;
                    case 2:
                        IV_HVFormula = [NSString stringWithFormat:@"IV_HV <= 0.1"];
                        break;
                    case 3:
                        IV_HVFormula = [NSString stringWithFormat:@"IV_HV <= 0.2"];
                        break;
                    case 4:
                        IV_HVFormula = [NSString stringWithFormat:@"IV_HV <= 0.3"];
                        break;
                    case 5:
                        IV_HVFormula = [NSString stringWithFormat:@"IV_HV >= 0.3"];
                        break;
                }
            }
        }
    }
    [self getWarrantData];
}

-(void)getWarrantData
{
    if(![brokersFormula isEqualToString:@""]){
        formula = [self appendFormula:brokersFormula];
    }
    if(![typeFormula isEqualToString:@""]){
        formula = [self appendFormula:typeFormula];
    }
    if(![priceFormula isEqualToString:@""]){
        formula = [self appendFormula:priceFormula];
    }
    if(![flatSpotFormula isEqualToString:@""]){
        formula = [self appendFormula:flatSpotFormula];
    }
    if(![dateFormula isEqualToString:@""]){
        formula = [self appendFormula:dateFormula];
    }
    if(![IVFormula isEqualToString:@""]){
        formula = [self appendFormula:IVFormula];
    }
    if(![IV_HVFormula isEqualToString:@""]){
        formula = [self appendFormula:IV_HVFormula];
    }
    warrantArray = [dataModel.warrant getWarrantData:formula];
    [self.mainTableView reloadAllData];
}

-(NSString *)appendFormula:(NSString *)str
{
    if(!formulaFlag){
        formula = [NSString stringWithFormat:@"Where %@",str];
        formulaFlag = YES;
    }else{
        formula = [NSString stringWithFormat:@"%@ and %@",formula, str];
    }
    return formula;
}

- (void)initBrokersOption {
    self.brokersLabel = [[UILabel alloc] init];
    self.brokersLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.brokersLabel.textColor = [UIColor blueColor];
    [self.view addSubview:self.brokersLabel];
    
    self.brokersButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    self.brokersButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.brokersButton addTarget:self action:@selector(brokersHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.brokersButton];
    
}

-(void)brokersHandler:(FSUIButton *)target
{
    
    brokersSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"選擇券商", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    brokersSheet.delegate = self;
    _brokersOptionArray = [dataModel.warrant getBrokers];
    for(int i =0; i<[_brokersOptionArray count]; i++){
        [brokersSheet addButtonWithTitle:[_brokersOptionArray objectAtIndex:i]];
    }
    [brokersSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
    brokersSheet.cancelButtonIndex = [_brokersOptionArray count];
    [brokersSheet showInView:self.view];
}


- (void)initTypeOption {
    
    NSString *localeString1 = NSLocalizedStringFromTable(@"全部", @"EPS", nil);
    NSString *localeString2 = NSLocalizedStringFromTable(@"認購", @"EPS", nil);
    NSString *localeString3 = NSLocalizedStringFromTable(@"認售", @"EPS", nil);
    
    self.typeOptionArray = [NSArray arrayWithObjects:localeString1, localeString2, localeString3, nil];
    
    self.typeLabel = [[UILabel alloc] init];
    self.typeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.typeLabel.textColor = [UIColor blueColor];
    self.typeLabel.text = @"類型";
    
    [self.view addSubview:self.typeLabel];
    
    self.typeButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    self.typeButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.typeButton addTarget:self action:@selector(typeHandler:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.typeButton];
}

-(void)typeHandler:(FSUIButton *)target
{
    typeOptionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"類型", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    typeOptionSheet.delegate = self;
    for(int i =0; i<[self.typeOptionArray count]; i++){
        [typeOptionSheet addButtonWithTitle:[self.typeOptionArray objectAtIndex:i]];
    }
    [typeOptionSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
    typeOptionSheet.cancelButtonIndex = [self.typeOptionArray count];
    [typeOptionSheet showInView:self.view];
}

- (void)initPriceInOutOption {
    
    self.priceInOutOptionArray = [NSArray arrayWithObjects:
                            NSLocalizedStringFromTable(@"全部", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"價內20%以上", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"價內10%~價內20%", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"價內0%~價內10%", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"價外0%~價外10%", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"價外10%~價外20%", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"價外20%以上", @"Warrant", nil),
                            nil];
    
    self.priceInOutLabel = [[UILabel alloc] init];
    self.priceInOutLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.priceInOutLabel.textColor = [UIColor blueColor];
    [self.view addSubview:self.priceInOutLabel];
    
    self.priceInOutButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    self.priceInOutButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.priceInOutButton addTarget:self action:@selector(priceInOutHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.priceInOutButton];
}

-(void)priceInOutHandler:(FSUIButton *)target
{
    priceInOutSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"類型", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    priceInOutSheet.delegate = self;
    for(int i =0; i<[self.priceInOutOptionArray count]; i++){
        [priceInOutSheet addButtonWithTitle:[self.priceInOutOptionArray objectAtIndex:i]];
    }
    [priceInOutSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
    priceInOutSheet.cancelButtonIndex = [self.priceInOutOptionArray count];
    [priceInOutSheet showInView:self.view];
}



- (void)initLossBalanceOption {
    
    self.lossBalanceOptionArray = [NSArray arrayWithObjects:
                            NSLocalizedStringFromTable(@"全部", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"小於5%", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"小於10%", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"小於20%", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"小於30%", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"小於40%", @"Warrant", nil),
                            nil];
    
    self.lossBalanceLabel = [[UILabel alloc] init];
    self.lossBalanceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.lossBalanceLabel.textColor = [UIColor blueColor];
    [self.view addSubview:self.lossBalanceLabel];
    
    self.lossBalanceButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    self.lossBalanceButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.lossBalanceButton];
    [self.lossBalanceButton addTarget:self action:@selector(lossBalanceHandler:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)lossBalanceHandler:(FSUIButton *)target
{
    lossBalanceSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"類型", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    lossBalanceSheet.delegate = self;
    for(int i =0; i<[self.lossBalanceOptionArray count]; i++){
        [lossBalanceSheet addButtonWithTitle:[self.lossBalanceOptionArray objectAtIndex:i]];
    }
    [lossBalanceSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
    lossBalanceSheet.cancelButtonIndex = [self.lossBalanceOptionArray count];
    [lossBalanceSheet showInView:self.view];
}

- (void)initRemainingDayOption {
    
    self.remainingDayOptionArray = [NSArray arrayWithObjects:
                            NSLocalizedStringFromTable(@"全部", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"30日以內", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"60日以內", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"90日以內", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"91日以上", @"Warrant", nil),
                            nil];
    
    self.remainingDayLabel = [[UILabel alloc] init];
    self.remainingDayLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.remainingDayLabel.textColor = [UIColor blueColor];
    [self.view addSubview:self.remainingDayLabel];
    
    self.remainingDayButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    self.remainingDayButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.remainingDayButton addTarget:self action:@selector(remainingDayHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.remainingDayButton];
}

-(void)remainingDayHandler:(FSUIButton *)target
{
    dateSheet= [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"類型", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    dateSheet.delegate = self;
    for(int i =0; i<[self.remainingDayOptionArray count]; i++){
        [dateSheet addButtonWithTitle:[self.remainingDayOptionArray objectAtIndex:i]];
    }
    [dateSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
    dateSheet.cancelButtonIndex = [self.remainingDayOptionArray count];
    [dateSheet showInView:self.view];
}


- (void)initIVOption {
    self.IVOptionArray = [NSArray arrayWithObjects:
                            NSLocalizedStringFromTable(@"全部", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"20%以下", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"30%以下", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"40%以下", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"50%以下", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"60%以下", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"70%以下", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"70%以上", @"Warrant", nil),
                            nil];
    
    self.IVLabel = [[UILabel alloc] init];
    self.IVLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.IVLabel.textColor = [UIColor blueColor];
    [self.view addSubview:self.IVLabel];
    
    self.IVButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    self.IVButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.IVButton addTarget:self action:@selector(IVHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.IVButton];
}

-(void)IVHandler:(FSUIButton *)target
{
    IVSheet= [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"類型", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    IVSheet.delegate = self;
    for(int i =0; i<[self.IVOptionArray count]; i++){
        [IVSheet addButtonWithTitle:[self.IVOptionArray objectAtIndex:i]];
    }
    [IVSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
    IVSheet.cancelButtonIndex = [self.IVOptionArray count];
    [IVSheet showInView:self.view];
}

- (void)initIVHVOption {
    
    self.IVHVOptionArray = [NSArray arrayWithObjects:
                            NSLocalizedStringFromTable(@"全部", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"0%以下", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"10%以下", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"20%以下", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"30%以下", @"Warrant", nil),
                            NSLocalizedStringFromTable(@"30%以上", @"Warrant", nil),
                            nil];
    
    self.IVHVLabel = [[UILabel alloc] init];
    self.IVHVLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.IVHVLabel.textColor = [UIColor blueColor];
    [self.view addSubview:self.IVHVLabel];
    
    self.IVHVButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    self.IVHVButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.IVHVButton addTarget:self action:@selector(IVHVHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.IVHVButton];
}

-(void)IVHVHandler:(FSUIButton *)target
{
    IV_HVSheet= [[UIActionSheet alloc] initWithTitle:NSLocalizedStringFromTable(@"類型", @"Warrant", nil) delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    IV_HVSheet.delegate = self;
    for(int i =0; i<[self.IVHVOptionArray count]; i++){
        [IV_HVSheet addButtonWithTitle:[self.IVHVOptionArray objectAtIndex:i]];
    }
    [IV_HVSheet addButtonWithTitle:NSLocalizedStringFromTable(@"取消", @"Warrant", nil)];
    IV_HVSheet.cancelButtonIndex = [self.IVHVOptionArray count];
    [IV_HVSheet showInView:self.view];
}


- (void)initMainTableView {
    self.mainTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:77 AndColumnHeight:33];
    self.mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mainTableView.delegate = self;
    
    [self.view addSubview:_mainTableView];
}

- (void)initHeaderLabelsText {
    self.warrantTargetLabel.text = @"權證標的";
    
    self.brokersLabel.text = @"券商";
    [self.brokersButton setTitle:@"全部" forState:UIControlStateNormal];
    
    NSString *typeButtonTitle = [self.typeOptionArray objectAtIndex:self.typeButtonSelectIndex];
    [self.typeButton setTitle:typeButtonTitle forState:UIControlStateNormal];
    
    self.priceInOutLabel.text = @"價內外";
    NSString *priceInOutButtonTitle = [self.priceInOutOptionArray objectAtIndex:self.priceInOutButtonSelectIndex];
    [self.priceInOutButton setTitle:priceInOutButtonTitle forState:UIControlStateNormal];
    
    self.lossBalanceLabel.text = @"距損平點";
    [self.lossBalanceButton setTitle:@"全部" forState:UIControlStateNormal];
    
    self.remainingDayLabel.text = @"剩餘天數";
    [self.remainingDayButton setTitle:@"全部" forState:UIControlStateNormal];
    
    self.IVLabel.text = @"IV";
    [self.IVButton setTitle:@"全部" forState:UIControlStateNormal];
    
    self.IVHVLabel.text = @"IV-HV";
    [self.IVHVButton setTitle:@"全部" forState:UIControlStateNormal];
    
}

- (void)selectTargetWarrant {
    dataModel = [FSDataModelProc sharedInstance];
    [dataModel.portfolioData setTarget:self];
    self.priceChangeLabel.text = @"----";
    self.openPriceLabel.text = @"----";
    self.stockVolumeLabel.text = @"----";
    self.targetIdentCodeSymbol = [NSString stringWithFormat:@"%@ %@", self.targetIdentCode, self.targetSymbol];
    
    [self.warrantTargetButton setTitle:self.targetStockName forState:UIControlStateNormal];
    [self.stockInfoButton setTitle:self.targetStockName forState:UIControlStateNormal];
    
    NewSymbolObject * symbolObj = [[NewSymbolObject alloc] init];
    symbolObj.identCode = [self.targetIdentCodeSymbol substringToIndex:2];
    symbolObj.symbol = [self.targetIdentCodeSymbol substringFromIndex:3];
    symbolObj.fullName = self.targetStockName;	
    [dataModel.portfolioData addWatchListItemNewSymbolObjArray:@[symbolObj]];
    snapShot = [dataModel.portfolioTickBank getSnapshotFromIdentCodeSymbol:self.targetIdentCodeSymbol];
    
    [dataModel.warrant setTarget:self];
    [dataModel.portfolioTickBank watchTarget:self ForEquity:targetIdentCodeSymbol];
}

-(void)sendHandler
{
    [FSHUD showHUDin:self.view title:NSLocalizedStringFromTable(@"搜尋中", @"Warrnat", nil)];
    [dataModel.warrant sendIdentSymbol:self.targetIdentCodeSymbol function:3 fullName:targetStockName targetPrice:snapShot.currentPrice];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WarrantObject *warrantObj = [warrantArray objectAtIndex:indexPath.row];
    objNum = (int)indexPath.row;
    if (warrantObj) {
        self.firstFlag = YES;
        NewSymbolObject * symbolObj = [[NewSymbolObject alloc] init];
        symbolObj.identCode = [warrantObj->identCodeSymbol substringToIndex:2];
        symbolObj.symbol = [warrantObj->identCodeSymbol substringFromIndex:3];
        symbolObj.fullName = warrantObj->warrantSymbol;
        [dataModel.portfolioData addWatchListItemNewSymbolObjArray:@[symbolObj]];
        comparedSymbol = warrantObj->identCodeSymbol;
    }
}

-(void)pushHandler
{
    //WarrantObject *warrantObj = [warrantArray objectAtIndex:objNum];
    self.firstFlag = NO;
    [self.dataModel.portfolioData addWatchListItemByIdentSymbolArray:@[self.targetIdentCodeSymbol]];
    [self.dataModel.portfolioData addWatchListItemByIdentSymbolArray:@[comparedSymbol]];
    PortfolioItem *portfolio =[self.dataModel.portfolioData findItemByIdentCodeSymbol:self.targetIdentCodeSymbol];
    
    PortfolioItem *comparedPortfolio =[self.dataModel.portfolioData findItemByIdentCodeSymbol:comparedSymbol];
    
    FSInstantInfoWatchedPortfolio * watchPortfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
    watchPortfolio.portfolioItem = portfolio;
    watchPortfolio.comparedPortfolioItem = comparedPortfolio;
    WarrantMainViewController *warrantMainViewController = [[WarrantMainViewController alloc] init];
    [self.navigationController pushViewController:warrantMainViewController animated:NO];
}


- (void)notifyDataArrive:(NSObject <TickDataSourceProtocol> *)dataSource {
    [self updateSnapshot];
}



- (void)notifyData {
    warrantArray = [dataModel.warrant getWarrantData:formula];
    [self.mainTableView reloadAllData];
    [FSHUD hideHUDFor:self.view];
    
}


- (double)getTAValueFromFieldMaskArray:(NSArray*)fmArray FieldID:(int)fID
{
	double value = 0;
	for(FieldMaskParam *fmParam in fmArray)
	{
		if(fmParam->fieldID == fID)
		{
			value = fmParam->taValue * pow(1000,fmParam->taValueUnit);
		}
	}
	return value;
}

- (UInt16)getDataFromFieldMaskArray:(NSArray*)fmArray FieldID:(int)fID
{
	UInt16 value = 0;
	for(FieldMaskParam *fmParam in fmArray)
	{
		if(fmParam->fieldID == fID)
		{
			value = fmParam->shortData;
		}
	}
	return value;
}


- (void)updateSnapshot {
	snapShot = [dataModel.portfolioTickBank getSnapshotFromIdentCodeSymbol:self.targetIdentCodeSymbol];
    
	if (snapShot) {
        
        self.openPriceLabel.text = [CodingUtil ConvertDoubleValueToString:snapShot.currentPrice];
        self.priceChangeLabel.text = [CodingUtil ConvertDoubleValueToString:snapShot.currentPrice - snapShot.referencePrice];
        self.stockVolumeLabel.text = [CodingUtil ConvertDoubleValueToString:snapShot.volume];;
        
		if (snapShot.currentPrice > snapShot.referencePrice) {
			self.openPriceLabel.textColor = [StockConstant PriceUpColor];
			self.priceChangeLabel.textColor = [StockConstant PriceUpColor];
		} else if(snapShot.currentPrice < snapShot.referencePrice) {
			self.openPriceLabel.textColor = [StockConstant PriceDownColor];
			self.priceChangeLabel.textColor = [StockConstant PriceDownColor];
		} else {
			self.openPriceLabel.textColor = [UIColor blueColor];
			self.priceChangeLabel.textColor = [UIColor blueColor];
		}
	}
	
}




- (NSArray *)columnsInFixedTableView {
    return @[@"權證"];
}

- (NSArray *)columnsInMainTableView {
   return @[@"成交價",
            @"總量",
            @"履約價",
            @"溢價比",
            @"行使\n比例",
            @"槓桿\n倍數",
            @"歷史\n波動",
            @"隱含\n波動",
            @"燈號",
            @"類型",
            @"履約\n方式",
            @"到期日"];
}

#pragma mark -------------------- Table 資料欄位 --------------------

- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WarrantObject *warrantObj = [warrantArray objectAtIndex:indexPath.row];
    if (columnIndex == 0) {
        label.textColor = [UIColor blueColor];
        label.textAlignment = NSTextAlignmentLeft;
        label.text = warrantObj->warrantSymbol;
    }
}


- (void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (columnIndex > 13) return;
    
    // default value
    label.textColor = [UIColor blueColor];
    label.text = @"----";
    
    double taValue;
    //SecurityQueryParam *sqParam = [dataModel.warrant getAllocDataByRow:indexPath.row];
    WarrantObject *warrantObj = [warrantArray objectAtIndex:indexPath.row];
    // 成交價
    if (columnIndex == 0) {
        
        //成交價:2  參考價:3
        label.textAlignment = NSTextAlignmentCenter;
        double refValue = warrantObj->reference;
        taValue = warrantObj->price;
        
        if (taValue != 0) {
            if (taValue > refValue) {
                label.textColor = [StockConstant PriceUpColor];
            } else if (taValue < refValue) {
                label.textColor = [StockConstant PriceDownColor];
            }
            label.text = [NSString stringWithFormat:@"%.2f", taValue];
        } else {
            label.textColor = [UIColor blackColor];
            label.text = @"----";
        }
    
    }
    
    // 總量
    if (columnIndex == 1) {
        taValue = warrantObj->volume;
        label.text = [CodingUtil ConvertDoubleValueToString:taValue];
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:137.0f/255.0f alpha:1.0];
    }

    // 履約價
    if (columnIndex == 2) {
        taValue = warrantObj->exercisePrice;
        label.text = [CodingUtil ConvertDoubleAndZeroValueToString:taValue];
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:137.0f/255.0f alpha:1.0];
    }

    // 溢價比
    if (columnIndex == 3) {
        taValue = warrantObj->premiumRatio;
        if(taValue < 0.00 || taValue == -0.00){
            label.text = @"----";
        }else{
            label.text = [NSString stringWithFormat:@"%.2f", taValue];
        }
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:137.0f/255.0f alpha:1.0];
        
    }

    // 行使比例
    if (columnIndex == 4) {
        taValue = warrantObj->proportion;
        NSString *valString;
        if (taValue) {
            valString = [NSString stringWithFormat:@"%.3lf", taValue];//[NSString stringWithFormat:taValue<1 ? taValue<0.1 ? taValue<0.01 ? @"%.3lf" : @"%.2lf" : @"%.1lf" : @"%.0lf",taValue];
            label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:137.0f/255.0f alpha:1.0];
        } else {
            valString = @"---";
        }
        
        label.text = valString;
    }

    // 槓桿倍數
    if (columnIndex == 5) {
        taValue = warrantObj->gearingRatio;
        label.text = [NSString stringWithFormat:@"%.2f", taValue];//[CodingUtil ConvertDoubleAndZeroValueToString:taValue];
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:137.0f/255.0f alpha:1.0];
    }
    
    // 歷史波動
    if (columnIndex == 6) {
        taValue = warrantObj->HV * 100;
        label.text = [NSString stringWithFormat:@"%.1f", taValue];
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:137.0f/255.0f alpha:1.0];
    }

    // 隱含波動
    if (columnIndex == 7) {
        taValue = warrantObj->IV * 100;
        label.text = [NSString stringWithFormat:@"%.1f", taValue];
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:137.0f/255.0f alpha:1.0];
    }
    
    // 燈號
    if (columnIndex == 8) {
        taValue = warrantObj->light;
        label.text = @"●";
        
        if (taValue < 0.1) {
            label.textColor = [UIColor greenColor];
        } else if (taValue <= 0.3) {
            label.textColor = [UIColor yellowColor];
        } else if (taValue > 0.3) {
            label.textColor = [UIColor redColor];
        }
    }

    // 類型
    if (columnIndex == 9) {
        label.text = warrantObj->type;
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:137.0f/255.0f alpha:1.0];
    }

    // 履約方式
    if (columnIndex == 10) {
        label.text = warrantObj->method;
        label.textColor = [UIColor colorWithRed:127.0f/255.0f green:15.0f/255.0f blue:137.0f/255.0f alpha:1.0];
            
    }

    // 到期日
    if (columnIndex == 11) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy/MM/dd"];
        label.text = [formatter stringFromDate:[[NSNumber numberWithUnsignedInt:warrantObj->date] uint16ToDate]];
        label.textColor = [UIColor blueColor];
        label.font = [UIFont systemFontOfSize:14.0f];
    }
    

}

// 共有N列
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [warrantArray count];
} 

// 一個section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 33;
}

@end
