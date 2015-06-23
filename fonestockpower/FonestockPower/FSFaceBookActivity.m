//
//  FSFaceBookActivity.m
//  FonestockPower
//
//  Created by Derek on 2014/12/25.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSFaceBookActivity.h"
#import <Social/Social.h>


@implementation FSFaceBookActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryShare;
}

- (NSString *)activityType {
    return @"FaceBookActivity";
}

- (NSString *)activityTitle {
    return @"Facebook";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"FBActivityIcon"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[NSString class]] || [activityItem isKindOfClass:[NSURL class]] || [activityItem isKindOfClass:[UIImage class]]) {
            return YES;
        }
    }
    
    return NO;
}

-(void)performActivity{
    [self activityDidFinish:YES];
}

-(void)activityDidFinish:(BOOL)completed{
    [self shareScreenToFB:[[UIApplication sharedApplication] keyWindow]];
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
            case SLComposeViewControllerResultDone:{
                NSString *account = [[FSDataModelProc sharedInstance] loginService].account;
                NSURLRequest *requset = [[[FSDataModelProc sharedInstance] signupModel] fbSharedRequestWithAccount:account];
                
//                return;
                [NSURLConnection sendAsynchronousRequest:requset queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                    if (!connectionError) {
                        NSError *jsonParseError;
//                        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//                        NSLog(@"%@", str);
                        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&jsonParseError];
                        if (!jsonParseError) {
                            NSString *status = [jsonDict objectForKey:@"status"];
                            if ([@"shar.ok" isEqualToString:status]) {
                                [[[FSDataModelProc sharedInstance] loginService] loginAuthUsingSelfAccount];
//                                [SGInfoAlert showInfo:@"FB分享成功,謝謝您的分享,神乎贈送一天圖是力(一天一次)" bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:[[UIApplication sharedApplication] keyWindow]];
                                
//                                [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedStringFromTable(@"FB分享成功,謝謝您的分享,神乎贈送一天圖是力(一天一次)",@"Launcher",nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確認",@"Launcher",nil) otherButtonTitles: nil] show];
                                
                            }else{
//                                [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedStringFromTable(@"FB分享成功,謝謝您的分享",@"Launcher",nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確認",@"Launcher",nil) otherButtonTitles: nil] show];
//                                [SGInfoAlert showInfo:@"FB分享成功,謝謝您的分享" bgColor:[[UIColor colorWithRed:42/255 green:42/255 blue:42/255 alpha:1] CGColor] inView:[[UIApplication sharedApplication] keyWindow]];
                            }
                        }else{
//                            [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedStringFromTable(@"FB分享成功,謝謝您的分享",@"Launcher",nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確認",@"Launcher",nil) otherButtonTitles: nil] show];
                        }
                    }else{
//                        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedStringFromTable(@"FB分享成功,謝謝您的分享",@"Launcher",nil) delegate:nil cancelButtonTitle:NSLocalizedStringFromTable(@"確認",@"Launcher",nil) otherButtonTitles: nil] show];
                    }
                }];
            }
                break;
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
    UIViewController *presentingController = [UIApplication sharedApplication].delegate.window.rootViewController;
    [presentingController presentViewController:mySocialComposeView animated:NO completion:nil];
}

- (UIImage *)getImageFromView:(UIView *)orgView{
    UIGraphicsBeginImageContext(orgView.bounds.size);
    [orgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
