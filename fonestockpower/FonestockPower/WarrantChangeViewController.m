//
//  WarrantChangeViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/9/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "WarrantChangeViewController.h"
#import "WarrantCollectionView.h"
#import "WarrantSearchViewController.h"

@interface WarrantChangeViewController ()<UITextFieldDelegate, SecuritySearchDelegate>
{
    FSUIButton *countryButton;
    UITextField *inputText;
    FSUIButton *searchButton;
    WarrantCollectionView *warrantCollectionView;
    WarrantSearchViewController *searchStockView;
    NSString *stringV;
    NSString *stringH;
    NSMutableDictionary * objDictionary;
    UIView *rootView;
    WarrantViewController *warrantViewController;
}
@end

@implementation WarrantChangeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(id)initWithTarget:(WarrantViewController *)controller
{
    self = [super init];
    if(self){
        warrantViewController = controller;
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [warrantCollectionView willMoveToParentViewController:nil];
    
    [self transitionFromViewController:searchStockView toViewController:warrantCollectionView duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
        stringV = @"V:|[warrantCollectionView]|";
        stringH = @"H:|[warrantCollectionView]|";
        [self.view setNeedsUpdateConstraints];
    }];
}

-(void)initView
{
    objDictionary = [[NSMutableDictionary alloc]init];
    
    countryButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeDetailYellow];
    [countryButton addTarget:self action:@selector(changeWarrantCollectionView) forControlEvents:UIControlEventTouchUpInside];
    [countryButton setTitle:@"台灣" forState:UIControlStateNormal];
    countryButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:countryButton];
    
    inputText = [[UITextField alloc] init];
    inputText.placeholder = @"輸入代碼或名稱...";
    inputText.textAlignment = NSTextAlignmentCenter;
    [inputText addTarget:self action:@selector(search:) forControlEvents:UIControlEventEditingChanged];
    inputText.delegate = self;
    inputText.layer.borderWidth = 1;
    inputText.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:inputText];
    
    searchButton = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];
    [searchButton addTarget:self action:@selector(searchBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [searchButton setTitle:@"搜尋" forState:UIControlStateNormal];
    searchButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:searchButton];
    
    rootView = [[UIView alloc] init];
    rootView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:rootView];
    
    warrantCollectionView = [[WarrantCollectionView alloc] init];
    warrantCollectionView.warrantViewController = warrantViewController;
    warrantCollectionView.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self addChildViewController:warrantCollectionView];
    [objDictionary setObject:warrantCollectionView.view forKey:@"warrantCollectionView"];
    [rootView addSubview:warrantCollectionView.view];
    
    stringV = @"V:|[warrantCollectionView]|";
    stringH = @"H:|[warrantCollectionView]|";
    
    searchStockView = [[WarrantSearchViewController alloc]init];
    searchStockView.view.translatesAutoresizingMaskIntoConstraints = NO;
    searchStockView.delegate = self;
    [self addChildViewController:searchStockView];
    [objDictionary setObject:searchStockView.view forKey:@"searchStockView"];
    [rootView addSubview:searchStockView.view];
    
    [self processLayout];
    [self setRootViewAutoLayout];
}

-(void)search:(UITextField *)textField{
    
    FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
    [dataModal.securitySearchModel setTarget:self];
    if (![textField.text isEqual:@""]) {
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"SecuritySearch", nil)];
        [dataModal.securitySearchModel performSelector:@selector(searchWarrantStockWithName:) onThread:dataModal.thread withObject:textField.text waitUntilDone:NO];
        searchStockView.noStockLabel.hidden = YES;
    }else{
        [searchStockView.data1Array removeAllObjects];
        [searchStockView setData1Array:searchStockView.data1Array];
        [searchStockView reloadButton];
    }
    [self.view setNeedsUpdateConstraints];
}

-(void)searchBtnClick{
    [inputText resignFirstResponder];
    if (![inputText.text isEqual:@""]) {
        FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
        [dataModal.securitySearchModel setTarget:self];
        [dataModal.securitySearchModel performSelector:@selector(searchStockFromServerWithName:) onThread:dataModal.thread withObject:inputText.text waitUntilDone:NO];
        [self.view showHUDWithTitle:NSLocalizedStringFromTable(@"搜尋中", @"SecuritySearch", nil)];
    }
}

-(void)notifyDataArrive:(NSMutableArray *)array{
    [searchStockView setData1Array:[array objectAtIndex:0]];
    [searchStockView setDataIdArray:[array objectAtIndex:1]];
    [searchStockView reloadButton];
    
    if ([[array objectAtIndex:0]count]==0) {
        searchStockView.noStockLabel.hidden = NO;
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view hideHUD];
}

-(void)notifyArrive:(NSMutableArray *)array
{
    [searchStockView setData1Array:[array objectAtIndex:0]];
    [searchStockView setDataIdArray:[array objectAtIndex:1]];
    [searchStockView reloadButton];
    
    if ([[array objectAtIndex:0]count]==0) {
        searchStockView.noStockLabel.hidden = NO;
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view hideHUD];
}

-(void)processLayout
{
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(countryButton, inputText, searchButton, rootView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[countryButton(44)][inputText(33)][rootView]|" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[countryButton]" options:0 metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[inputText]-3-[searchButton(60)]|" options:NSLayoutFormatAlignAllCenterY metrics:nil views:viewDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[rootView]-3-|" options:0 metrics:nil views:viewDictionary]];
    
}

-(void)setRootViewAutoLayout
{
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:stringV options:0 metrics:nil views:objDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:stringH options:0 metrics:nil views:objDictionary]];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [searchStockView willMoveToParentViewController:nil];
    searchStockView.warrantViewController = warrantViewController;
    [self transitionFromViewController:warrantCollectionView toViewController:searchStockView duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
        stringV = @"V:|[searchStockView]|";
        stringH = @"H:|[searchStockView]|";
        [self setRootViewAutoLayout];
    }];
}

-(void)changeWarrantCollectionView
{
    [inputText resignFirstResponder];
    [warrantCollectionView willMoveToParentViewController:nil];
    [self transitionFromViewController:searchStockView toViewController:warrantCollectionView duration:0.0f options:UIViewAnimationOptionCurveLinear animations:^{} completion:^(BOOL finished){
        stringV = @"V:|[warrantCollectionView]|";
        stringH = @"H:|[warrantCollectionView]|";
        [self setRootViewAutoLayout];
    }];
}


@end
