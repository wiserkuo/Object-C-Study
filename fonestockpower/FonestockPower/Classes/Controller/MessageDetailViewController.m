//
//  MessageDetailViewController.m
//  Bullseye
//
//  Created by Neil on 13/8/29.
//
//

#import "MessageDetailViewController.h"

@interface MessageDetailViewController ()

@property (strong, nonatomic) UITextView * detailText;
@property (strong,nonatomic) NSString * contentText;

@end

@implementation MessageDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)initWithTitle:(NSString *)title content:(NSString *)c{
    
    self.navigationItem.title = title;
    _contentText = c;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.hidesBackButton = YES;
    
    UIBarButtonItem * leftButton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedStringFromTable(@"返回", @"VIPMessage", nil) style:UIBarButtonItemStylePlain target:self action:@selector(backView)];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    self.detailText =[[UITextView alloc]init];
    
    _detailText.Text=_contentText;
    _detailText.font = [UIFont systemFontOfSize:20];
    _detailText.editable = NO;
    [self.view addSubview:_detailText];
    
    CGRect frame = self.view.frame;
    frame.size.height = frame.size.height-89.0f;
    frame.origin.y = 0.0f;
    _detailText.frame = frame;

    
    
	// Do any additional setup after loading the view.
}


-(void)backView{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
