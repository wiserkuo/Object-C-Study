//
//  VersionViewController.m
//  Bullseye
//
//  Created by Neil on 13/8/28.
//
//

#import "VersionViewController.h"

@interface VersionViewController ()

@property (strong, nonatomic) UILabel * buildLabel;
@property (strong, nonatomic) UILabel * dateLabel;
@property (strong, nonatomic) UILabel * electricLabel;
@property (strong, nonatomic) UIImageView * logoImg;
@property (strong, nonatomic) UILabel * welcomeLabel;
@property (strong, nonatomic) UILabel * versionLabel;
@property (strong, nonatomic) UILabel * infoLabel;


@end

@implementation VersionViewController


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
    self.navigationItem.title =NSLocalizedStringFromTable(@"版本資訊", @"Version", nil);
    self.view.backgroundColor = [UIColor blackColor];
    
    self.buildLabel = [[UILabel alloc]init];
    _buildLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *path =[[NSBundle mainBundle] infoDictionary ];
    NSString * buildNumber = [path objectForKey:@"CFBundleVersion"];
    _buildLabel.text =[NSString stringWithFormat:@"Build %@",buildNumber];
    _buildLabel.backgroundColor = [UIColor blackColor];
    _buildLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:_buildLabel];

    
    
//    NSDate* date = [NSDate date];
//    NSDateFormatter* formatter = [[NSDateFormatter alloc] init] ;
//    [formatter setDateFormat:@"yyyy/MM/dd"];
//    NSString* dateStr = [formatter stringFromDate:date];
    
    self.dateLabel = [[UILabel alloc]init];
    _dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _dateLabel.text = @"2013/08/19";
    _dateLabel.backgroundColor = [UIColor blackColor];
    _dateLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:_dateLabel];

    
    UIDevice *myDevice = [UIDevice currentDevice];
    [myDevice setBatteryMonitoringEnabled:YES];
    float batteryLevel = [myDevice batteryLevel];
    
    self.electricLabel = [[UILabel alloc]init];
    _electricLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _electricLabel.backgroundColor = [UIColor blackColor];
    _electricLabel.textColor=[UIColor whiteColor];
    _electricLabel.text = [NSString stringWithFormat:@"%@:%.0f%%",NSLocalizedStringFromTable(@"電力", @"Version", nil),batteryLevel*100];
    
    [self.view addSubview:_electricLabel];
    
    
    self.logoImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    _logoImg.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_logoImg];
    
    self.welcomeLabel = [[UILabel alloc]init];
    _welcomeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _welcomeLabel.text = NSLocalizedStringFromTable(@"歡迎使用免費力", @"Version", nil);
    _welcomeLabel.backgroundColor = [UIColor blackColor];
    _welcomeLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:_welcomeLabel];
    
    self.versionLabel = [[UILabel alloc]init];
    _versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSString * shortVersion = [path objectForKey:@"CFBundleShortVersionString"];
    _versionLabel.text =[NSString stringWithFormat:@"%@: V%@",NSLocalizedStringFromTable(@"版本", @"Version", nil),shortVersion];
    _versionLabel.backgroundColor = [UIColor blackColor];
    _versionLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:_versionLabel];
    
    self.infoLabel = [[UILabel alloc]init];
    _infoLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _infoLabel.numberOfLines = 2;
    _infoLabel.font =[UIFont systemFontOfSize:12];
    _infoLabel.text =NSLocalizedStringFromTable(@"提醒", @"Version", nil);
    _infoLabel.backgroundColor = [UIColor blackColor];
    _infoLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:_infoLabel];
    
    [self.view setNeedsUpdateConstraints];
    
	// Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    UIDevice *myDevice = [UIDevice currentDevice];
    myDevice.batteryMonitoringEnabled = YES;
    float batteryLevel = [myDevice batteryLevel];
    _electricLabel.text = [NSString stringWithFormat:@"%@:%.0f%%",NSLocalizedStringFromTable(@"電力", @"Version", nil),batteryLevel*100];
}

- (void)updateViewConstraints {
    
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_buildLabel,_dateLabel,_logoImg,_welcomeLabel,_versionLabel,_infoLabel);
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_buildLabel][_dateLabel(88)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewControllers]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_buildLabel(20)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_electricLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:_dateLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_electricLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_dateLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_logoImg attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual  toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_logoImg attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual  toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-200]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_welcomeLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual  toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_welcomeLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual  toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-150]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_versionLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual  toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_versionLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:_welcomeLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_logoImg]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_logoImg(148)]" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_infoLabel]|" options:0 metrics:nil views:viewControllers]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_infoLabel(50)]|" options:0 metrics:nil views:viewControllers]];
    
    [super updateViewConstraints];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
