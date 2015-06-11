//
//  MacroeconomicDrawViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/7/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "MacroeconomicDrawViewController.h"
#import "MacroeconomicDrawTableViewCell.h"
#import "FSUIButton.h"
#import "RadioTableViewCell.h"
#import "MacroeconomicIndexDrawView.h"
#import "ChooseReferenceViewController.h"
#import "ChangeStockViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "HistoricDataTypes.h"
#import "UIViewController+CustomNavigationBar.h"

@interface MacroeconomicDrawViewController ()
{
    MacroeconomicIndexDrawView *drawView;
    NSMutableArray *titleArray;
    UIView *topView;
    UITableView *mainTableView;
    UIView *headerView;
    UILabel *dateTitleLabel;
    UILabel *valueTitleLabel;
    UILabel *indexLabel;
    FSUIButton *changeButton;
    FSUIButton *changePrecentButton;
    FSUIButton *indexButton;
    FSUIButton *chartTypeButton;
    NSMutableArray *idArray;
    NSMutableArray *nameArray;
    int nameIndex;
    NSString *indexID;
    int row;
    
    NSString *tagName;
    NSMutableDictionary *secondDict;
    NSMutableArray *firstDate;
    NSMutableArray *firstValue;
    NSMutableArray *secondDate;
    NSMutableArray *secondValue;
    
    UITableView *indexTableView;
    UIActionSheet *indexActionSheet;
    
    UIActionSheet *changeActionSheet;
    UIActionSheet *chartTypeActionSheet;
    BOOL btnFlag;
    UITableView *changeTableView;
    int changeNum;
    int changePrecentNum;
    
    int chartTypeNum;
    int secondChartTypeNum;
    UITableView *chartTypeTableView;

    UIView *rightView;
    UILabel *valueLabel1;
    UILabel *valueLabel2;
    UILabel *valueLabel3;
    UILabel *valueLabel4;
    UILabel *valueLabel5;
    UILabel *valueLabel6;
    UILabel *valueLabel7;
    UILabel *valueLabel8;
    UILabel *valueLabel9;
    
    UIView *leftView;
    UILabel *value2Label1;
    UILabel *value2Label2;
    UILabel *value2Label3;
    UILabel *value2Label4;
    UILabel *value2Label5;
    UILabel *value2Label6;
    UILabel *value2Label7;
    UILabel *value2Label8;
    UILabel *value2Label9;
    
    UIView *bottomView;
    
    FSUIButton *twoChartButton;
    FSUIButton *selectButton;
    UILabel *selectLabel;
    UITableView *selectTableView;
    UIActionSheet *selectActionSheet;
    NSXMLParser *firstParser;
    NSXMLParser *secondParser;
    FSUIButton *secondChartTypeButton;
    UITableView *secondChartTypeTableView;
    UIActionSheet *secondChartTypeActionSheet;
    
    FSInstantInfoWatchedPortfolio *portfolio;
    PortfolioTick *tickBank;
    FSDataModelProc *dataModel;
    HistoricDataAgent *historicData;
    UILabel *firstDataLabel;
    UILabel *secondDataLabel;
    NSString *value;
    NSString *date;
}
@end

@implementation MacroeconomicDrawViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

