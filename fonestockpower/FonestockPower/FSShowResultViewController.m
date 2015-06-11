//
//  FSShowResultViewController.m
//  DivergenceStock
//
//  Created by CooperLin on 2014/12/5.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSShowResultViewController.h"
#import "ShowResultTableViewCell.h"
#import "FSDivergenceModel.h"
#import "FSPaymentViewController.h"
#import "FSFile.h"
#import "TechViewController.h"
#import "FSADPopViewController.h"


//翻轉會有問題，但是暫緩處理 PS解決方案為：鎖定畫面，不讓其有翻轉的可能
#define mainTableViewHeaderBackgroundColor [UIColor colorWithRed: 1.0/255.0 green: 124.0/255.0 blue: 251.0/255.0 alpha: 1.0]
#define TABLEVIEW_HEADER_FONTSIZE [UIFont boldSystemFontOfSize:16.0]


@interface FSShowResultViewController ()<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, FSDivergenceDelegate, FSDivergenceMainCellDelegate>{

    // FSDivergenceMainCellDelegate被註解掉的
    
    FSUIButton *changeBullOrBearButton;
    UILabel *updateTimeLabel;
    
    
    UITableView *tView;
    UIScrollView *sclViewForContent;
    
    FSDataModelProc *dataModel;
    
    UIScrollView *beingScrolled;
    
    NSArray *containFiveArrays;
    //此陣列包含五個陣列，各個陣列是試驗畫面的button 是否顯示勾勾，有值->顯示，空值(@"")->隱藏
    //但是每個陣列顯示的為直向的結果，須透過 setArrays 及 putStuffIntoArray: 轉成橫向的結果
    //ps 直向指cellForColumn 橫向指cellForRow
    
    NSArray *textArray;
    
    BOOL isFirstDivergenceTipsAD;
    
    UIView *toastView;
    
    NSArray *tableViewTitleArray;
    
    ReturnTwoArrayObjects *rtaObj;
    
    NSMutableArray *layoutConstraints;
    
    MBProgressHUD *hud;
}


@end

@implementation FSShowResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dataModel = [FSDataModelProc sharedInstance];
    dataModel.divergenceModel.delegate = self;
    [self initView];
    [self.view setNeedsUpdateConstraints];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self doPreLoadData];
    
    //在使用protocolbuffer 前必須先完成登入的動作，而divergenceTips是app一打開就進入的頁面，因此登入的動作沒有辦法在畫面顯示完畢之前就完成，所以在通知中心進行註冊，當登入完成之後通知中心會透過「loginServiceStatus」自行通知這個viewController的「loginAuthCallBackNotification」method
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginAuthCallBackNotification:) name:@"loginServiceStatus" object:nil];

}

- (void)viewWillDisappear:(BOOL)animated {
    //有註冊就要有移除，一直註冊而沒有移除的動作會造成一些問題（什麼問題，我忘了）
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)initView
{
//    [self.navigationItem setHidesBackButton:YES];
    
    layoutConstraints = [[NSMutableArray alloc] init];
    
    [self setToastView];
    [self setArrays];
    
    updateTimeLabel = [[UILabel alloc] init];
    updateTimeLabel.textAlignment = NSTextAlignmentRight;
    updateTimeLabel.textColor = [UIColor blueColor];
    updateTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:updateTimeLabel];
    
    changeBullOrBearButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeChangeBullOrBear];
    [changeBullOrBearButton addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [changeBullOrBearButton setTitle:NSLocalizedStringFromTable(@"Divert to Bull", @"DivergenceTips", nil) forState:UIControlStateNormal];
    changeBullOrBearButton.translatesAutoresizingMaskIntoConstraints = NO;
    changeBullOrBearButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:changeBullOrBearButton];
    
    tView = [[UITableView alloc] init];
    tView.delegate = self;
    tView.dataSource = self;
    tView.bounces = NO;
    tView.showsHorizontalScrollIndicator = NO;
    tView.showsVerticalScrollIndicator = NO;
    tView.translatesAutoresizingMaskIntoConstraints = NO;
    tView.separatorInset = UIEdgeInsetsZero;
    tView.layer.borderWidth = 0.5;
    tView.layer.borderColor = [UIColor grayColor].CGColor;
    [self.view addSubview:tView];

    textArray = [NSArray arrayWithObjects:
                 NSLocalizedStringFromTable(@"名稱",@"DivergenceTips",nil),
                 NSLocalizedStringFromTable(@"Vol",@"DivergenceTips",nil),
                 NSLocalizedStringFromTable(@"KD",@"DivergenceTips",nil),
                 NSLocalizedStringFromTable(@"RSI",@"DivergenceTips",nil),
                 NSLocalizedStringFromTable(@"MACD",@"DivergenceTips",nil),
                 NSLocalizedStringFromTable(@"OBV",@"DivergenceTips",nil), nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    isFirstDivergenceTipsAD = YES;
    [userDefaults setBool:isFirstDivergenceTipsAD forKey:@"isFirstDivergenceTipsAD"];
    [userDefaults synchronize];
    
}

