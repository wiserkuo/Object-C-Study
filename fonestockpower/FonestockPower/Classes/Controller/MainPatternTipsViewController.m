//
//  MainPatternTipsViewController.m
//  FonestockPower
//
//  Created by Kenny on 2015/1/14.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "MainPatternTipsViewController.h"
#import "PatternTipsTableViewCell.h"
#import "PatternTipsModel.h"
#import "FSFile.h"
#import "TechViewController.h"
#import "Tips_location_up.pb.h"
#import "ProtocolBufferOut.h"
#import "ProtocolBufferIn.h"
#import "FSADPopViewController.h"
#import "FigureSearchMyProfileModel.h"

@interface MainPatternTipsViewController ()<UITableViewDataSource, UITableViewDelegate, PatternTipsTableViewCellDelegate>
{
    UITableView *mainTableView;
    NSString *system;
    NSMutableDictionary *mainDict;
    FSDataModelProc *model;
    FSFonestock *fonestock;
    BOOL isFirstDivergenceTipsAD;
    UIView *toastView;
    UILabel *msgLabelView;
    
    FSUIButton *changeBullOrBearButton;
    UILabel *updateTimeLabel;
}
@end

@implementation MainPatternTipsViewController
- (void)dealloc {
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initModel];
    [self initView];
    [self.view setNeedsUpdateConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self doPreLoadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAuthCallBackNotification:) name:@"loginServiceStatus" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)doPreLoadData
{
    if([PatternTipsModel getTheFileInMyFileFolder]){
        
        NSData *data = [FSFile readFileInCacheDirectory:@"MyFile" fileName:[PatternTipsModel getTheFileInMyFileFolder]];
        [self performSelectorOnMainThread:@selector(readBinaryData:) withObject:data waitUntilDone:YES];
        
        updateTimeLabel.text = [PatternTipsModel getFileTime:[PatternTipsModel getTheFileInMyFileFolder]];
        
    }
}

- (void)loginAuthCallBackNotification:(NSNotification *)notification {
    //接收到通知後做的動作
    FSLoginResultType authResultType = [(NSNumber *)[notification object] intValue];
    //判斷接收到的通知是屬於哪一類的，是不是我們要的那一種
    if (authResultType == FSLoginResultTypeServiceServerLoginSuccess) {
        [self performSelector:@selector(reloadProtocolBuffersData) withObject:nil afterDelay:0.5];
        
        [FSHUD showGlobalProgressHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中, 請稍候", @"DivergenceTips", nil) hideAfterDelay:2];
    }
}

- (void)reloadProtocolBuffersData {
    //tips_localtion_upBuilder 這些class是connor 做的，我還不會
    //在這裡將上行的protocolbuffer 建立起來，並使用電文將其送出
    tips_location_upBuilder *builder = [tips_location_up builder];
    [builder setType:(int)fonestock.TipsLocationUpdataType];
    tips_location_up *tips = [builder build];
    //電文的部份
    ProtocolBufferOut *pbo = [[ProtocolBufferOut alloc] initWithUpStream:tips.data];
    [FSDataModelProc sendData:self WithPacket:pbo];
}

-(void)loadDidFinishWithData:(PatternTipsModel *)data
{
    NSLog(@"data has arrived %@",data);
    [self getAllInformation:[NSURL URLWithString:data.downloadURL]];
    
//    [self popADFirstLogin];
}

-(void)getAllInformation:(NSURL *)URL
{
    
    NSString *fileName = [URL.absoluteURL lastPathComponent];
    
    updateTimeLabel.text = [PatternTipsModel getFileTime:fileName];
    
    if(![FSFile fileExistsInCacheDirectory:@"MyFile" fileName:[URL.absoluteURL lastPathComponent]]){
        
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if([fileManager fileExistsAtPath:[CodingUtil divergenceDataDirectoryPath]]    ){
                [fileManager removeItemAtPath:[CodingUtil divergenceDataDirectoryPath] error:nil];
            }
            
            [FSFile writeFileInCache:data subDirectoryName:@"MyFile" fileName:response.suggestedFilename];
            
            [self readBinaryData:data];
            //將牛市及熊市內的所有物件各別存到storeBull 及storeBear 的陣列裡面
            //裡面有兩層，第一層是symbol，lastprice，跟refprice 第二層是放在ContainerForThreeObjects 裡面
            //symbol->IdentCode, symbol.symbol這兩個資料是cell 裡的btn 被按下時需要送出去的資料
            //identCode Symbol 格式："%s %@" or "%c%c %@"
            
            if (connectionError) {
                [FSHUD showGlobalProgressHUDWithTitle:@"連線異常, 請檢查網路連線" hideAfterDelay:3];
            }
        }];
    }else{
        NSData *data = [FSFile readFileInCacheDirectory:@"MyFile" fileName:[URL.absoluteURL lastPathComponent]];
        [self readBinaryData:data];
        
    }
}
-(void)readBinaryData:(NSData *)data
{
    if(!data)return;
    mainDict = [PatternTipsModel DataFromFileIn:data];
    [mainTableView reloadData];
}

-(void)initModel
{
    
    model = [FSDataModelProc sharedInstance];
    model.patternTipsModel.delegate = self;
    
//    NSString * appid = [FSFonestock sharedInstance].appId;
//    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
//    if(![group isEqualToString:@"us"])return;
//    FigureSearchMyProfileModel *customModel = [[FigureSearchMyProfileModel alloc] init];
//    for(int i = 1; i < 13; i++){
//        [customModel updateFigureSearchImageToUSStyle:[NSNumber numberWithInt:i] LongOrShort:@"LongSystem" Image:UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"more_%d",i]])];
//         [customModel updateFigureSearchImageToUSStyle:[NSNumber numberWithInt:i+12] LongOrShort:@"ShortSystem" Image:UIImagePNGRepresentation([UIImage imageNamed:[NSString stringWithFormat:@"zero_%d",i]])];
//     }
}