-(id)initWithIndexID:(NSString *)IndexID ID:(NSMutableArray *)IDArray Name:(NSMutableArray *)NameArray Index:(int)NameIndex IndexRow:(int)Row Title:(NSMutableArray *)TitleArray
{
    self = [super init];
    if(self){
        nameArray = NameArray;
        indexID = IndexID;
        nameIndex = NameIndex;
        row = Row;
        idArray = IDArray;
        titleArray = TitleArray;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Macroeconomics Indicator";
    [self setUpImageBackButton];
    [self initArray];
    [self sendXML];
    [self initHeaderView];
	[self initTopView];
    [self initBottomView];
    [self initLeftView];
    [self processLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(drawView.secondFlag){
        _vertical.hidden = YES;
        firstDataLabel.hidden = YES;
        secondDataLabel.hidden = YES;
        //[selectButton setTitle:[[nameArray objectAtIndex:_secondNameIndex]objectAtIndex:_secondRow] forState:UIControlStateNormal];
        selectLabel.text = [[nameArray objectAtIndex:_secondNameIndex]objectAtIndex:_secondRow];
        [self sendSecondXML];
    }
    if(_portfolioFlag){
        portfolio = [FSInstantInfoWatchedPortfolio sharedFSInstantInfoWatchedPortfolio];
        if(![[portfolio.comparedPortfolioItem getIdentCodeSymbol] isEqual:nil]){
            dataModel = [FSDataModelProc sharedInstance];
            tickBank = dataModel.historicTickBank;
            [tickBank watchTarget:self ForEquity:[portfolio.comparedPortfolioItem getIdentCodeSymbol] tickType:'M'];
        }
        _portfolioFlag = NO;
    }
}

-(void)notifyDataArrive:(NSObject<HistoricTickDataSourceProtocol> *)dataSource{
    historicData = [[HistoricDataAgent alloc] init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM";
    char * ident = malloc(2 * sizeof(UInt8));
    ident[0]=[[dataSource getIdenCodeSymbol] characterAtIndex:0];
    ident[1]=[[dataSource getIdenCodeSymbol] characterAtIndex:1];
    NSString *symbol = [[dataSource getIdenCodeSymbol]substringFromIndex:3];
    PortfolioItem *item = [dataModel.portfolioData findInPortfolio:ident Symbol:symbol];
    [historicData updateData:dataSource forPeriod:AnalysisPeriodMonth portfolioItem:item];
    //[selectButton setTitle:symbol forState:UIControlStateNormal];
    selectLabel.text = symbol;
    BOOL YESNO = NO;
    if([dataSource isLatestData:'M'])
    {
        YESNO = YES;
    }
    
    if(YESNO){
        [secondDate removeAllObjects];
        [secondValue removeAllObjects];
        [secondDict removeAllObjects];
        DecompressedHistoricData *hist;
        int countNum;
        if([historicData.dataArray count]<60){
            countNum = (int)[historicData.dataArray count];
        }else{
            countNum = 60;
        }
        for(NSInteger i=[historicData.dataArray count]-1; countNum >=0; i--){
            hist = [historicData copyHistoricTick:'M' sequenceNo:(int)i];
            
            [secondDate addObject:[formatter stringFromDate:[[NSNumber numberWithUnsignedInt:hist.date] uint16ToDate]]];
            [secondValue addObject:[NSNumber numberWithDouble:hist.close]];
            [secondDict setObject:[NSNumber numberWithDouble:hist.close] forKey:[formatter stringFromDate:[[NSNumber numberWithUnsignedInt:hist.date] uint16ToDate]]];
            countNum --;
        }
        drawView.secondFlag = YES;
        drawView.secondValueArray = secondValue;
        drawView.date2Array = secondDate;
        [self setValue2Label];
        leftView.hidden = NO;
        [self reload2Draw];
        [tickBank stopWatch:self ForEquity:[dataSource getIdenCodeSymbol]];
    }
}


-(void)initArray
{
    firstDate = [[NSMutableArray alloc] init];
    firstValue = [[NSMutableArray alloc] init];
    secondDate = [[NSMutableArray alloc] init];
    secondValue = [[NSMutableArray alloc] init];
    secondDict = [[NSMutableDictionary alloc] init];
}

-(void)sendXML
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/econ.cgi?cmd=historical_by_count&index_id=%@&count=48",[FSFonestock sharedInstance].queryServerURL, indexID]];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    firstParser = [[NSXMLParser alloc] initWithData:data];
    [firstParser setDelegate:self];
    [firstParser parse];
}

-(void)sendSecondXML
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/query/econ.cgi?cmd=historical_by_count&index_id=%@&count=48",[FSFonestock sharedInstance].queryServerURL, [[idArray objectAtIndex:_secondNameIndex]objectAtIndex:_secondRow]]];
    NSData *data = [[NSData alloc] initWithContentsOfURL:url];
    secondParser = [[NSXMLParser alloc] initWithData:data];
    [secondParser setDelegate:self];
    [secondParser parse];
}

-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    if([parser isEqual:firstParser]){
        [firstDate removeAllObjects];
        [firstValue removeAllObjects];
    }else{
        [secondDate removeAllObjects];
        [secondValue removeAllObjects];
        [secondDict removeAllObjects];
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    tagName = elementName;
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    if(![string isEqualToString:@"\n"]){
        if([tagName isEqualToString:@"date"]){
            NSString *dateStr = [string substringToIndex:7];
            if([parser isEqual:firstParser]){
                [firstDate addObject:dateStr];
            }else{
                [secondDate addObject:dateStr];
                date = dateStr;
            }
        }
        if([tagName isEqualToString:@"value"]){
            if([parser isEqual:firstParser]){
                [firstValue addObject:string];
            }else{
                [secondValue addObject:string];
                value = string;
            }
        }
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if([parser isEqual:secondParser]){
        if(!([date isEqualToString:@""] || [value isEqualToString:@""])){
            if([@"data" isEqualToString:elementName]){
                [secondDict setObject:value forKey:date];
                value = @"";
                date = @"";
            }
        }
    }
}

-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    if([parser isEqual:secondParser]){
        drawView.secondFlag = YES;
        drawView.secondValueArray = secondValue;
        drawView.date2Array = secondDate;
        [self setValue2Label];
        leftView.hidden = NO;
        [self reload2Draw];
    }
}

-(void)initHeaderView
{
    changeNum = 0;
    changePrecentNum = 0;
    chartTypeNum = 0;
    secondChartTypeNum = 0;
    headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:26/255.0 green:117/255.0 blue:174/255.0 alpha:1];
    
    dateTitleLabel = [[UILabel alloc] init];
    dateTitleLabel.text = NSLocalizedStringFromTable(@"日期", @"Macroeconomic", nil);
    dateTitleLabel.textAlignment = NSTextAlignmentCenter;
    dateTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:dateTitleLabel];
    
    valueTitleLabel = [[UILabel alloc] init];
    valueTitleLabel.text = NSLocalizedStringFromTable(@"數值", @"Macroeconomic", nil);
    valueTitleLabel.textAlignment = NSTextAlignmentCenter;
    valueTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:valueTitleLabel];
    
    changeButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    [changeButton setTitle:NSLocalizedStringFromTable(@"增減", @"Macroeconomic", nil) forState:UIControlStateNormal];
    changeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [changeButton addTarget:self action:@selector(changeButton:) forControlEvents:UIControlEventTouchUpInside];
    changeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:changeButton];
    
    changePrecentButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    [changePrecentButton setTitle:NSLocalizedStringFromTable(@"增減%", @"Macroeconomic", nil) forState:UIControlStateNormal];
    changePrecentButton.titleLabel.font = [UIFont boldSystemFontOfSize:13.0f];
    [changePrecentButton addTarget:self action:@selector(changeButton:) forControlEvents:UIControlEventTouchUpInside];
    changePrecentButton.translatesAutoresizingMaskIntoConstraints = NO;
    [headerView addSubview:changePrecentButton];
    
    [self processLayout_HeaderView];
}

