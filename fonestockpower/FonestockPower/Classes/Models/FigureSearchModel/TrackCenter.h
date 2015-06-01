//
//  TrackCenter.h
//  WirtsLeg
//
//  Created by Neil on 13/11/7.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TrackCenter;

@protocol TrackCenterDelegate <NSObject>
@required
- (void)trackCenterDidFinishWithData:(TrackCenter *)trackCenterData;
- (void)trackCenterDidFailWithData:(TrackCenter *)trackCenterData;
- (void)trackCenterDidFailWithError:(NSError *)error;
@end

@interface TrackCenter : NSObject

+ (TrackCenter *)sharedInstance;
-(void)upTrackWithTrackUpArray:(NSMutableArray *)trackUpArray;

@property (strong, nonatomic) id <TrackCenterDelegate> delegate;

@property (strong, nonatomic) NSString *connectStatusCode;
@property (nonatomic) int resultCount;
@property (strong, nonatomic) NSMutableArray * trackDownArray;
@property (strong, nonatomic) NSMutableArray * trackUpArray;
@end
