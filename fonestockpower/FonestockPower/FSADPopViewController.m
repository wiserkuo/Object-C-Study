//
//  FSADPopViewController.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/2/5.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSADPopViewController.h"
#import "FSADResultViewController.h"
#import "ADSystem.h"

@interface FSADPopViewController (){
    FSShowResultAdObj *AdObj;
}

@property UIButton *closeBtn;

@end

@implementation FSADPopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)initView
{
    ADSystem *adSystem = [[ADSystem alloc]init];
    UIImage *image;
    if ([[adSystem getLoaclAdPlist] firstObject] != nil) {
        AdObj = [[[adSystem getLoaclAdPlist] objectAtIndex:0] objectAtIndex:0];
        image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/ADImage/Index.png",[CodingUtil fonestockDocumentsPath]]];
    }
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = self.view.frame;

    image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1070, 640, 0, 640)];
    imageView.image = image;
    imageView.userInteractionEnabled = YES;
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _closeBtn.layer.masksToBounds = NO;
    _closeBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _closeBtn.layer.borderWidth = 2.5f;
    _closeBtn.frame = CGRectMake(self.view.frame.size.width - 40, 30, 30, 30);
    _closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    _closeBtn.backgroundColor = [UIColor redColor];
    _closeBtn.layer.shadowColor = [UIColor blackColor].CGColor;
    _closeBtn.layer.shadowOpacity = 0.5;
    _closeBtn.layer.shadowRadius = 3;
    _closeBtn.layer.shadowOffset = CGSizeMake(0.0f,1.0f);
    
    [_closeBtn.layer setCornerRadius:15];
    [_closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [_closeBtn addTarget:self action:@selector(cancelBtn) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:_closeBtn];

    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    UIView *checkView;
    if ([group isEqualToString:@"us"]){
        checkView = [[UIView alloc]initWithFrame:CGRectMake(10, self.view.frame.size.height - 80, 300, 80)];
    }else{
        checkView = [[UIView alloc]initWithFrame:CGRectMake(70, self.view.frame.size.height - 80, 300, 80)];
    }
    
    FSUIButton * checkBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
    [checkBtn setFrame:CGRectMake(0, 0, 40, 40)];
    [checkBtn addTarget:self action:@selector(checkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [checkView addSubview:checkBtn];
    
    UILabel * alertLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 0, 260, 40)];
    alertLabel.backgroundColor  = [UIColor clearColor];
    alertLabel.text = NSLocalizedStringFromTable(@"下次不顯示此訊息",@"DivergenceTips",nil);
    [checkView addSubview:alertLabel];
    
    [imageView addSubview:checkView];
    
    [self.view addSubview:imageView];
}

-(void)checkBtnClick:(FSUIButton*)btn{

    btn.selected = !btn.selected;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:btn.selected forKey:@"isFirstDivergenceTipsADCeck"];
    [userDefaults synchronize];
}

-(void)cancelBtn{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
-(void)tapGesture:(id)sender{
    FSADResultViewController *nextView = [[FSADResultViewController alloc]initWithAdUrl:AdObj.uri];
    [self presentViewController:nextView animated:NO completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