-(void)doPreLoadData
{
    if([dataModel.divergenceModel getTheFileInMyFileFolder]){
        
        NSData *data = [FSFile readFileInCacheDirectory:@"MyFile" fileName:[dataModel.divergenceModel getTheFileInMyFileFolder]];
        [self performSelectorOnMainThread:@selector(readBinaryData:) withObject:data waitUntilDone:YES];
        
        updateTimeLabel.text = [dataModel.divergenceModel getFileTime:[dataModel.divergenceModel getTheFileInMyFileFolder]];
        
    }
}

- (void)loginAuthCallBackNotification:(NSNotification *)notification {
 
    //接收到通知後做的動作
    FSLoginResultType authResultType = [(NSNumber *)[notification object] intValue];
    //判斷接收到的通知是屬於哪一類的，是不是我們要的那一種
    if (authResultType == FSLoginResultTypeServiceServerLoginSuccess) {
//        [dataModel.divergenceModel performSelector:@selector(reloadProtocolBuffersData) onThread:dataModel.thread withObject:nil waitUntilDone:YES];
        
        [FSHUD showGlobalProgressHUDWithTitle:NSLocalizedStringFromTable(@"資料下載中, 請稍候", @"DivergenceTips", nil) hideAfterDelay:2];
        
        [dataModel.divergenceModel performSelector:@selector(reloadProtocolBuffersData) withObject:nil afterDelay:0.5];
    }
    if (authResultType == 123) {
        [self performSelectorOnMainThread:@selector(showTheLoginToast) withObject:nil waitUntilDone:YES];   
    }
}

#pragma mark 接收回來的下行電文
-(void)loadDidFinishWithData:(FSDivergenceModel *)data
{
    NSLog(@"data has arrived \n '%@'",data.downloadURL);
    [self getAllInformation:[NSURL URLWithString:data.downloadURL]];
}

//判斷是否已有最新的資料，有則直接解析，沒有則儲存起來，並解析取得的nsdata 的資料內容
-(void)getAllInformation:(NSURL *)URL
{
    
    
    NSString *fileName = [URL.absoluteURL lastPathComponent];

    updateTimeLabel.text = [dataModel.divergenceModel getFileTime:fileName];
    
    if(![FSFile fileExistsInCacheDirectory:@"MyFile" fileName:fileName]){
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if([fileManager fileExistsAtPath:[CodingUtil divergenceDataDirectoryPath]]    ){
                [fileManager removeItemAtPath:[CodingUtil divergenceDataDirectoryPath] error:nil];
            }
            
            [FSFile writeFileInCache:data subDirectoryName:@"MyFile" fileName:response.suggestedFilename];
            
            [self performSelectorOnMainThread:@selector(readBinaryData:) withObject:data waitUntilDone:YES];
            //將牛市及熊市內的所有物件各別存到storeBull 及storeBear 的陣列裡面
            //裡面有兩層，第一層是symbol，lastprice，跟refprice 第二層是放在ContainerForThreeObjects 裡面
            //symbol->IdentCode, symbol.symbol這兩個資料是cell 裡的btn 被按下時需要送出去的資料
            //identCodeSymbol 格式："%s:%@" or "%c%c:%@"
            
            if (connectionError) {
                [FSHUD showGlobalProgressHUDWithTitle:@"連線異常, 請檢查網路連線" hideAfterDelay:3];
            }
        }];
    }else{
        NSData *data = [FSFile readFileInCacheDirectory:@"MyFile" fileName:[URL.absoluteURL lastPathComponent]];
        [self performSelectorOnMainThread:@selector(readBinaryData:) withObject:data waitUntilDone:YES];
        
    }
}

