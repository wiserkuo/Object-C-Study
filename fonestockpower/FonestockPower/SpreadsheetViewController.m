//
//  SpreadsheetViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/6.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "SpreadsheetViewController.h"
#import "SKCustomTableView.h"

@interface SpreadsheetViewController ()<SKCustomTableViewDelegate>
{
    UILabel *targetLabel;
    FSUIButton *targetButton;
    UILabel *brokerageLabel;
    FSUIButton *brokerageButton;
    UILabel *objectPriceTitleLabel;
    UILabel *objectPriceLabel;
    UILabel *waveTitleLabel;
    UILabel *waveLabel;
    UILabel *targetPriceTitleLabel;
    FSUIButton *targetPriceButton;
    UILabel *targetWaveTitleLabel;
    FSUIButton *targetWaveButton;
    UILabel *dateLabel;
    FSUIButton *dateButton;
    SKCustomTableView *mainTableView;
}
@end

@implementation SpreadsheetViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    targetLabel = [[UILabel alloc] init];
    targetLabel.translatesAutoresizingMaskIntoConstraints = NO;
    targetLabel.text = @"權證標的";
    targetLabel.textColor = [UIColor blueColor];
    [self.view addSubview:targetLabel];
    
    targetButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    targetButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetButton];
    
    brokerageLabel = [[UILabel alloc] init];
    brokerageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    brokerageLabel.text = @"券商";
    brokerageLabel.textAlignment = NSTextAlignmentCenter;
    brokerageLabel.textColor = [UIColor blueColor];
    [self.view addSubview:brokerageLabel];
    
    brokerageButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeDetailYellow];
    brokerageButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:brokerageButton];
    
    objectPriceTitleLabel = [[UILabel alloc] init];
    objectPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    objectPriceTitleLabel.text = @"標的現價";
    objectPriceTitleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:objectPriceTitleLabel];
    
    objectPriceLabel = [[UILabel alloc] init];
    objectPriceLabel.translatesAutoresizingMaskIntoConstraints = NO;
    objectPriceLabel.textColor = [UIColor redColor];
    [self.view addSubview:objectPriceLabel];
    
    waveTitleLabel = [[UILabel alloc] init];
    waveTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    waveTitleLabel.text = @"歷史波動";
    waveTitleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:waveTitleLabel];
    
    waveLabel = [[UILabel alloc] init];
    waveLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:waveLabel];
    
    targetPriceTitleLabel = [[UILabel alloc] init];
    targetPriceTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    targetPriceTitleLabel.text = @"目標價格";
    targetPriceTitleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:targetPriceTitleLabel];
    
    targetPriceButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    targetPriceButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetPriceButton];
    
    targetWaveTitleLabel = [[UILabel alloc] init];
    targetWaveTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    targetWaveTitleLabel.text = @"目標波動%";
    targetWaveTitleLabel.adjustsFontSizeToFitWidth = YES;
    targetWaveTitleLabel.textColor = [UIColor blueColor];
    [self.view addSubview:targetWaveTitleLabel];
    
    targetWaveButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    targetWaveButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:targetWaveButton];
    
    dateLabel = [[UILabel alloc] init];
    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    dateLabel.text = @"評價日期";
    dateLabel.textColor = [UIColor blueColor];
    [self.view addSubview:dateLabel];
    
    dateButton = [[FSUIButton alloc] initWithButtonType:FSUIButtonTypeNormalRed];
    dateButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:dateButton];
    
    mainTableView = [[SKCustomTableView alloc] initWithfixedColumnWidth:77 mainColumnWidth:85 AndColumnHeight:44];
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.delegate = self;
    [self.view addSubview:mainTableView];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(targetLabel, targetButton, brokerageLabel, brokerageButton, objectPriceTitleLabel, objectPriceLabel, waveTitleLabel, waveLabel, targetPriceTitleLabel, targetPriceButton, targetWaveTitleLabel, targetWaveButton, dateLabel, dateButton, mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[targetLabel][targetButton(==targetLabel)][brokerageLabel(==targetLabel)][brokerageButton(==targetLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[objectPriceTitleLabel][objectPriceLabel(==objectPriceTitleLabel)][waveTitleLabel(==objectPriceTitleLabel)][waveLabel(==objectPriceTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[targetPriceTitleLabel][targetPriceButton(==targetPriceTitleLabel)][targetWaveTitleLabel(==targetPriceTitleLabel)][targetWaveButton(==targetPriceTitleLabel)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[dateLabel(==objectPriceTitleLabel)][dateButton]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[targetLabel(33)][objectPriceTitleLabel(==targetLabel)][targetPriceTitleLabel(==targetLabel)][dateLabel(==targetLabel)][mainTableView]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[targetButton(33)][objectPriceLabel(==targetButton)][targetPriceButton(==targetButton)][dateButton(==targetButton)][mainTableView]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[brokerageLabel(33)][waveTitleLabel(==brokerageLabel)][targetWaveTitleLabel(==brokerageLabel)][dateButton(==brokerageLabel)][mainTableView]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[brokerageButton(33)][waveLabel(==brokerageButton)][targetWaveButton(==brokerageButton)][dateButton(==brokerageButton)][mainTableView]|" options:0 metrics:nil views:viewDictionary]];
}


- (NSArray *)columnsInFixedTableView {
    return @[NSLocalizedStringFromTable(@"權證", @"", nil)];
}

- (NSArray *)columnsInMainTableView {
    return @[NSLocalizedStringFromTable(@"成交", @"", nil), NSLocalizedStringFromTable(@"預估價", @"", nil), NSLocalizedStringFromTable(@"報酬", @"", nil), NSLocalizedStringFromTable(@"類型", @"", nil), NSLocalizedStringFromTable(@"履約方式", @"", nil), NSLocalizedStringFromTable(@"上下限型", @"", nil), NSLocalizedStringFromTable(@"履約價", @"", nil), NSLocalizedStringFromTable(@"價內外", @"", nil), NSLocalizedStringFromTable(@"剩餘天數", @"", nil), NSLocalizedStringFromTable(@"隱含波動", @"", nil), NSLocalizedStringFromTable(@"實質槓桿", @"", nil), NSLocalizedStringFromTable(@"距損平點", @"", nil)];
}

- (void)updateFixedTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    int recordCount = [_revenueArray count];
    //    label.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    //    if(recordCount<=0)
    //    {
    //        label.text = @"----";
    //        label.textColor = [UIColor orangeColor];
    //    }
    //    else {
    //        if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
    //            //getRowData會檢查傳進去的參數是否大於0
    //            // change format : year/month => month/year （Memory 中的資料年放在前頭 也就是year/month格式 這樣比較好遵照 “年 月“ 來ＳＯＲＴ,而輸出因應要求則需轉換成 month/year）
    //            label.text = [self getDateStr:[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"Date"]];
    //            label.textColor = [UIColor blueColor];
    //        }else{
    //            //getRowData會檢查傳進去的參數是否大於0
    //            // change format : year/month => month/year （Memory 中的資料年放在前頭 也就是year/month格式 這樣比較好遵照 “年 月“ 來ＳＯＲＴ,而輸出因應要求則需轉換成 month/year）
    //            NSString *monthString =@"";
    //            int month = [(NSNumber *)[[self getDateStr:[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"Date"]] substringFromIndex:5]intValue];
    //            if (month>=1 && month<=3) {
    //                monthString = @"Q1";
    //            }else if (month>=4 && month<=6){
    //                monthString = @"Q2";
    //            }else if (month>=7 && month<=9){
    //                monthString = @"Q3";
    //            }else if (month>=10 && month<=12){
    //                monthString = @"Q4";
    //            }
    //            NSRange yearRange;
    //            yearRange.location	= 0;
    //            yearRange.length = 4;
    //            NSString *yearString = [[self getDateStr:[[_revenueArray objectAtIndex:indexPath.row] objectForKey:@"Date"]] substringWithRange:yearRange];
    //            if([[[FSFonestock sharedInstance].appId substringWithRange:NSMakeRange(0, 2)] isEqualToString:@"tw"]){
    //                label.text = [NSString stringWithFormat:@"%04d/%@",[yearString intValue],monthString];
    //            }else{
    //                label.text = [NSString stringWithFormat:@"%@/%04d",monthString,[yearString intValue]];
    //            }
    //            label.textColor = [UIColor blueColor];
    //        }
    //    }
    
}

- (void)updateMainTableViewCellLabel:(UILabel *)label cellForColumnAtIndex:(NSInteger)columnIndex cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //    int recordCount = [_revenueArray count];
    //
    //    if (recordCount <= 0) {
    //        label.text = @"----";
    //        label.textColor = [UIColor blackColor];
    //        return;
    //    }
    //    else {
    //        //column會預先產生25個(因應選股精靈)，所以超過自己要的index不要跑
    //        if (columnIndex < [headerSmybolArray count]) {
    //            [self updateRevenueLabel:label columnIndex:columnIndex indexPath:indexPath header:headerSmybolArray[columnIndex]];
    //        }
    //    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 20;
}
@end