-(void)initTopView
{
    topView = [[UIView alloc] init];
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topView];
    
    indexButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    indexButton.titleLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    //[indexButton setTitle:[[nameArray objectAtIndex:nameIndex]objectAtIndex:row] forState:UIControlStateNormal];
    [indexButton addTarget:self action:@selector(indexHandler:) forControlEvents:UIControlEventTouchUpInside];
    indexButton.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:indexButton];
    
    indexLabel = [[UILabel alloc] init];
    indexLabel.textColor = [UIColor redColor];
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.lineBreakMode = NSLineBreakByWordWrapping;
    indexLabel.numberOfLines = 2;
    indexLabel.text = [[nameArray objectAtIndex:nameIndex]objectAtIndex:row];
    indexLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:indexLabel];
    
    mainTableView = [[UITableView alloc] init];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.scrollEnabled = NO;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:mainTableView];
    
    chartTypeButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    [chartTypeButton setTitle:NSLocalizedStringFromTable(@"折線圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
    [chartTypeButton addTarget:self action:@selector(chartTypeHandler:) forControlEvents:UIControlEventTouchUpInside];
    chartTypeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:chartTypeButton];
    
    twoChartButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalBlue];
    twoChartButton.translatesAutoresizingMaskIntoConstraints = NO;
    [twoChartButton setImage:[UIImage imageNamed:@"tachart_doubleline"] forState:UIControlStateNormal];
    [twoChartButton addTarget:self action:@selector(twoChartHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:twoChartButton];
    
    selectButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    selectButton.translatesAutoresizingMaskIntoConstraints = NO;
    selectButton.titleLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    selectButton.hidden = YES;
    //[selectButton setTitle:@"Select" forState:UIControlStateNormal];
    [selectButton addTarget:self action:@selector(selectHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectButton];
    
    selectLabel = [[UILabel alloc] init];
    selectLabel.textAlignment = NSTextAlignmentCenter;
    selectLabel.font = [UIFont boldSystemFontOfSize:11.0f];
    selectLabel.lineBreakMode = NSLineBreakByWordWrapping;
    selectLabel.textColor = [UIColor redColor];
    selectLabel.hidden = YES;
    selectLabel.text = NSLocalizedStringFromTable(@"請選擇", @"Macroeconomic", nil);
    selectLabel.numberOfLines = 2;
    selectLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:selectLabel];
    
    secondChartTypeButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeBlueGreenDetailButton];
    secondChartTypeButton.translatesAutoresizingMaskIntoConstraints = NO;
    secondChartTypeButton.hidden = YES;
    [secondChartTypeButton setTitle:NSLocalizedStringFromTable(@"折線圖-折線圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
    [secondChartTypeButton addTarget:self action:@selector(secondChartTypeHandler:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:secondChartTypeButton];
}

-(void)initBottomView
{
    UIFont *valueFont = [UIFont boldSystemFontOfSize:9.0f];
    firstDataLabel = [[UILabel alloc] init];
    firstDataLabel.translatesAutoresizingMaskIntoConstraints = NO;
    firstDataLabel.font = valueFont;
    firstDataLabel.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    [self.view addSubview:firstDataLabel];

    
    secondDataLabel = [[UILabel alloc] init];
    secondDataLabel.translatesAutoresizingMaskIntoConstraints = NO;
    secondDataLabel.font = valueFont;
    secondDataLabel.textColor = [UIColor redColor];
    [self.view addSubview:secondDataLabel];
    
    drawView = [[MacroeconomicIndexDrawView alloc] initWithController:self];
    drawView.layer.borderColor = [UIColor blackColor].CGColor;
    drawView.layer.borderWidth = 1.0f;
    drawView.backgroundColor = [UIColor clearColor];
    drawView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addSubview:drawView];
    
    drawView.firstValueArray = firstValue;
    drawView.date1Array = firstDate;
    
    rightView = [[UIView alloc] init];
    rightView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:rightView];
    
    UIFont *font = [UIFont systemFontOfSize:10.0f];
    
    valueLabel1 = [[UILabel alloc] init];
    valueLabel1.font = font;
    valueLabel1.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    valueLabel2 = [[UILabel alloc] init];
    valueLabel2.font = font;
    valueLabel2.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    valueLabel3 = [[UILabel alloc] init];
    valueLabel3.font = font;
    valueLabel3.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    valueLabel4 = [[UILabel alloc] init];
    valueLabel4.font = font;
    valueLabel4.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    valueLabel5 = [[UILabel alloc] init];
    valueLabel5.font = font;
    valueLabel5.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    valueLabel6 = [[UILabel alloc] init];
    valueLabel6.font = font;
    valueLabel6.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    valueLabel7 = [[UILabel alloc] init];
    valueLabel7.font = font;
    valueLabel7.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    valueLabel8 = [[UILabel alloc] init];
    valueLabel8.font = font;
    valueLabel8.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    valueLabel9 = [[UILabel alloc] init];
    valueLabel9.font = font;
    valueLabel9.textColor = [UIColor colorWithHue:120.0/360.0 saturation:1.0 brightness:0.7 alpha:1.0];
    
    [rightView addSubview:valueLabel1];
    [rightView addSubview:valueLabel2];
    [rightView addSubview:valueLabel3];
    [rightView addSubview:valueLabel4];
    [rightView addSubview:valueLabel5];
    [rightView addSubview:valueLabel6];
    [rightView addSubview:valueLabel7];
    [rightView addSubview:valueLabel8];
    [rightView addSubview:valueLabel9];
    
    bottomView = [[UIView alloc] init];
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bottomView];
    
    leftView = [[UIView alloc] init];
    leftView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:leftView];

    [self setValueLabel];
    [drawView setNeedsDisplay];
}

