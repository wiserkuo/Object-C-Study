//
//  FSUIViewController.m
//  FonestockPower
//
//  Created by Connor on 2014/11/12.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSUIViewController.h"
#import "FSLineActivity.h"
#import "FSFaceBookActivity.h"
#import <Social/Social.h>


@interface FSUIViewController () {
    NSMutableArray *layoutConstraints;
    
}
@end

@implementation FSUIViewController

- (instancetype)init {
    if (self = [super init]) {
        layoutConstraints = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(motionEnded:withEvent:)];
    
//    FSFonestock *fonestock =
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    dataModel.fonestock.currentViewController = self;

//    UIImage *menuButtonImage = [UIImage imageNamed:@"分享"];
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setImage:menuButtonImage forState:UIControlStateNormal];
//    [button addTarget:self action:@selector(motionEnded:withEvent:) forControlEvents:UIControlEventTouchUpInside];
//    button.frame = CGRectMake(0, 0, 25, 25);
    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:button];
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    [itemArray addObject:item];
    [itemArray addObjectsFromArray:self.navigationItem.rightBarButtonItems];
    [self.navigationItem setRightBarButtonItems:itemArray];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version>=8.0f) {
        NSString *string = @"圖示力能夠讓我能有效的找到標的";
        UIImage *image = [self getImageFromView:[[UIApplication sharedApplication] keyWindow]];
        NSArray *activityItems = @[string, image];
        NSArray *applicationActivities = @[[[FSFaceBookActivity alloc] init], [[FSLineActivity alloc] init]];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
        activityViewController.excludedActivityTypes = @[UIActivityTypeCopyToPasteboard, UIActivityTypeSaveToCameraRoll, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeAirDrop, UIActivityTypePostToFacebook];
        [self presentViewController:activityViewController animated:YES completion:NULL];
    }else{
        [self shareScreenToFB:[[UIApplication sharedApplication] keyWindow]];
    }
}

- (void)shareScreenToFB:(UIView *)screenView {
    
    //建立對應社群網站的ComposeViewController
    SLComposeViewController *mySocialComposeView = [[SLComposeViewController alloc] init];
    mySocialComposeView = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    mySocialComposeView.completionHandler = ^(SLComposeViewControllerResult result) {
        switch(result) {
                //  This means the user cancelled without sending the Tweet
            case SLComposeViewControllerResultCancelled:
                break;
                //  This means the user hit 'Send'
            case SLComposeViewControllerResultDone: {
                NSString *account = [[FSDataModelProc sharedInstance] loginService].account;
                NSURLRequest *requset = [[[FSDataModelProc sharedInstance] signupModel] fbSharedRequestWithAccount:account];
                [NSURLConnection sendAsynchronousRequest:requset queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (!connectionError) {
                        NSError *jsonParseError;
                        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParseError];
                        if (!jsonParseError) {
                            NSString *status = [jsonDict objectForKey:@"status"];
                            if ([@"shar.ok" isEqualToString:status]) {
                                [[[FSDataModelProc sharedInstance] loginService] loginAuthUsingSelfAccount];
                                [[[UIAlertView alloc] initWithTitle:@"" message:@"FB分享成功,謝謝您的分享,神乎贈送一天圖是力(一天一次)" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles: nil] show];
//                                [SGInfoAlert showInfo:@"FB分享成功,謝謝您的分享,神乎贈送一天圖是力(一天一次)" bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:[[UIApplication sharedApplication] keyWindow]];
                            }
                            else {
                                [[[UIAlertView alloc] initWithTitle:@"" message:@"FB分享成功,謝謝您的分享" delegate:nil cancelButtonTitle:@"確認" otherButtonTitles: nil] show];
//                                [SGInfoAlert showInfo:@"FB分享成功,謝謝您的分享" bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:[[UIApplication sharedApplication] keyWindow]];
                            }
                        }
                    }
                }];
                break;
            }
        }
    };
    
    //插入文字
    [mySocialComposeView setInitialText:@""];
    
    //插入網址
    NSURL *myURL = [[NSURL alloc] initWithString:@"http://www.fonestock.com/"];
    [mySocialComposeView addURL: myURL];
    
    
    //插入圖片
    UIImage *myImage = [self getImageFromView:screenView];
    [mySocialComposeView addImage:myImage];
    
    //呼叫建立的SocialComposeView
    [self presentViewController:mySocialComposeView animated:YES completion:^{
        NSLog(@"成功呼叫 SocialComposeView ");
    }];
}

- (UIImage *)getImageFromView:(UIView *)orgView{
    UIGraphicsBeginImageContext(orgView.bounds.size);
    [orgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

/*
 
 支援iOS8 autolayout
 
 */
- (void)addCustomizeConstraints:(NSArray *)newConstraints {
    [layoutConstraints addObjectsFromArray:newConstraints];
    [self.view addConstraints:layoutConstraints];
}

- (void)removeCustomizeConstraints {
    [self.view removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
}

- (void)replaceCustomizeConstraints:(NSArray *)newConstraints {
    [self removeCustomizeConstraints];
    [self addCustomizeConstraints:newConstraints];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

@end