-(void)initView
{
    
    fonestock = [FSFonestock sharedInstance];
    
    system = @"LongSystem";
    
    
    updateTimeLabel = [[UILabel alloc] init];
    updateTimeLabel.textAlignment = NSTextAlignmentRight;
    updateTimeLabel.textColor = [UIColor blueColor];
    updateTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:updateTimeLabel];
    
    changeBullOrBearButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeChangeBullOrBear];
    [changeBullOrBearButton addTarget:self action:@selector(buttonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [changeBullOrBearButton setTitle:NSLocalizedStringFromTable(@"多方選股", @"DivergenceTips", nil) forState:UIControlStateNormal];
    changeBullOrBearButton.translatesAutoresizingMaskIntoConstraints = NO;
    changeBullOrBearButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:changeBullOrBearButton];

    
    mainTableView = [[UITableView alloc] init];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.layer.borderColor = [UIColor grayColor].CGColor;
    mainTableView.layer.borderWidth = 0.5;
    [self.view addSubview:mainTableView];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    isFirstDivergenceTipsAD = YES;
    [userDefaults setBool:isFirstDivergenceTipsAD forKey:@"isFirstDivergenceTipsAD"];
    [userDefaults synchronize];
    
}

-(void)buttonHandler:(FSUIButton *)sender {
    
    changeBullOrBearButton.selected = !changeBullOrBearButton.selected;
    
    if (changeBullOrBearButton.selected) {
        [changeBullOrBearButton setTitle:NSLocalizedStringFromTable(@"空方選股", @"DivergenceTips", nil) forState:UIControlStateNormal];
        system = @"ShortSystem";
    } else {
        [changeBullOrBearButton setTitle:NSLocalizedStringFromTable(@"多方選股", @"DivergenceTips", nil) forState:UIControlStateNormal];
        system = @"LongSystem";
    }
    
    
    [mainTableView reloadData];
}

-(void)popADFirstLogin{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults boolForKey:@"isFirstDivergenceTipsAD"] && ![userDefaults boolForKey:@"isFirstDivergenceTipsADCeck"]) {
        NSFileManager *fileManager = [[NSFileManager alloc]init];
        if ([fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/ADImage/Index.png", [CodingUtil fonestockDocumentsPath]]]) {
            
            isFirstDivergenceTipsAD = !isFirstDivergenceTipsAD;
            [userDefaults setBool:isFirstDivergenceTipsAD forKey:@"isFirstDivergenceTipsAD"];
            [userDefaults synchronize];
            FSADPopViewController *popAdView = [[FSADPopViewController alloc]init];
            [self presentViewController:popAdView animated:YES completion:nil];
        }else{
            NSLog(@"Wrong Path:%@/ADImage/", [CodingUtil fonestockDocumentsPath]);
        }
    }
}

-(void)updateViewConstraints {
    [super updateViewConstraints];

    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(changeBullOrBearButton, updateTimeLabel, mainTableView);
    
    NSMutableArray *layoutContraints = [[NSMutableArray alloc] initWithCapacity:3];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[changeBullOrBearButton(44)]-1-[mainTableView]-80-|" options:0 metrics:nil views:viewDictionary]];
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[changeBullOrBearButton(90)]-[updateTimeLabel]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    
    [layoutContraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewDictionary]];

    [self replaceCustomizeConstraints:layoutContraints];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tableIdentifier = [NSString stringWithFormat:@"PatternTipsTableViewCell%d_%@", (int)indexPath.row, system];
    PatternTipsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
    if(cell == nil){
        cell = [[PatternTipsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
    }
    PatternTipsObject *obj = [[mainDict objectForKey:system]objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.tag = indexPath.row;
    cell.imgName.text = NSLocalizedStringFromTable(NSLocalizedStringFromTable(obj.tipsName, @"FigureSearch", nil),@"DivergenceTips",nil);
    cell.imgView.image = [UIImage imageWithData:obj.tipsImg];
    //此為顯示tableView 左方圖示下方個數數字的給值的地方，因目前不需要，暫時註解起來
//    cell.imgCount.text = [NSString stringWithFormat:@"%d",obj.dataCount];
    cell.delegate = self;
    [cell setImgArray:obj.tipsData];
    return cell;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(changeBullOrBearButton.selected == YES){
        return [[mainDict objectForKey:@"ShortSystem"]count];
    }else{
        return [[mainDict objectForKey:@"LongSystem"]count];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.0;
}

-(void)cellBtnBeClicked:(NSInteger)cellTag CollectionRow:(NSInteger)collectionRow
{
    PatternTipsObject *tipsObj;
    if(changeBullOrBearButton.selected){
        tipsObj = [[mainDict objectForKey:@"ShortSystem"]objectAtIndex:cellTag];
    }else{
        tipsObj = [[mainDict objectForKey:@"LongSystem"]objectAtIndex:cellTag];
    }

    TipsSymbolObject *obj = [tipsObj.tipsData objectAtIndex:collectionRow];
    NSDictionary *dict = @{@"IdentCode":obj.identCode, @"Symbol":obj.Symbol, @"FullName":obj.fullName, @"IdentCodeSymbol":obj.identCodeSymbol, @"Type":@"Vol"};
    
    TechViewController *techViewController = [[TechViewController alloc] init];
    techViewController.symbolDict = dict;
    [self.navigationController pushViewController:techViewController animated:NO];
}

    
@end