-(void)setDateLabel
{
    float dateLabelCenter = bottomView.frame.size.width / 36.0f;
    int widthNum=0;
    int limit;
    if([firstDate count] >=35){
        limit = 35;
    }else{
        limit = (int)[firstDate count];
    }
    for(int i=limit; i>=0; i--){
        if([[[firstDate objectAtIndex:i] substringFromIndex:5] isEqualToString:@"01"]){
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(dateLabelCenter*widthNum-dateLabelCenter/4, 3, 30, bottomView.frame.size.height-5)];
            UIFont *font = [UIFont boldSystemFontOfSize:10.0f];
            label.font = font;
            label.text = [[firstDate objectAtIndex:i] substringWithRange:NSMakeRange(2, 2)];
            [bottomView addSubview:label];
        }
        widthNum ++;
    }
}

-(void)setValueLabel
{
    double maxValue = -MAXFLOAT;
    double minValue = MAXFLOAT;
    for(int i=0; i<=35 && i<[firstValue count]; i++){
        maxValue = MAX([(NSNumber *)[firstValue objectAtIndex:i]doubleValue], maxValue);
        minValue = MIN([(NSNumber *)[firstValue objectAtIndex:i]doubleValue], minValue);
    }
    double avgValue = (maxValue - minValue) / 8.0f;
    
    if(maxValue -minValue==0){
        valueLabel1.text = @"";
        valueLabel2.text = @"";
        valueLabel3.text = @"";
        valueLabel4.text = @"";
        valueLabel5.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*4];
        valueLabel6.text = @"";
        valueLabel7.text = @"";
        valueLabel8.text = @"";
        valueLabel9.text = @"";
    }else{
        valueLabel1.text = [CodingUtil getMacroeconomicValue:maxValue];
        valueLabel2.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*1];
        valueLabel3.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*2];
        valueLabel4.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*3];
        valueLabel5.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*4];
        valueLabel6.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*5];
        valueLabel7.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*6];
        valueLabel8.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*7];
        valueLabel9.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*8];
    }
    
}

-(void)setValue2Label
{
    int sameCount = 0;
    int yearDate1 =  [(NSNumber *)[[firstDate objectAtIndex:0] substringToIndex:4]intValue];
    int yearDate2 =  [(NSNumber *)[[secondDate objectAtIndex:0] substringToIndex:4]intValue];
    int monthDate1 = [(NSNumber *)[[firstDate objectAtIndex:0] substringWithRange:NSMakeRange(5, 2)]intValue];
    int monthDate2 = [(NSNumber *)[[secondDate objectAtIndex:0] substringWithRange:NSMakeRange(5, 2)]intValue];
    
    if(yearDate2 > yearDate1 || (yearDate2 == yearDate1 && monthDate2 > monthDate1)){
        for(int i = 0; i<[secondDate count] && i<=35; i++){
            if([[firstDate objectAtIndex:0] isEqualToString:[secondDate objectAtIndex:i]]){
                sameCount = i;
            }
        }
    }else{
        for(int i = 0; i<=35 && i<[firstValue count]; i++){
            if([[secondDate objectAtIndex:0] isEqualToString:[firstDate objectAtIndex:i]]){
                sameCount = i;
            }
        }
    }
    
    double maxValue = -MAXFLOAT;
    double minValue = MAXFLOAT;
    for(int i=sameCount; i<=35 + sameCount && i<[secondValue count]; i++){
        maxValue = MAX([(NSNumber *)[secondValue objectAtIndex:i]doubleValue], maxValue);
        minValue = MIN([(NSNumber *)[secondValue objectAtIndex:i]doubleValue], minValue);
    }
    
    double avgValue = (maxValue - minValue) / 8.0f;
    
    if(maxValue -minValue==0){
        value2Label1.text = @"";
        value2Label2.text = @"";
        value2Label3.text = @"";
        value2Label4.text = @"";
        value2Label5.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*4];;
        value2Label6.text = @"";
        value2Label7.text = @"";
        value2Label8.text = @"";
        value2Label9.text = @"";
    }else{
        value2Label1.text = [CodingUtil getMacroeconomicValue:maxValue];
        value2Label2.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*1];
        value2Label3.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*2];
        value2Label4.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*3];
        value2Label5.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*4];
        value2Label6.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*5];
        value2Label7.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*6];
        value2Label8.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*7];
        value2Label9.text = [CodingUtil getMacroeconomicValue:maxValue-avgValue*8];
    }
    
}

-(void)initLeftView
{
    UIFont *font = [UIFont systemFontOfSize:10.0f];
    value2Label1 = [[UILabel alloc] init];
    value2Label1.textAlignment = NSTextAlignmentRight;
    value2Label1.font = font;
    value2Label1.textColor = [UIColor redColor];
    value2Label2 = [[UILabel alloc] init];
    value2Label2.textAlignment = NSTextAlignmentRight;
    value2Label2.font = font;
    value2Label2.textColor = [UIColor redColor];
    value2Label3 = [[UILabel alloc] init];
    value2Label3.textAlignment = NSTextAlignmentRight;
    value2Label3.font = font;
    value2Label3.textColor = [UIColor redColor];
    value2Label4 = [[UILabel alloc] init];
    value2Label4.textAlignment = NSTextAlignmentRight;
    value2Label4.font = font;
    value2Label4.textColor = [UIColor redColor];
    value2Label5 = [[UILabel alloc] init];
    value2Label5.textAlignment = NSTextAlignmentRight;
    value2Label5.font = font;
    value2Label5.textColor = [UIColor redColor];
    value2Label6 = [[UILabel alloc] init];
    value2Label6.textAlignment = NSTextAlignmentRight;
    value2Label6.font = font;
    value2Label6.textColor = [UIColor redColor];
    value2Label7 = [[UILabel alloc] init];
    value2Label7.textAlignment = NSTextAlignmentRight;
    value2Label7.font = font;
    value2Label7.textColor = [UIColor redColor];
    value2Label8 = [[UILabel alloc] init];
    value2Label8.textAlignment = NSTextAlignmentRight;
    value2Label8.font = font;
    value2Label8.textColor = [UIColor redColor];
    value2Label9 = [[UILabel alloc] init];
    value2Label9.textAlignment = NSTextAlignmentRight;
    value2Label9.font = font;
    value2Label9.textColor = [UIColor redColor];
    
    [leftView addSubview:value2Label1];
    [leftView addSubview:value2Label2];
    [leftView addSubview:value2Label3];
    [leftView addSubview:value2Label4];
    [leftView addSubview:value2Label5];
    [leftView addSubview:value2Label6];
    [leftView addSubview:value2Label7];
    [leftView addSubview:value2Label8];
    [leftView addSubview:value2Label9];
}

