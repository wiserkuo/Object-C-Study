//
//  FSAccountSettingViewController.m
//  FonestockPower
//
//  Created by Connor on 14/4/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSAccountSettingViewController.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FSUIButton.h"
#import "FigureSearchMyProfileModel.h"


@interface FSAccountSettingViewController (){
    BOOL show;
}
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UIView *bottomView;
@property (strong, nonatomic) UILabel *learnLabel;
@property (strong, nonatomic) UILabel *operateLabel;
@property (strong, nonatomic) UILabel *versionLabel;
@property (strong, nonatomic) UILabel *versionDetailLabel;
@property (strong, nonatomic) UILabel *copyrightLabel;
@property (strong, nonatomic) UITextView *copyrightText;
@property (strong, nonatomic) FSUIButton *gotoBtn;
@property (strong, nonatomic) UISwitch *switchBtn;
@property (strong, nonatomic) FigureSearchMyProfileModel *profileModel;
@end

@implementation FSAccountSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpImageBackButton];
    self.title = NSLocalizedStringFromTable(@"設定", @"AccountSetting", nil);
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self addContent1];
    [self addContent2];
    
    [self processLayout];
}

- (void)addContent1 {
    
    self.topView = [[UIView alloc] init];
    _topView.translatesAutoresizingMaskIntoConstraints=NO;
    [_topView.layer setBorderWidth:1.5f];
    [self.view addSubview:_topView];
    
    //    self.learnLabel = [[UILabel alloc] init];
    //    _learnLabel.text=NSLocalizedStringFromTable(@"線上教學", @"AccountSetting", nil);
    //    _learnLabel.font = [UIFont boldSystemFontOfSize:18.0];
    //    _learnLabel.translatesAutoresizingMaskIntoConstraints=NO;
    //    [_topView addSubview:_learnLabel];
    
    self.operateLabel = [[UILabel alloc] init];
    _operateLabel.text=NSLocalizedStringFromTable(@"操作導覽", @"AccountSetting", nil);
    _operateLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _operateLabel.translatesAutoresizingMaskIntoConstraints=NO;
//    [_topView addSubview:_operateLabel];
    
    //    self.gotoBtn = [[SKCustomButton alloc]initWithButtonType:FSCustomButtonTypeNormalRed];
    //    [_gotoBtn setTitle:NSLocalizedStringFromTable(@"前往", @"AccountSetting", nil) forState:UIControlStateNormal];
    //    _gotoBtn.translatesAutoresizingMaskIntoConstraints=NO;
    //    [_gotoBtn addTarget:self action:@selector(gotoHandler) forControlEvents:UIControlEventTouchUpInside];
    //    [_topView addSubview:_gotoBtn];
    
    self.versionLabel = [[UILabel alloc] init];
    _versionLabel.text=NSLocalizedStringFromTable(@"版本資訊", @"AccountSetting", nil);
    _versionLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _versionLabel.translatesAutoresizingMaskIntoConstraints=NO;
    [_topView addSubview:_versionLabel];
    
    self.versionDetailLabel = [[UILabel alloc] init];
    
    _versionDetailLabel.text= [FSFonestock appFullVersion];
    _versionDetailLabel.font = [UIFont boldSystemFontOfSize:18.0];
    _versionDetailLabel.translatesAutoresizingMaskIntoConstraints=NO;
    [_topView addSubview:_versionDetailLabel];
    
    
    self.switchBtn = [[UISwitch alloc] init];
    
    _switchBtn.translatesAutoresizingMaskIntoConstraints=NO;
    [_switchBtn addTarget:self action:@selector(switchHandler) forControlEvents:UIControlEventTouchUpInside];
    
    self.profileModel = [[FigureSearchMyProfileModel alloc] init];
    show = [_profileModel searchInstruction];
    
    if(show){
        [_switchBtn setOn:YES];
        _switchBtn.enabled=NO;
    }else{
        [_switchBtn setOn:NO];
    }
    
//    [_topView addSubview:_switchBtn];
    
    
}

- (void)addContent2 {
    self.bottomView = [[UIView alloc] init];
    _bottomView.translatesAutoresizingMaskIntoConstraints=NO;
    [_bottomView.layer setBorderWidth:1.5f];
    [self.view addSubview:_bottomView];
    
    self.copyrightLabel = [[UILabel alloc] init];
    _copyrightLabel.textAlignment = NSTextAlignmentCenter;
    _copyrightLabel.text = NSLocalizedStringFromTable(@"服務說明/版權宣告", @"AccountSetting", nil);
    _copyrightLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:18.0f];
    
    _copyrightLabel.translatesAutoresizingMaskIntoConstraints=NO;
    [_bottomView addSubview:_copyrightLabel];
    
    self.copyrightText = [[UITextView alloc] init];
    self.copyrightText.editable = NO;
    self.copyrightText.bounces = NO;
    
    
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if(version >= 7.0f){
        NSString * htmlString =  NSLocalizedStringFromTable(@"服務內容", @"AccountSetting", nil);
        NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        _copyrightText.attributedText = attributedString;
    }else{
        _copyrightText.font = [UIFont boldSystemFontOfSize:18.0f];
        _copyrightText.text =NSLocalizedStringFromTable(@"服務內容ios6", @"AccountSetting", nil);
    }
    _copyrightText.editable=NO;
    _copyrightText.translatesAutoresizingMaskIntoConstraints=NO;
    _copyrightText.textAlignment = NSTextAlignmentNatural;
    [_bottomView addSubview:_copyrightText];
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}

- (void)processLayout {
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_topView,
                                                                   _bottomView, _versionLabel, _copyrightLabel,_copyrightText, _versionDetailLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_topView]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_bottomView]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[_topView(60)]-5-[_bottomView]|" options:0 metrics:nil views:viewControllers]];
    
    
//    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_operateLabel]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_versionLabel][_versionDetailLabel(70)]-10-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    
    [_topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[_versionLabel]" options:0 metrics:nil views:viewControllers]];
    
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_copyrightLabel]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[_copyrightText]-5-|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];
    [_bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-3-[_copyrightLabel(20)][_copyrightText]|" options:0 metrics:nil views:viewControllers]];
    
}

-(void)gotoHandler
{
//    NSString *url = @"http://www.fonestock.com";
//    TSMiniWebBrowser *webBrowser = [[TSMiniWebBrowser alloc] initWithUrl:[NSURL URLWithString:url]];
//    webBrowser.showActionButton = NO;
//    webBrowser.showReloadButton = YES;
//    webBrowser.mode = TSMiniWebBrowserModeNavigation;
//    webBrowser.barStyle = UIBarStyleDefault;
    
//    [self.navigationController pushViewController:webBrowser animated:YES];
    
    NSURL *url = [NSURL URLWithString:@"http://www.fonestock.com"];
    [[UIApplication sharedApplication] openURL:url];

}

-(void)switchHandler
{
    if([_switchBtn isOn]){
        [_profileModel setAllInstruction:@"YES"];
        show = [_profileModel searchInstruction];
        [_switchBtn setOn:YES];
        _switchBtn.enabled=NO;
    }
}

@end
