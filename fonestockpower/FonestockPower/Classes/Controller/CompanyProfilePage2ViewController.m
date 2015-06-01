//
//  CompanyProfilePage2ViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/8/14.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "CompanyProfilePage2ViewController.h"
#import "FSInstantInfoWatchedPortfolio.h"
#import "InvesterHoldOut.h"
@interface CompanyProfilePage2ViewController ()
{
    UITableView *mainTableView;
    FSDataModelProc *model;
    NSMutableDictionary *dict;
    NSMutableDictionary *boardDict;
}
@end

@implementation CompanyProfilePage2ViewController

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
	[self initMainTableView];
    [self processLayout];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initModel];
    [self registerSecurityRegisterNotificationCallBack:self seletor:@selector(initModel)];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self unRegisterSecurityRegisterNotificationCallBack:self];
    model.investerHold.delegate = nil;
    model.boardHolding.delegate = nil;
    boardDict = nil;
    dict = nil;
    [mainTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initModel
{
    model = [FSDataModelProc sharedInstance];
    model.investerHold.delegate = self;
    model.boardHolding.delegate = self;
    [model.investerHold sendAndRead];
    [model.boardHolding sendAndRead];
}

-(void)InvesterNotifyData:(id)target
{
    dict = target;
    [mainTableView reloadData];
}

-(void)BoardHoldingNotifyData:(id)target
{
    boardDict = target;
    [mainTableView reloadData];
}

-(void)initMainTableView
{
    mainTableView = [[UITableView alloc] init];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    mainTableView.allowsSelection = NO;
    mainTableView.bounces = NO;
    [self.view addSubview:mainTableView];
}

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(mainTableView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView]-15-|" options:0 metrics:nil views:viewController]];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return 1;
    }else{
        return 3;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        static NSString *kCellIdentifier = @"TopCell";
        CompanyProfilePage2TopCell *cell = (CompanyProfilePage2TopCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        if (cell == nil) {
            cell = [[CompanyProfilePage2TopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        }
        if(!dict){
            cell.foreignCapitalPercent.text= @"---";
            cell.investmentTrustPercent.text= @"---";
            cell.dealersPercent.text = @"---";
            cell.directorsPercent.text =@"---";
        }else{
            cell.foreignCapitalPercent.text= [self returnNumber:[(NSNumber *)[dict objectForKey:@"Ratio1"]doubleValue]];
            cell.investmentTrustPercent.text= [self returnNumber:[(NSNumber *)[dict objectForKey:@"Ratio2"]doubleValue]];
            cell.dealersPercent.text = [self returnNumber:[(NSNumber *)[dict objectForKey:@"Ratio3"]doubleValue]];
            
            cell.foreignCapitalPercent.textColor = [self setTextColor:[(NSNumber *)[dict objectForKey:@"Ratio1"]doubleValue]];
            cell.investmentTrustPercent.textColor = [self setTextColor:[(NSNumber *)[dict objectForKey:@"Ratio2"]doubleValue]];
            cell.dealersPercent.textColor = [self setTextColor:[(NSNumber *)[dict objectForKey:@"Ratio3"]doubleValue]];
            
            if(!boardDict){
                cell.directorsPercent.text = @"----";
            }else{
                cell.directorsPercent.text = [self returnNumber:[(NSNumber *)[[boardDict objectForKey:@"HoldRatio"]objectAtIndex:0]doubleValue]];
                cell.directorsPercent.textColor = [self setTextColor:[(NSNumber *)[[boardDict objectForKey:@"HoldRatio"]objectAtIndex:0]doubleValue]];
            }
        }
        cell.legalLabel.text=@"法人認同度(持股比率)";
        cell.foreignCapitalLabel.text=@"外資";
        cell.investmentTrustLabel.text=@"投信";
        cell.dealersLabel.text=@"自營商";
        cell.directorsLabel.text=@"董監事";
        return cell;
    }else {
        static NSString *kCellIdentifier = @"BottomCell";
        CompanyProfilePage2BottomCell *cell = (CompanyProfilePage2BottomCell *)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
        
        if (cell == nil) {
            cell = [[CompanyProfilePage2BottomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        }
        if(indexPath.section == 1){
            if(!boardDict){
                cell.shareHoldersDateLabel.text=@"----";
                cell.shareHoldersRateLabel.text=@"----";
                cell.changeRateLabel.text=@"----";
            }else{
                cell.shareHoldersDateLabel.text = [self determineIfExist:[boardDict objectForKey:@"HDate"] IndexPath:indexPath.row];
                cell.shareHoldersRateLabel.text = [CodingUtil getValueToPrecent:[(NSNumber *)[self determineIfExist:[boardDict objectForKey:@"HoldRatio"] IndexPath:indexPath.row]doubleValue]];
                cell.changeRateLabel.text = [CodingUtil getValueToPrecent:[(NSNumber *)[self determineIfExist:[boardDict objectForKey:@"OffsetRatio"] IndexPath:indexPath.row]doubleValue]];
                [cell.shareHoldersRateLabel setTextColor:[self textColor:[boardDict objectForKey:@"OffsetRatio"] IndexPath:indexPath.row]];
                [cell.changeRateLabel setTextColor:[self textColor:[boardDict objectForKey:@"OffsetRatio"] IndexPath:indexPath.row]];
            }
        }else{
            NSArray *boardArray = [boardDict objectForKey:@"PDate"];
            if (boardArray) {
                if ([boardArray count] <= indexPath.row) {
                    cell.shareHoldersDateLabel.text=@"----";
                    cell.shareHoldersRateLabel.text=@"----";
                    cell.changeRateLabel.text=@"----";
                    
                    [cell.shareHoldersDateLabel setTextColor:[UIColor blackColor]];
                }else{
                    cell.shareHoldersDateLabel.text=[[boardDict objectForKey:@"PDate"]objectAtIndex:indexPath.row];
                    cell.shareHoldersRateLabel.text=[[boardDict objectForKey:@"PledgeVolume"]objectAtIndex:indexPath.row];
                    [cell.shareHoldersRateLabel setTextColor:[UIColor blueColor]];
                    cell.changeRateLabel.text=[CodingUtil getValueToPrecent:[(NSNumber *)[[boardDict objectForKey:@"PledgeRatio"]objectAtIndex:indexPath.row]doubleValue]];
                    [cell.changeRateLabel setTextColor:[UIColor blueColor]];
                    [cell.shareHoldersDateLabel setTextColor:[UIColor blueColor]];
                }
            }   
        }
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        return 110.0f;
    }else{
        return 40.0f;
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIFont * font = [UIFont boldSystemFontOfSize:18.0f];
    
    UILabel * leftLabel = [[UILabel alloc] init];
    leftLabel.textColor = [UIColor whiteColor];
    leftLabel.font = font;
    leftLabel.translatesAutoresizingMaskIntoConstraints=NO;
    
    UILabel * centerLabel = [[UILabel alloc] init];
    centerLabel.font = font;
    centerLabel.textColor = [UIColor whiteColor];
    centerLabel.translatesAutoresizingMaskIntoConstraints=NO;
    
    UILabel * rightLabel = [[UILabel alloc] init];
    rightLabel.font= font;
    rightLabel.textColor = [UIColor whiteColor];
    rightLabel.textAlignment = NSTextAlignmentRight;
    rightLabel.translatesAutoresizingMaskIntoConstraints=NO;

    
    if(section==1){
        leftLabel.text = @"董監持股";
        centerLabel.text = @"持股比率";
        rightLabel.text = @"變 動 率";
    }else if(section==2){
        leftLabel.text = @"董監質押";
        centerLabel.text = @"質押張數";
        rightLabel.text = @"質押比率";
    }else{
        return nil;
    }
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor colorWithRed:226.0f/255.0f green:153.0f/255.0f blue:32.0f/255.0f alpha:1];
    
    [headerView addSubview:leftLabel];
    [headerView addSubview:centerLabel];
    [headerView addSubview:rightLabel];
    
    NSDictionary *viewControll = NSDictionaryOfVariableBindings(leftLabel, centerLabel, rightLabel);
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftLabel][centerLabel(==leftLabel)][rightLabel(==leftLabel)]-20-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControll]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftLabel]|" options:0 metrics:nil views:viewControll]];
    return headerView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section==0){
        return 0;
    }
    return 40.0f;
}

-(NSString *)returnNumber:(double)value
{
    if(value==0){
        return @"----";
    }else{
        return [CodingUtil getValueToPrecent:value];
    }
}

-(UIColor *)setTextColor:(double)cellNumber{
    UIColor *textColor;
    if (cellNumber == 0) {
        textColor = [UIColor blackColor];
    }else{
        textColor = [UIColor blueColor];
    }
    return textColor;
}
-(UIColor *)textColor:(NSArray *)dic IndexPath:(NSInteger)indexPath{
    if ([dic count] > indexPath) {
        if ([[dic objectAtIndex:indexPath]doubleValue] > 0.00) {
            return [UIColor redColor];
        }else if ([[dic objectAtIndex:indexPath]doubleValue] < 0.00){
            return [UIColor colorWithRed:26.0/255.0 green:132.0/255.0 blue:24.0/255.0 alpha:1];
        }else{
            return [UIColor blueColor];
        }
    }else{
        return [UIColor blueColor];
    }
}
-(NSString *)determineIfExist:(NSArray *)dic IndexPath:(NSInteger)indexPath{
    if ([dic count] > indexPath) {
        return [dic objectAtIndex:indexPath];
    }else{
        return @"----";
    }
}
@end
