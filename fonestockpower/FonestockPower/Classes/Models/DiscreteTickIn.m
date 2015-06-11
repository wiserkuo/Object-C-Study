//
//  DiscreteTickIn.m
//  Bullseye
//
//  Created by Shen Kevin on 13/8/6.
//
//

#import "DiscreteTickIn.h"
#import "MessageType10.h"
#import "MessageType11.h"
#import "MessageType12.h"

@interface DiscreteTickIn ()
@property (nonatomic) UInt16 dataCount;
@property (nonatomic) UInt8 messageType;
@property (nonatomic) UInt8 dataLength;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation DiscreteTickIn

- (id)init
{
	if(self = [super init])
	{
		self.dataArray = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void) decode:(UInt8*)body size:(int)size commodity:(UInt32)commodity retcode:(UInt8)retcode
{
	UInt8 *tmpPtr = body;
	_dataCount = [CodingUtil getUInt16:tmpPtr];
	tmpPtr+=2;
	if(_dataCount)
	{
		_messageType = *tmpPtr++;
		_dataLength = 0;
		int offset=0;
		for( int i=0 ; i<_dataCount ; i++)
		{
			tmpPtr += _dataLength;
			offset = 0;
			_dataLength = *tmpPtr++;
			if(_messageType == 10)
			{
				EquityTickParam *TickDataParam = [[EquityTickParam alloc] init];
				TickDataParam->securityNO = commodity;
				[MessageType10 decodeType10:tmpPtr TickParam:TickDataParam Offset:&offset];
				[_dataArray addObject:TickDataParam];
			}
			else if(_messageType == 11)
			{
				EquityTickParam *TickDataParam = [[EquityTickParam alloc] init];
				TickDataParam->securityNO = commodity;
				[MessageType11 decodeType11:tmpPtr TickParam:TickDataParam Offset:&offset];
				[_dataArray addObject:TickDataParam];
			}
			else if(_messageType == 12)
			{
				IndexTickParam *TickDataParam = [[IndexTickParam alloc] init];
				TickDataParam->securityNO = commodity;
				[MessageType12 decodeType12:tmpPtr TickParam:TickDataParam Offset:&offset];
				[_dataArray addObject:TickDataParam];
			}
		}
	}
	
	// Send to Data Modal.
	FSDataModelProc *dataModal = [FSDataModelProc sharedInstance];
	[dataModal.portfolioTickBank performSelector:@selector(addTick:) onThread:dataModal.thread withObject:_dataArray waitUntilDone:NO];
}

@end