-(void)readBinaryData:(NSData *)data
{
    if(!data)return;
    rtaObj = [FSDivergenceModel DataFromServerIn:data];
    
    [FSHUD hideGlobalHUD];
    
    [tView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}



-(void)updateViewConstraints {
    [super updateViewConstraints];
    [self.view removeConstraints:layoutConstraints];

    NSDictionary *allObj = NSDictionaryOfVariableBindings(changeBullOrBearButton, updateTimeLabel, tView);
    NSDictionary *metrics = @{@"tableHeight":[NSNumber numberWithFloat:self.view.bounds.size.height - 130]};
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-1-[changeBullOrBearButton(44)]-1-[tView(tableHeight)]" options:0 metrics:metrics views:allObj]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[changeBullOrBearButton(90)]-[updateTimeLabel]-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:allObj]];
    
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-1-[tView]-1-|" options:0 metrics:nil views:allObj]];
    
    [self.view addConstraints:layoutConstraints];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

//最上方的兩個按鈕被按下後所要做的動作
-(void)btnClicked:(UIButton *)sender
{
    changeBullOrBearButton.selected = !changeBullOrBearButton.selected;
    
    if (changeBullOrBearButton.selected) {
        [changeBullOrBearButton setTitle:NSLocalizedStringFromTable(@"Divert to Bear", @"DivergenceTips", nil) forState:UIControlStateNormal];
    } else {
        [changeBullOrBearButton setTitle:NSLocalizedStringFromTable(@"Divert to Bull", @"DivergenceTips", nil) forState:UIControlStateNormal];
    }
    
    
    [tView reloadData];
}

-(void)setToastView
{
    toastView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2 - 50, self.view.frame.size.height - 150, 100, 30)];
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    lbl.text = NSLocalizedStringFromTable(@"登入成功", @"Launcher", nil);
    lbl.textColor = [UIColor whiteColor];
    lbl.textAlignment = NSTextAlignmentCenter;
    [toastView addSubview:lbl];
    toastView.backgroundColor = [UIColor blackColor];
    [toastView.layer setMasksToBounds:YES];
    toastView.layer.cornerRadius = 10;
    toastView.hidden = YES;
    [self.view addSubview:toastView];
}

-(void)setArrays
{
    NSMutableArray *forTestArray1 = [[NSMutableArray alloc] init];
    NSMutableArray *forTestArray2 = [[NSMutableArray alloc] init];
    NSMutableArray *forTestArray3 = [[NSMutableArray alloc] init];
    NSMutableArray *forTestArray4 = [[NSMutableArray alloc] init];
    NSMutableArray *forTestArray5 = [[NSMutableArray alloc] init];
    containFiveArrays = [NSArray arrayWithObjects:forTestArray1, forTestArray2, forTestArray3, forTestArray4, forTestArray5, nil];
}

-(void)putStuffIntoArray:(ContainerForThreeObjects *)cfto
{
    int i = 0;
    for(NSMutableArray *ar1 in containFiveArrays){
        [ar1 addObject:[cfto.divIDTick objectAtIndex:i]];
        i++;
    }
}