-(void)viewDidLayoutSubviews
{
    float upperLabelCenter = rightView.frame.size.height / 8.0f;
    
    [valueLabel1 setFrame:CGRectMake(3, 0-upperLabelCenter/4, rightView.frame.size.width-5, upperLabelCenter/2+3)];
    [valueLabel2 setFrame:CGRectMake(3, upperLabelCenter*1-upperLabelCenter/4, rightView.frame.size.width-5, upperLabelCenter/2+3)];
    [valueLabel3 setFrame:CGRectMake(3, upperLabelCenter*2-upperLabelCenter/4, rightView.frame.size.width-5, upperLabelCenter/2+3)];
    [valueLabel4 setFrame:CGRectMake(3, upperLabelCenter*3-upperLabelCenter/4, rightView.frame.size.width-5, upperLabelCenter/2+3)];
    [valueLabel5 setFrame:CGRectMake(3, upperLabelCenter*4-upperLabelCenter/4, rightView.frame.size.width-5, upperLabelCenter/2+3)];
    [valueLabel6 setFrame:CGRectMake(3, upperLabelCenter*5-upperLabelCenter/4, rightView.frame.size.width-5, upperLabelCenter/2+3)];
    [valueLabel7 setFrame:CGRectMake(3, upperLabelCenter*6-upperLabelCenter/4, rightView.frame.size.width-5, upperLabelCenter/2+3)];
    [valueLabel8 setFrame:CGRectMake(3, upperLabelCenter*7-upperLabelCenter/4, rightView.frame.size.width-5, upperLabelCenter/2+3)];
    [valueLabel9 setFrame:CGRectMake(3, upperLabelCenter*8-upperLabelCenter/4, rightView.frame.size.width-5, upperLabelCenter/2+3)];
    
    [value2Label1 setFrame:CGRectMake(1, 0-upperLabelCenter/4, leftView.frame.size.width-5, upperLabelCenter/2+3)];
    [value2Label2 setFrame:CGRectMake(1, upperLabelCenter*1-upperLabelCenter/4, leftView.frame.size.width-5, upperLabelCenter/2+3)];
    [value2Label3 setFrame:CGRectMake(1, upperLabelCenter*2-upperLabelCenter/4, leftView.frame.size.width-5, upperLabelCenter/2+3)];
    [value2Label4 setFrame:CGRectMake(1, upperLabelCenter*3-upperLabelCenter/4, leftView.frame.size.width-5, upperLabelCenter/2+3)];
    [value2Label5 setFrame:CGRectMake(1, upperLabelCenter*4-upperLabelCenter/4, leftView.frame.size.width-5, upperLabelCenter/2+3)];
    [value2Label6 setFrame:CGRectMake(1, upperLabelCenter*5-upperLabelCenter/4, leftView.frame.size.width-5, upperLabelCenter/2+3)];
    [value2Label7 setFrame:CGRectMake(1, upperLabelCenter*6-upperLabelCenter/4, leftView.frame.size.width-5, upperLabelCenter/2+3)];
    [value2Label8 setFrame:CGRectMake(1, upperLabelCenter*7-upperLabelCenter/4, leftView.frame.size.width-5, upperLabelCenter/2+3)];
    [value2Label9 setFrame:CGRectMake(1, upperLabelCenter*8-upperLabelCenter/4, leftView.frame.size.width-5, upperLabelCenter/2+3)];
    
    [self setDateLabel];
    [self initVertical];
}

-(void)processLayout_HeaderView
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(dateTitleLabel, valueTitleLabel, changeButton, changePrecentButton);
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[dateTitleLabel(33)]" options:0 metrics:nil views:viewController]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[dateTitleLabel][valueTitleLabel(==dateTitleLabel)][changeButton(==dateTitleLabel)][changePrecentButton(==dateTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
}

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(topView, mainTableView, indexButton, drawView, chartTypeButton, rightView, bottomView, leftView, twoChartButton, selectButton, secondChartTypeButton, firstDataLabel, secondDataLabel, indexLabel, selectLabel);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftView(50)][drawView][rightView(50)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftView(50)][bottomView][rightView(50)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView(200)][chartTypeButton(44)][firstDataLabel(10)][drawView][bottomView(20)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView(200)][chartTypeButton(44)][firstDataLabel(10)][rightView][bottomView(20)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[topView(200)][chartTypeButton(44)][firstDataLabel(10)][leftView][bottomView(20)]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[topView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-50-[firstDataLabel(75)]-10-[secondDataLabel]" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[twoChartButton(50)][selectButton]-5-[chartTypeButton(150)]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewController]];
    
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[indexButton(44)][mainTableView]|" options:0 metrics:nil views:viewController]];
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewController]];
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indexButton]|" options:0 metrics:nil views:viewController]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:selectLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:selectButton attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:selectLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:selectButton attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:selectLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:selectButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:selectLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:selectButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:indexLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:indexButton attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:indexLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:indexButton attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:indexLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:indexButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:indexLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:indexButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:secondChartTypeButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:chartTypeButton attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:secondChartTypeButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:chartTypeButton attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:secondChartTypeButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:chartTypeButton attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:secondChartTypeButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:chartTypeButton attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    
}

