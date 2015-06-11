//
//  FSURLConnectCenter.h
//  FonestockPower
//
//  Created by Connor on 14/4/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol FSURLConnectCenterDelegate;

@interface FSURLConnectCenter : NSObject

- (id)initURLRequestWithURL:(NSURL *)requestURL requestString:(NSString *)requestString;

- (void)commit;
- (void)cancel;

@property (weak, nonatomic) id <FSURLConnectCenterDelegate> delegate;
@end

@protocol FSURLConnectCenterDelegate <NSObject>
@optional
- (void)urlConnectCenter:(FSURLConnectCenter *)urlConnectCenter didFinishWithData:(NSData *)callBackData;
- (void)urlConnectCenter:(FSURLConnectCenter *)urlConnectCenter didFailWithError:(NSError *)callBackError;
@end