-(void)cellBtnBeClicked:(NSInteger)indexRow sender:(UIButton *)sender
{
    NSLog(@"indexRow === %d", (int)indexRow);
    CompleteStuff *csff;
    BOOL isBull;
    if(changeBullOrBearButton.selected == NO){
        csff = [rtaObj.storeBull objectAtIndex:indexRow];
        isBull = YES;
    }else{
        csff = [rtaObj.storeBear objectAtIndex:indexRow];
        isBull = NO;
    }
    ContainerForThreeObjects *cfto = [csff.divergenceObject objectAtIndex:(sender.tag % 100) - 1];
    NSLog(@"IdentCode Symbol %c%c %@ date from %d - %d Target %@",
          csff.symbol->IdentCode[0],csff.symbol->IdentCode[1],
          csff.symbol->symbol,
          (unsigned int)cfto.startDate,(unsigned int)cfto.endDate,
          [textArray objectAtIndex:(sender.tag % 100)]);
    //日期也是要給kenny 的，他說直接傳給他這個格式即可，不用轉回2014 的格式
    NSDictionary *dict = @{@"IdentCode":[NSString stringWithFormat:@"%c%c", csff.symbol->IdentCode[0], csff.symbol->IdentCode[1]],
                           @"Symbol":csff.symbol->symbol,
                           @"FullName":csff.symbol->fullName,
                           @"IdentCodeSymbol":[NSString stringWithFormat:@"%c%c %@", csff.symbol->IdentCode[0], csff.symbol->IdentCode[1], csff.symbol->symbol],
                           @"Type":[textArray objectAtIndex:(sender.tag % 100)],
                           @"StartDate":[NSNumber numberWithInt:cfto.startDate],
                           @"EndDate":[NSNumber numberWithInt:cfto.endDate],
                           @"SymbolType":[NSNumber numberWithBool:isBull]};
    TechViewController *techViewController = [[TechViewController alloc] initWithDict:dict];
    [self.navigationController pushViewController:techViewController animated:NO];
}

