//
//  DataSettingViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/6/24.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "DataSettingViewController.h"

@interface DataSettingViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
{
    UITableView *mainTableView;
    
}
@end

@implementation DataSettingViewController

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
    self.title = NSLocalizedStringFromTable(@"待機設定", @"Launcher", nil);
    mainTableView = [[UITableView alloc] init];
    mainTableView.backgroundColor = [UIColor clearColor];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
    
    [self processLayout];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(mainTableView);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView]|" options:0 metrics:nil views:viewController]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewController]];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    FSUITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[FSUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.row==0){
        cell.textLabel.text = NSLocalizedStringFromTable(@"清除即時盤資料", @"DataSetting", nil);
    }else if(indexPath.row==1){
        cell.textLabel.text = NSLocalizedStringFromTable(@"清除盤後資料", @"DataSetting", nil);
    }else if(indexPath.row==2){
        cell.textLabel.text = NSLocalizedStringFromTable(@"清除新聞資料", @"DataSetting", nil);
    }
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedStringFromTable(@"Data Clear", @"DataSetting", nil);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row==1){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"要清除盤後資料嗎?", @"DataSetting", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"取消", @"DataSetting", nil) otherButtonTitles:NSLocalizedStringFromTable(@"確定", @"DataSetting", nil), nil];
        [alertView show];
        
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedStringFromTable(@"盤後資料清除完畢!", @"DataSetting", nil) delegate:self cancelButtonTitle:NSLocalizedStringFromTable(@"確定", @"DataSetting", nil) otherButtonTitles:nil];
        [alertView show];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if([fileManager fileExistsAtPath:[CodingUtil techLineDataDirectoryPath]]    ){
            [fileManager removeItemAtPath:[CodingUtil techLineDataDirectoryPath] error:nil];
        }
    }
    
}
@end
