//
//  KeepAliveIn.m
//  Bullseye
//
//  Created by Yehsam on 2008/12/8.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "KeepAliveIn.h"
#import "CodingUtil.h"
#import	"OutPacket.h"
#import "KeepAliveOut.h"

@interface KeepAliveIn()
@property (strong, nonatomic) UIView *toastView;
@end

@implementation KeepAliveIn

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
    
    UInt8 *tmpPtr = body;
    timeStamp = [CodingUtil getUInt32:tmpPtr];
    tmpPtr += 4;
    Identifier = [CodingUtil getUInt16:&tmpPtr needOffset:YES];
    code = [CodingUtil getUInt8:&tmpPtr needOffset:YES];
    message = [CodingUtil getShortStringFormatByBuffer:&tmpPtr needOffset:YES];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSDateComponents *comps = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:[[NSTimeZone systemTimeZone] secondsFromGMT]];
    [[NSCalendar currentCalendar] dateFromComponents:comps];
    if(code == 1){
        [self showTheStatus:message];
        FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
        dataModel.isRejectReLogin = YES;
        [dataModel.mainSocket disconnect];
    }
    
//	UInt8 *tmpPtr = body;
//	startByte = *tmpPtr++;
//	timeStamp = [CodingUtil getUInt32:tmpPtr];
//	tmpPtr+=4;
//	Identifier = [CodingUtil getUInt16:tmpPtr];
//	tmpPtr+=2;
	
//	OutPacket *outP;
//	KeepAliveOut *kp = [[KeepAliveOut alloc] initWithStartByte:startByte TimeStamp:timeStamp identifier:Identifier];
//    KeepAliveOut *kp = [[KeepAliveOut alloc] initWithTimeStamp:timeStamp identifier:Identifier];
//    outP = [[OutPacket alloc] init];
//	[outP attchBody:kp];
//	[outP encode:self];
//    FSDataModelProc
//	PacketProc *op = [DataModalProc getCommModal];
//	[op performSelector:@selector(sendPacket:) onThread:op.thread withObject:outP waitUntilDone:NO];
	

}

-(void)showTheStatus:(NSString *)showMsg
{
    CGFloat theWidth = [[UIApplication sharedApplication] keyWindow].frame.size.width;
    CGFloat theHeight = [[UIApplication sharedApplication] keyWindow].frame.size.height;
    if(!_toastView){
        _toastView = [[UIView alloc] initWithFrame:CGRectMake(theWidth / 2 - 150, theHeight - 80, 300, 50)];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 50)];
        lbl.numberOfLines = 0;
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"us"])
        {
            [_toastView setFrame:CGRectMake(theWidth / 2 - 150, theHeight - 100, 300, 40)];
            [lbl setFrame:CGRectMake(20, 0, 280, 40)];
        }
        lbl.text = NSLocalizedStringFromTable(@"在其他裝置使用相同帳號會發生的事情", @"Launcher", nil);
        lbl.textColor = [UIColor whiteColor];
        lbl.font = [UIFont systemFontOfSize:14.0f];
        lbl.textAlignment = NSTextAlignmentLeft;
        [_toastView addSubview:lbl];
        _toastView.backgroundColor = [UIColor blackColor];
        [_toastView.layer setMasksToBounds:YES];
        _toastView.layer.cornerRadius = 5;
    }
    _toastView.hidden = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginAuthStatus" object:[NSNumber numberWithInteger:FSLoginResultTypeBeKickedOut]];
    [[[UIApplication sharedApplication] keyWindow] addSubview:_toastView];
    [self performSelector:@selector(closeTheLoginToast) withObject:nil afterDelay:5];
}

-(void)closeTheLoginToast
{
    _toastView.hidden = YES;
}

@end
