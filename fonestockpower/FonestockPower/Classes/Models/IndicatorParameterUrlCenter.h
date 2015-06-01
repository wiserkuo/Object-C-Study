//
//  IndicatorParameterUrlCenter.h
//  WirtsLeg
//
//  Created by Neil on 13/11/21.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IndicatorParameterUrlCenter;

@protocol IndicatorParameterUrlCenterDelegate <NSObject>
@required
- (void)urlCenterDidFinishWithData:(IndicatorParameterUrlCenter *)urlCenterData;
- (void)urlCenterDidFailWithData:(IndicatorParameterUrlCenter *)urlCenterData;
- (void)urlCenterDidFailWithError:(NSError *)error;
@end

@interface IndicatorParameterUrlCenter : NSObject

+ (IndicatorParameterUrlCenter *)sharedInstance;
-(void)IndicatorParameterUrlUpWithTime:(NSString *)time;

@property (strong, nonatomic) id <IndicatorParameterUrlCenterDelegate> delegate;

@property (strong, nonatomic) NSString *connectStatusCode;

@end
