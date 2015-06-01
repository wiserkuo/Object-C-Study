//
//  FSRootPaymentViewController.m
//  FSRootPayment
//
//  Created by Michael.Hsieh on 2015/1/21.
//  Copyright (c) 2015年 Michael. All rights reserved.
//

#import "FSRootPaymentViewController.h"
#import "FSPaymentViewController.h"



@interface FSRootPaymentViewController (){
    
    UILabel *mainLabel;
    UIImageView *mainImage;
    FSUIButton *purchaseBtn;
}

@end

@implementation FSRootPaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
}
-(void)initView{
    [self setUpImageBackButton];
    
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    NSMutableAttributedString *attStr;
    NSMutableParagraphStyle *paragraphStyleCenter;
    NSRange titleRange1;
    NSRange titleRange2;
    NSRange titleRange3;
    NSRange mainRange;
    NSRange lastRange;
    
    mainLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, self.view.frame.size.height - 190, self.view.frame.size.width - 10, 120)];
    
    mainLabel.backgroundColor = [UIColor colorWithRed:0.7294 green:0.4745 blue:0.6941 alpha:1.0];
    mainLabel.layer.cornerRadius = 15;
    mainLabel.numberOfLines = 0;
    mainLabel.layer.masksToBounds = YES;
    mainLabel.userInteractionEnabled = YES;
    
    [self.view addSubview:mainLabel];
    
    purchaseBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeNormalRed];

    [purchaseBtn addTarget:self action:@selector(goShopping) forControlEvents:UIControlEventTouchUpInside];
    [mainLabel addSubview:purchaseBtn];
    
    mainImage = [[UIImageView alloc]initWithFrame:CGRectMake(40, 5, self.view.frame.size.width - 60, self.view.frame.size.height - mainLabel.frame.size.height - 80 )];
    mainImage.backgroundColor = [UIColor brownColor];
    [mainImage setContentMode:UIViewContentModeScaleToFill];
    [self.view addSubview:mainImage];
    
    if ([group isEqualToString:@"us"]){
        self.title = @"Divergence Tips";
        
        attStr = [[NSMutableAttributedString alloc]initWithString:@"   \t\tOnly $1.99/Month\n・Observe divergences with trends and patterns for decisive timing signals.\n・No advertisement interruption.\n   Thank you for your support"];
        paragraphStyleCenter = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyleCenter setAlignment:NSTextAlignmentCenter];
        
        titleRange1 = NSMakeRange([@"   \t\t" length], [@"Only" length]);
        titleRange2 = NSMakeRange([@"   \t\tOnly " length], [@"$1.99" length]);
        titleRange3 = NSMakeRange([@"   \t\tOnly $1.99" length], [@"/Month" length]);
        
        mainRange = NSMakeRange([@"   \t\tOnly $1.99/Month" length] , [@"・Observe divergences with trends and patterns for decisive timing signals.\n・No advertisement interruption. " length]);
        lastRange = NSMakeRange([attStr length] -[@"Thank you for your support" length] , [@"Thank you for your support" length]);
        
        [mainImage setImage:[UIImage imageNamed:@"背離小秘-K線圖.jpg"]];
        purchaseBtn.frame = CGRectMake(185, 95, 115, 27);
        purchaseBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        [purchaseBtn setTitle:@"Subscribe Now" forState:UIControlStateNormal];
    }else{
        self.title = @"背離小秘";
        
        attStr = [[NSMutableAttributedString alloc]initWithString:@"\t\t\t只要 $60 /月\n・背離搭配Ｋ線趨勢以及最近型態，快速精確掌握轉折契機。\n・無廣告干擾。\n   感謝您的支持"];
        paragraphStyleCenter = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyleCenter setAlignment:NSTextAlignmentCenter];
        
        titleRange1 = NSMakeRange([@"\t\t\t" length], [@"只要" length]);
        titleRange2 = NSMakeRange([@"\t\t\t只要 " length], [@"$60" length]);
        titleRange3 = NSMakeRange([@"\t\t\t只要 $60 " length], [@"/月" length]);
        
        mainRange = NSMakeRange([@"\t\t\t只要 $60 /月" length], [@"・背離搭配Ｋ線趨勢以及最近型態，快速精確掌握轉折契機。\n・無廣告干擾。\n" length]);
        lastRange = NSMakeRange([attStr length] -[@"感謝您的支持" length], [@"感謝您的支持" length]);
        
        [mainImage setImage:[UIImage imageNamed:@"背離小秘-K線圖.jpg"]];
        purchaseBtn.frame = CGRectMake(185, 85, 115, 35);
        purchaseBtn.titleLabel.font = [UIFont boldSystemFontOfSize:20.0f];
        [purchaseBtn setTitle:@"立刻訂閱" forState:UIControlStateNormal];
    }

    
//    titleFont
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:titleRange1];
    [attStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:22.0f] range:titleRange1];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:titleRange3];
    [attStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:22.0f] range:titleRange3];
    
    [attStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:35.0f] range:titleRange2];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:titleRange2];
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyleCenter range:titleRange2];

//    mainFont
    NSMutableParagraphStyle *paragraphStyleLeft = [[NSMutableParagraphStyle alloc]init];

    paragraphStyleLeft.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyleLeft.headIndent = 15.0;
    paragraphStyleLeft.lineSpacing = -3;

    [attStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:15.0] range:mainRange];
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyleLeft range:mainRange];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:mainRange];

//    lastFont
    [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:lastRange];
    [attStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyleLeft range:lastRange];
    
    [mainLabel setAttributedText:attStr];
    
}

-(void)goShopping
{
    FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
    FSFonestock *fonestock = [FSFonestock sharedInstance];

    NSString *paymentFullURL = [NSString stringWithFormat:@"%@?acc_id=%@&app_id=%@&lang=%@&request_iap=1&forapp=1", fonestock.paymentPageURL, loginService.account, fonestock.appId, fonestock.lang];

    FSPaymentViewController *paymentWebView = [[FSPaymentViewController alloc] initWithPaymentURL:paymentFullURL];

    [self.navigationController pushViewController:paymentWebView animated:NO];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