-(void)initVertical
{
    if (!_vertical) {
        self.vertical = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 1, drawView.frame.size.height)];
        _vertical.layer.borderColor = [UIColor blueColor].CGColor;
        _vertical.layer.borderWidth = 0.5;
        [drawView addSubview:_vertical];
        _vertical.hidden = YES;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:mainTableView]){
        static NSString *CellIdentifier = @"MacroeconomicDrawCell";
        MacroeconomicDrawTableViewCell *cell = (MacroeconomicDrawTableViewCell *)[mainTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[MacroeconomicDrawTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.dateLabel.text = [firstDate objectAtIndex:indexPath.row];
        cell.valueLabel.text = [CodingUtil getMacroeconomicValue:[(NSNumber *)[firstValue objectAtIndex:indexPath.row]doubleValue]];
        
        if(changeNum == 0){
            cell.changeLabel.text = [CodingUtil getMacroeconomicValue:[(NSNumber *)[firstValue objectAtIndex:indexPath.row]doubleValue] - [(NSNumber *)[firstValue objectAtIndex:indexPath.row+1]doubleValue]];
        }else{
            cell.changeLabel.text = [CodingUtil getMacroeconomicValue:[(NSNumber *)[firstValue objectAtIndex:indexPath.row]doubleValue] - [(NSNumber *)[firstValue objectAtIndex:indexPath.row+12]doubleValue]];
        }
        if(changePrecentNum == 0){
            cell.changePrecentLabel.text = [NSString stringWithFormat:@"%.2f%%",([(NSNumber *)[firstValue objectAtIndex:indexPath.row]doubleValue] - [(NSNumber *)[firstValue objectAtIndex:indexPath.row+1]doubleValue])/[(NSNumber *)[firstValue objectAtIndex:indexPath.row+1]doubleValue]*100];
        }else{
            cell.changePrecentLabel.text = [NSString stringWithFormat:@"%.2f%%",([(NSNumber *)[firstValue objectAtIndex:indexPath.row]doubleValue] - [(NSNumber *)[firstValue objectAtIndex:indexPath.row+12]doubleValue])/[(NSNumber *)[firstValue objectAtIndex:indexPath.row+12]doubleValue]*100];
        }
        return cell;
    }else if([tableView isEqual:indexTableView]){
        static NSString *CellIdentifier = @"RadioTableViewCell";
        RadioTableViewCell *cell = (RadioTableViewCell *)[indexTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[RadioTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if(indexPath.row == row){
            cell.checkBtn.selected = YES;
        }
        if([[FSFonestock sharedInstance].appId isEqualToString:@"us"]){
            cell.textLabel.font = [UIFont boldSystemFontOfSize:9.0f];
        }else{
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        }
        
        cell.textLabel.text = [[nameArray objectAtIndex:nameIndex] objectAtIndex:indexPath.row];
       
        return cell;
    }else if([tableView isEqual:changeTableView]){
        static NSString *CellIdentifier = @"RadioTableViewCell";
        RadioTableViewCell *cell = (RadioTableViewCell *)[indexTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[RadioTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if(!btnFlag){
            if(indexPath.row == changeNum){
                cell.checkBtn.selected = YES;
            }
        }else{
            if(indexPath.row == changePrecentNum){
                cell.checkBtn.selected = YES;
            }
        }
        if(indexPath.row == 0){
            cell.textLabel.text = NSLocalizedStringFromTable(@"與前期比較", @"Macroeconomic", nil);
        }else{
            cell.textLabel.text = NSLocalizedStringFromTable(@"與去年同期比較", @"Macroeconomic", nil);
        }
        return cell;
    }else if([tableView isEqual:chartTypeTableView]){
        static NSString *CellIdentifier = @"RadioTableViewCell";
        RadioTableViewCell *cell = (RadioTableViewCell *)[indexTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[RadioTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if(indexPath.row == chartTypeNum){
            cell.checkBtn.selected = YES;
        }
        if(indexPath.row == 0){
            cell.textLabel.text = NSLocalizedStringFromTable(@"折線圖", @"Macroeconomic", nil);
        }else{
            cell.textLabel.text = NSLocalizedStringFromTable(@"長條圖", @"Macroeconomic", nil);
        }
        return cell;
    }else if([tableView isEqual:selectTableView]){
        static NSString *CellIdentifier = @"TableViewCell";
        FSUITableViewCell *cell = (FSUITableViewCell *)[indexTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[FSUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if(indexPath.row == 0){
            cell.textLabel.text = @"Individual Stock";
        }else{
            cell.textLabel.text = @"Macroeconomic Indicator";
        }
        return cell;
    }else{
        static NSString *CellIdentifier = @"RadioTableViewCell";
        RadioTableViewCell *cell = (RadioTableViewCell *)[indexTableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[RadioTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        if(indexPath.row == secondChartTypeNum){
            cell.checkBtn.selected = YES;
        }
        if(indexPath.row == 0){
            cell.textLabel.text = NSLocalizedStringFromTable(@"折線圖-折線圖", @"Macroeconomic", nil);
        }else if(indexPath.row == 1){
            cell.textLabel.text = NSLocalizedStringFromTable(@"折線圖-長條圖", @"Macroeconomic", nil);
        }else{
            cell.textLabel.text = NSLocalizedStringFromTable(@"長條圖-折線圖", @"Macroeconomic", nil);
        }
        return cell;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableView isEqual:mainTableView]){
        return 4;
    }else if([tableView isEqual:indexTableView]){
        return [[nameArray objectAtIndex:nameIndex] count];
    }else if([tableView isEqual:changeTableView]){
        return 2;
    }else if([tableView isEqual:chartTypeTableView]){
        return 2;
    }else if([tableView isEqual:selectTableView]){
        return 2;
    }else{
        return 3;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if([tableView isEqual:mainTableView]){
        return headerView;
    }else{
        return nil;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([tableView isEqual:mainTableView]){
        return 45.0f;
    }else{
        return 0;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:mainTableView]){
        return 25.0f;
    }else{
        return 44.0f;
    }
}

-(void)indexHandler:(FSUIButton *)sender
{
    if(![[FSFonestock sharedInstance] checkNeedShowAdvertise]){
        self.view.frame = CGRectMake(0, self.navigationController.topViewController.view.frame.origin.y, self.view.bounds.size.width, self.view.bounds.size.height-50);
    }
    NSString *title = NSLocalizedStringFromTable(@"Index", @"Macroeconomic", nil);
    title = [title stringByAppendingString:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"];
    indexActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Macroeconomic", nil)  destructiveButtonTitle:nil otherButtonTitles:nil];
    [indexActionSheet showInView:self.view.window.rootViewController.view];
    indexTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 45, indexActionSheet.frame.size.width-40, 300) style:UITableViewStylePlain];
    indexTableView.delegate = self;
    indexTableView.dataSource = self;
    indexTableView.bounces = NO;
    indexTableView.backgroundView = nil;
    
    [indexActionSheet addSubview:indexTableView];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableView isEqual:indexTableView]){
        indexID = [[idArray objectAtIndex:nameIndex] objectAtIndex:indexPath.row];
        [self sendXML];
        row = (int)indexPath.row;
        //[indexButton setTitle:[[nameArray objectAtIndex:nameIndex]objectAtIndex:row] forState:UIControlStateNormal];
        indexLabel.text = [[nameArray objectAtIndex:nameIndex]objectAtIndex:row];
        [indexActionSheet dismissWithClickedButtonIndex:0 animated:YES];
        drawView.firstValueArray = firstValue;
        drawView.date1Array = firstDate;
        firstDataLabel.hidden = YES;
        secondDataLabel.hidden = YES;
        _vertical.hidden = YES;
        [drawView setNeedsDisplay];
        [self setValueLabel];
        if(drawView.secondFlag){
            drawView.secondFlag = YES;
            drawView.secondValueArray = secondValue;
            drawView.date2Array = secondDate;
            [self setValue2Label];
            leftView.hidden = NO;
            [self reload2Draw];
        }
        
        for(UILabel *label in [bottomView subviews]){
            [label removeFromSuperview];
        }
        [self setDateLabel];
        [mainTableView reloadData];
    }else if([tableView isEqual:changeTableView]){
        if(!btnFlag){
            changeNum = (int)indexPath.row;
        }else{
            changePrecentNum = (int)indexPath.row;
        }
        [changeActionSheet dismissWithClickedButtonIndex:0 animated:YES];
        [mainTableView reloadData];
    }else if([tableView isEqual:chartTypeTableView]){
        chartTypeNum = (int)indexPath.row;
        [chartTypeActionSheet dismissWithClickedButtonIndex:0 animated:YES];
        
        if(indexPath.row == 0){
            [chartTypeButton setTitle:NSLocalizedStringFromTable(@"折線圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
            drawView.drawType = NO;
        }else{
            [chartTypeButton setTitle:NSLocalizedStringFromTable(@"長條圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
            drawView.drawType = YES;
        }
        [drawView setNeedsDisplay];
    }else if([tableView isEqual:selectTableView]){
        [selectActionSheet dismissWithClickedButtonIndex:0 animated:YES];
        if(indexPath.row ==0){
            [self.navigationController pushViewController:[[ChangeStockViewController alloc]initWithTarget:self] animated:NO];
        }else{
            [self.navigationController pushViewController:[[ChooseReferenceViewController alloc]initWithTitle:titleArray Name:nameArray Controller:self] animated:NO];
        }
    }else if([tableView isEqual:secondChartTypeTableView]){
        secondChartTypeNum = (int)indexPath.row;
        [secondChartTypeActionSheet dismissWithClickedButtonIndex:0 animated:YES];
        if(indexPath.row ==0){
            [secondChartTypeButton setTitle:NSLocalizedStringFromTable(@"折線圖-折線圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
            drawView.drawType = NO;
            drawView.draw2Type = NO;
        }else if(indexPath.row ==1){
            [secondChartTypeButton setTitle:NSLocalizedStringFromTable(@"折線圖-長條圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
            drawView.drawType = NO;
            drawView.draw2Type = YES;
        }else{
            [secondChartTypeButton setTitle:NSLocalizedStringFromTable(@"長條圖-折線圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
            drawView.drawType = YES;
            drawView.draw2Type = NO;
        }
        [drawView setNeedsDisplay];
    }
}

-(void)changeButton:(FSUIButton *)sender
{
    
    if([sender isEqual:changeButton]){
        btnFlag = NO;
    }else{
        btnFlag = YES;
    }
    
    NSString *title = NSLocalizedStringFromTable(@"增減", @"Macroeconomic", nil);
    title = [title stringByAppendingString:@"\n\n\n\n\n\n\n\n"];
    changeActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Macroeconomic", nil)  destructiveButtonTitle:nil otherButtonTitles:nil];
    [changeActionSheet showInView:self.view.window.rootViewController.view];
    changeTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 45, changeActionSheet.frame.size.width-40, 85) style:UITableViewStylePlain];
    changeTableView.delegate = self;
    changeTableView.dataSource = self;
    changeTableView.bounces = NO;
    changeTableView.backgroundView = nil;
    [changeActionSheet addSubview:changeTableView];
}

-(void)chartTypeHandler:(FSUIButton *)sneder
{
    NSString *title = NSLocalizedStringFromTable(@"圖表種類", @"Macroeconomic", nil);
    title = [title stringByAppendingString:@"\n\n\n\n\n\n\n\n"];
    chartTypeActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Macroeconomic", nil)  destructiveButtonTitle:nil otherButtonTitles:nil];
    [chartTypeActionSheet showInView:self.view.window.rootViewController.view];
    chartTypeTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 45, chartTypeActionSheet.frame.size.width-40, 85) style:UITableViewStylePlain];
    chartTypeTableView.delegate = self;
    chartTypeTableView.dataSource = self;
    chartTypeTableView.bounces = NO;
    chartTypeTableView.backgroundView = nil;
    [chartTypeActionSheet addSubview:chartTypeTableView];
}

-(void)twoChartHandler:(FSUIButton *)sender
{
    if(sender.selected){
        twoChartButton.selected = NO;
        selectButton.hidden = YES;
        selectLabel.hidden = YES;
        drawView.secondFlag = NO;
        //[selectButton setTitle:@"Select" forState:UIControlStateNormal];
        selectLabel.text = NSLocalizedStringFromTable(@"請選擇", @"Macroeconomic", nil);
        leftView.hidden = YES;
        secondChartTypeButton.hidden = YES;
        chartTypeButton.hidden = NO;
        _vertical.hidden = YES;
        firstDataLabel.hidden = YES;
        secondDataLabel.hidden = YES;
        [self reload1Draw];
    }else{
        twoChartButton.selected = YES;
        selectButton.hidden = NO;
        selectLabel.hidden = NO;
        secondChartTypeButton.hidden = NO;
        chartTypeButton.hidden = YES;
        _vertical.hidden = YES;
        firstDataLabel.hidden = YES;
        secondDataLabel.hidden = YES;
        
        [self reload2Draw];
    }
}

-(void)selectHandler:(FSUIButton *)sender
{
    NSString *title = NSLocalizedStringFromTable(@"Reference", @"Macroeconomic", @"Reference");
    title = [title stringByAppendingString:@"\n\n\n\n\n\n\n\n"];
    selectActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Macroeconomic", nil)  destructiveButtonTitle:nil otherButtonTitles:nil];
    [selectActionSheet showInView:self.view.window.rootViewController.view];
    selectTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 45, selectActionSheet.frame.size.width-40, 85) style:UITableViewStylePlain];
    selectTableView.delegate = self;
    selectTableView.dataSource = self;
    selectTableView.bounces = NO;
    selectTableView.backgroundView = nil;
    [selectActionSheet addSubview:selectTableView];
}

-(void)secondChartTypeHandler:(FSUIButton *)sender
{
    NSString *title = NSLocalizedStringFromTable(@"圖表種類", @"Macroeconomic", nil);
    title = [title stringByAppendingString:@"\n\n\n\n\n\n\n\n\n\n"];
    secondChartTypeActionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"Macroeconomic", nil)  destructiveButtonTitle:nil otherButtonTitles:nil];
    [secondChartTypeActionSheet showInView:self.view.window.rootViewController.view];
    secondChartTypeTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 45, secondChartTypeActionSheet.frame.size.width-40, 130) style:UITableViewStylePlain];
    secondChartTypeTableView.delegate = self;
    secondChartTypeTableView.dataSource = self;
    secondChartTypeTableView.bounces = NO;
    secondChartTypeTableView.backgroundView = nil;
    [secondChartTypeActionSheet addSubview:secondChartTypeTableView];
}

-(void)reload1Draw
{
    if(chartTypeNum == 0){
        [chartTypeButton setTitle:NSLocalizedStringFromTable(@"折線圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
        drawView.drawType = NO;
    }else{
        [chartTypeButton setTitle:NSLocalizedStringFromTable(@"長條圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
        drawView.drawType = YES;
    }
    [drawView setNeedsDisplay];
}

-(void)reload2Draw
{
    if(secondChartTypeNum == 0){
        [secondChartTypeButton setTitle:NSLocalizedStringFromTable(@"折線圖-折線圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
        drawView.drawType = NO;
        drawView.draw2Type = NO;
    }else if(secondChartTypeNum ==1){
        [secondChartTypeButton setTitle:NSLocalizedStringFromTable(@"折線圖-長條圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
        drawView.drawType = NO;
        drawView.draw2Type = YES;
    }else{
        [secondChartTypeButton setTitle:NSLocalizedStringFromTable(@"長條圖-折線圖", @"Macroeconomic", nil) forState:UIControlStateNormal];
        drawView.drawType = YES;
        drawView.draw2Type = NO;
    }
    [drawView setNeedsDisplay];
}

- (void)doTouchesWithPoint:(CGPoint)point number:(int)num
{
    if(point.x > 0 && point.x < drawView.frame.size.width){
        _vertical.hidden = NO;
        [_vertical setFrame:CGRectMake(point.x, _vertical.frame.origin.y, _vertical.frame.size.width, _vertical.frame.size.height)];
        firstDataLabel.hidden = NO;
        firstDataLabel.text = [NSString stringWithFormat:@"%@:%@", [firstDate objectAtIndex:num], [CodingUtil getMacroeconomicValue:[(NSNumber *)[firstValue objectAtIndex:num]doubleValue]]];
        if(drawView.secondFlag){
            if([secondDict objectForKey:[firstDate objectAtIndex:num]]){
            secondDataLabel.hidden = NO;
            secondDataLabel.text = [NSString stringWithFormat:@"%@", [CodingUtil getMacroeconomicValue:[(NSNumber *)[secondDict objectForKey:[firstDate objectAtIndex:num]]doubleValue]]];
            }else{
                secondDataLabel.hidden = YES;
            }
        }
        
    }
}

-(void)setSecondFlag
{
    drawView.secondFlag = YES;
}


@end
