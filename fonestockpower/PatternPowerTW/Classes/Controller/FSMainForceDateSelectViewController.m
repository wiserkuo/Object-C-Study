//
//  FSMainForceDateSelectViewController.m
//  FonestockPower
//
//  Created by Derek on 2014/8/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSMainForceDateSelectViewController.h"
#import "UIView+NewComponent.h"
#import "FSMainForceViewController.h"

@interface FSMainForceDateSelectViewController (){
    FSUIButton *todayButton;
    FSUIButton *fiveDayButton;
    FSUIButton *tenDayButton;
    FSUIButton *twentyDayButton;
    FSUIButton *okButton;
    
    UILabel *titleLabel;
    UILabel *messageLabel;
}

@end

@implementation FSMainForceDateSelectViewController

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
	// Do any additional setup after loading the view.
    [self.navigationController setNavigationBarHidden:YES];
    
    [self constructUIComponents];
    [self processLayout];
    [self initData];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData{
    if (_dayType == 0) {
        todayButton.selected = YES;
        messageLabel.text = NSLocalizedStringFromTable(@"由最近日期算起1天內", @"", @"");
    }else if (_dayType == 1){
        fiveDayButton.selected = YES;
        messageLabel.text = NSLocalizedStringFromTable(@"由最近日期算起5天內", @"", @"");
    }else if (_dayType == 2){
        tenDayButton.selected = YES;
        messageLabel.text = NSLocalizedStringFromTable(@"由最近日期算起10天內", @"", @"");
    }else if (_dayType == 3){
        twentyDayButton.selected = YES;
        messageLabel.text = NSLocalizedStringFromTable(@"由最近日期算起20天內", @"", @"");
    }
}

- (void)constructUIComponents {
    todayButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [todayButton setTitle:NSLocalizedStringFromTable(@"當日", @"", @"") forState:UIControlStateNormal];
    todayButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [todayButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    fiveDayButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [fiveDayButton setTitle:NSLocalizedStringFromTable(@"5日", @"", @"") forState:UIControlStateNormal];
    fiveDayButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [fiveDayButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    tenDayButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [tenDayButton setTitle:NSLocalizedStringFromTable(@"10日", @"", @"") forState:UIControlStateNormal];
    tenDayButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [tenDayButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    twentyDayButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [twentyDayButton setTitle:NSLocalizedStringFromTable(@"20日", @"", @"") forState:UIControlStateNormal];
    twentyDayButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [twentyDayButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    okButton = [self.view newButton:FSUIButtonTypeNormalRed];
    [okButton setTitle:NSLocalizedStringFromTable(@"確定", @"", @"") forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
    [okButton addTarget:self action:@selector(backtoViewController) forControlEvents:UIControlEventTouchUpInside];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor brownColor];
    titleLabel.font = [UIFont systemFontOfSize:20.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = NSLocalizedStringFromTable(@"選擇資料期間", @"", @"");
    [self.view addSubview:titleLabel];
    
    messageLabel = [[UILabel alloc] init];
    messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    messageLabel.backgroundColor = [UIColor clearColor];
    messageLabel.textColor = [UIColor brownColor];
    messageLabel.font = [UIFont systemFontOfSize:20.0f];
    messageLabel.text = NSLocalizedStringFromTable(@"由最近日期算起1天內", @"", @"");
    [self.view addSubview:messageLabel];
}

-(void)backtoViewController{
    _data.dayType = _dayType;
    _dataBroker.dayType = _dayType;
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)processLayout {
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(titleLabel, messageLabel, todayButton, fiveDayButton, tenDayButton, twentyDayButton, okButton);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[titleLabel]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[messageLabel]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[todayButton][fiveDayButton(todayButton)][tenDayButton(fiveDayButton)][twentyDayButton(tenDayButton)]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[okButton]-60-|" options:0 metrics:nil views:viewControllers]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[titleLabel][messageLabel][todayButton]-5-[okButton]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[titleLabel][messageLabel][fiveDayButton]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[titleLabel][messageLabel][tenDayButton]" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[titleLabel][messageLabel][twentyDayButton]" options:0 metrics:nil views:viewControllers]];
}

-(void)buttonClick:(UIButton *)btn{
    todayButton.selected = NO;
    fiveDayButton.selected = NO;
    tenDayButton.selected = NO;
    twentyDayButton.selected = NO;
    if ([btn isEqual:todayButton]) {
        _dayType = 0;
        todayButton.selected = YES;
        messageLabel.text = NSLocalizedStringFromTable(@"由最近日期算起1天內", @"", @"");
    }else if ([btn isEqual:fiveDayButton]){
        _dayType = 1;
        fiveDayButton.selected = YES;
        messageLabel.text = NSLocalizedStringFromTable(@"由最近日期算起5天內", @"", @"");
    }else if ([btn isEqual:tenDayButton]){
        _dayType = 2;
        tenDayButton.selected = YES;
        messageLabel.text = NSLocalizedStringFromTable(@"由最近日期算起10天內", @"", @"");
    }else if ([btn isEqual:twentyDayButton]){
        _dayType = 3;
        twentyDayButton.selected = YES;
        messageLabel.text = NSLocalizedStringFromTable(@"由最近日期算起20天內", @"", @"");
    }
}

@end
