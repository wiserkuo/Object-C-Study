//
//  SpecialStateModel.m
//  Bullseye
//
//  Created by Neil on 13/9/5.
//
//

#import "SpecialStateModel.h"
#import "SpecialStateOut.h"

@implementation SpecialStateModel

-(void)setTarget:(id)obj{
    notifyObj = obj;
}

-(void)showSpecialStateWithState:(NSNumber *)s{
    SpecialStateOut * SpecialStatepacket = [[SpecialStateOut alloc] initWithTimes:0 status:s];
    [FSDataModelProc sendData:self WithPacket:SpecialStatepacket];
}

-(void)backToControllerWithArray:(NSMutableArray *)array{
    [notifyObj performSelectorOnMainThread:@selector(notifyDataArrive:) withObject:array waitUntilDone:NO];
}

@end