#pragma make the tableview separtor shows perfactly
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Remove seperator inset
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//    
//    // Prevent the cell from inheriting the Table View's margin settings
//    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
//        [cell setPreservesSuperviewLayoutMargins:NO];
//    }
//    
//    // Explictly set your cell's layout margins
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return (isBullDivergenceOrNot)?rtaObj.storeBull.count:rtaObj.storeBear.count;
    NSInteger numberOfRows = 0;
    if(changeBullOrBearButton.selected == NO){
        numberOfRows = rtaObj.storeBull.count;
    }else{
        numberOfRows = rtaObj.storeBear.count;
    }
    return numberOfRows;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"ShowResultTableViewCell";
    ShowResultTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(!cell){
        cell = [[ShowResultTableViewCell alloc] initWithCustomTableViewCell:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    [self refreshMainCellContent:cell indexNum:indexPath.row];
    cell.delegate = self;
    cell.tag = indexPath.row;

    CompleteStuff *csff;
    if(changeBullOrBearButton.selected == NO){
        csff = [rtaObj.storeBull objectAtIndex:indexPath.row];
    }else{
        csff = [rtaObj.storeBear objectAtIndex:indexPath.row];
    }
    
    [cell.VolBtn setHidden:![[csff.divergenceObject objectAtIndex:0] isKindOfClass:NSClassFromString(@"ContainerForThreeObjects")]];
    [cell.KdBtn setHidden:![[csff.divergenceObject objectAtIndex:1] isKindOfClass:NSClassFromString(@"ContainerForThreeObjects")]];
    [cell.RsiBtn setHidden:![[csff.divergenceObject objectAtIndex:2] isKindOfClass:NSClassFromString(@"ContainerForThreeObjects")]];
    [cell.MacdBtn setHidden:![[csff.divergenceObject objectAtIndex:3] isKindOfClass:NSClassFromString(@"ContainerForThreeObjects")]];
    [cell.ObvBtn setHidden:![[csff.divergenceObject objectAtIndex:4] isKindOfClass:NSClassFromString(@"ContainerForThreeObjects")]];
    
    return cell;
}

-(void)refreshMainCellContent:(ShowResultTableViewCell *)cell indexNum:(NSInteger)indexNum
{
    CompleteStuff *csff;
    if(changeBullOrBearButton.selected == NO){
        csff = [rtaObj.storeBull objectAtIndex:indexNum];
    }else{
        csff = [rtaObj.storeBear objectAtIndex:indexNum];
    }    cell.mainLbl.text = csff.symbol->fullName;
    int a = csff.lastPrice;
    int b = csff.refPrice;
    int c = (a - b) * 10000;
#pragma mark 目前從server 接收到的資料由於分母為零，於是先加上此if 判斷式
    CGFloat theValue = 0.0;
    if(b != 0) theValue = c / b;
        
    //為什麼要用這種方式算這類數值？
    //因為unsigned int 的關係，unsigned 即為不分正、負號的意思，而lastPrice 與refPrice 做相減時可能會有負號的問題產生，而一般的表示負號的方式是最左邊的位元改為1 ，但是對unsigned int 來說，最左邊的數字仍然是可運算的數值，所以才會發生數值跑掉的問題。
    //所以，我先將unsigned int 轉成int 這類可表示負號的變數，然後才進行可能會有負號產生的運算，才可避免數值跑掉的問題！
    cell.detailLbl.text = [NSString stringWithFormat:@"%.2f(%@)",a/100.0,[FSDivergenceModel separatePositiveOrNegative:theValue]];
    cell.detailLbl.textColor = [FSDivergenceModel makeItGreenOrRed:theValue];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerCell = [[UIView alloc] init];
    
    [self doContentLabel:headerCell];
    headerCell.backgroundColor = mainTableViewHeaderBackgroundColor;
    return headerCell;
}

-(void)doContentLabel:(UIView *)headerCell
{
    UILabel *ll1 = [[UILabel alloc] init];
    UILabel *ll2 = [[UILabel alloc] init];
    UILabel *ll3 = [[UILabel alloc] init];
    UILabel *ll4 = [[UILabel alloc] init];
    UILabel *ll5 = [[UILabel alloc] init];
    UILabel *ll6 = [[UILabel alloc] init];
    tableViewTitleArray = [NSArray arrayWithObjects:ll1, ll2, ll3, ll4, ll5, ll6, nil];
    
    int i = 0;
    for(UILabel *ll in tableViewTitleArray){
        ll.textColor = [UIColor whiteColor];
        ll.font = TABLEVIEW_HEADER_FONTSIZE;
        ll.text = [textArray objectAtIndex:i];
        ll.textAlignment = NSTextAlignmentCenter;
        ll.translatesAutoresizingMaskIntoConstraints = NO;
        [headerCell addSubview:ll];
        i++;
    }
    
    NSDictionary *allObj = NSDictionaryOfVariableBindings(ll1,ll2,ll3,ll4,ll5,ll6);
    CGFloat customWidthForMACD = (self.view.frame.size.width - 80)/5;
    if(customWidthForMACD < 50.0){
        customWidthForMACD = 50.0;
    }
    NSDictionary *metrics = @{@"eachLabelWidth":[NSNumber numberWithFloat:(self.view.frame.size.width - 80)/5],@"customWidthForMACD":[NSNumber numberWithFloat:customWidthForMACD]};
    
    [headerCell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[ll1(80)][ll2(eachLabelWidth)][ll3(ll2)][ll4(ll2)][ll5(customWidthForMACD)][ll6(ll2)]" options:0 metrics:metrics views:allObj]];
    [headerCell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ll1]|" options:0 metrics:nil views:allObj]];
    [headerCell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ll2]|" options:0 metrics:nil views:allObj]];
    [headerCell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ll3]|"options:0 metrics:nil views:allObj]];
    [headerCell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ll4]|" options:0 metrics:nil views:allObj]];
    [headerCell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ll5]|" options:0 metrics:nil views:allObj]];
    [headerCell addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[ll6]|" options:0 metrics:nil views:allObj]];
}

#pragma About Scrolling two tableViews
//- (void)scrollViewDidScroll:(UIScrollView *)sender {
//    if ([sender isEqual:tView]) {
//        contentTView.contentOffset = tView.contentOffset;
//    } else if ([sender isEqual:contentTView]) {
//        tView.contentOffset = contentTView.contentOffset;
//    }
//}

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
//    [self performSelector:@selector(wakeTheSGInfoAlert) withObject:nil afterDelay:2];
//    [self wakeTheSGInfoAlert];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showTheLoginToast
{
    toastView.hidden = NO;
    [self performSelector:@selector(closeTheLoginToast) withObject:nil afterDelay:3];
}

-(void)closeTheLoginToast
{
    toastView.hidden = YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
