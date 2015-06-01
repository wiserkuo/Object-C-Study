//
//  ShopInfoViewController.m
//  Bullseye
//
//  Created by Neil on 13/8/29.
//
//

#import "ShopInfoViewController.h"
#import "UIViewController+CustomNavigationBar.h"

@interface ShopInfoViewController ()

@property (strong, nonatomic) UIWebView * shopInfoWebView;

@end

@implementation ShopInfoViewController

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
    
    self.navigationItem.title = NSLocalizedStringFromTable(@"門市據點", @"Launcher", nil);
    
    self.shopInfoWebView = [[UIWebView alloc] init];
    _shopInfoWebView.translatesAutoresizingMaskIntoConstraints = NO;
    NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:@ "https://www.fonestock.com/smart/service.php"]];
    
    [self.view addSubview:_shopInfoWebView];
    
    [_shopInfoWebView loadRequest:request];
    
    [self.view setNeedsUpdateConstraints];

	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setUpImageBackButton];
    [self.navigationController setNavigationBarHidden:NO];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)updateViewConstraints {
   
    [self.view removeConstraints:self.view.constraints];
    
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_shopInfoWebView);
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_shopInfoWebView]|" options:0 metrics:nil views:viewControllers]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_shopInfoWebView]|" options:0 metrics:nil views:viewControllers]];
     [super updateViewConstraints];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
