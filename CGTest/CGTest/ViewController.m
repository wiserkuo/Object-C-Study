//
//  ViewController.m
//  CGTest
//
//  Created by Wiser on 2015/5/20.
//  Copyright (c) 2015年 Wiser. All rights reserved.
//

#import "ViewController.h"
#import "CGView.h"
#import "CustomIOS7AlertView.h"
@interface ViewController ()<CustomIOS7AlertViewDelegate>{

    CGView *mainView;
    CustomIOS7AlertView *hintAlertView;
}
//@property (nonatomic, strong) FSUIButton *checkBtn;
@property (nonatomic, strong) UILabel *checkLabel;
@property (nonatomic, strong) UIView *checkView;
@end


@implementation ViewController

-(void)initView
{
    mainView  = [[CGView alloc]init];
    mainView.backgroundColor = [UIColor grayColor];
    mainView.layer.borderWidth =0.5f;
    [mainView setFrame:CGRectMake(0, 0, self.view.frame.size.width , self.view.frame.size.height)];
    [self.view addSubview:mainView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initView];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showHint];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // [self saveHandler];
    [hintAlertView close];
}
- (void)showHint

{
    //  UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapCheckBox)];
    hintAlertView = [[CustomIOS7AlertView alloc]init];
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 40, self.view.frame.size.width-30, 50)];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.view.frame.size.width-30, 40)];
    label.textAlignment = NSTextAlignmentLeft;
    [label setNumberOfLines:0];
    label.lineBreakMode =NSLineBreakByWordWrapping;
    label.text = NSLocalizedStringFromTable(@"請由右往左開始編輯一到五根K棒", @"FigureSearch", nil);
    [hintAlertView setTitleLabel:label];
    [hintAlertView setContainerView:view];
    [hintAlertView setButtonTitles:@[NSLocalizedStringFromTable(@"確定", @"FigureSearch", nil)]];
    hintAlertView.delegate = self;
   /*
     self.checkView = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height, 300, 44)];
     
     _checkView.backgroundColor = [UIColor whiteColor];
     
     _checkView.userInteractionEnabled = YES;
     
    // [_checkView addGestureRecognizer:tapGestureRecognizer];
     
     [view addSubview:_checkView];
     
     
     
     self.checkLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 300, 44)];
     
     _checkLabel.text = NSLocalizedStringFromTable(@"Do Not Sort", @"watchlists", nil);
     
     [_checkView addSubview:_checkLabel];
     
     
     
     //self.checkBtn = [[ alloc] initWithButtonType:FSUIButtonTypeCheckBox];
     
     //_checkBtn.selected =[[_mainDict objectForKey:@"Check"]boolValue];
     
     //sortFlag = _checkBtn.selected;
     
     [self.checkBtn addTarget:self action:@selector(tapCheckBox) forControlEvents:UIControlEventTouchUpInside];
     
     _checkBtn.frame = CGRectMake(245, 0, 30, 37);
     
     [_checkView addSubview:_checkBtn];
*/
    
    
    //[view addSubview:_actionTableView];
    
    
    
    [hintAlertView show];
    
}
-(void)tapCheckBox
{
    /*if(_checkBtn.selected){
        _checkBtn.selected = NO;
    }else{
        _checkBtn.selected = YES;
        
    }*/
    
}
@end
