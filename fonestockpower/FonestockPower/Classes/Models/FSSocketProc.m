
//
//  FSSocketProc.m
//  FonestockPower
//
//  Created by Connor on 14/3/19.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSSocketProc.h"
#import "FSLoginService.h"
#import "OutPacket.h"
#import "InPacket.h"
#import "KeepAliveOut.h"

@interface FSSocketProc() {
    NSMutableArray *queueInPacket;
    NSMutableArray *queueOutPacket;
    NSLock *lockInPacketQueue;
    NSLock *lockOutPacketQueue;
    NSCondition *conditionReady;
    BOOL isReady;
}

@end

@implementation FSSocketProc
#pragma --
#pragma mark 生命週期

- (id)init {
	if (self = [super init]) {
		queueInPacket = [[NSMutableArray alloc] initWithCapacity:16];
		queueOutPacket = [[NSMutableArray alloc] initWithCapacity:4];
		
		// Allocate locks for queues.
		lockInPacketQueue = [[NSLock alloc] init];
		lockOutPacketQueue = [[NSLock alloc] init];
		
		// aquire the condition lock
		conditionReady = [[NSCondition alloc] init];
        
        // 登入階段
        _isLoginStage = NO;
    }
	
	return self;
}

- (void)connectWithHost:(NSString *)ipAddress Port:(UInt32)portNumber {
    _ipAddress = ipAddress;
    _portNumber = portNumber;
    [self performSelector:@selector(openSession) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void)waitUntilReady {
    [conditionReady lock];
	
    while (!isReady) {
        NSLog(@"socket [conditionReady wait];");
        [conditionReady wait];
    }
		
	[conditionReady unlock];
}

- (void)dealloc {
    // 永遠不被執行
    assert(1>1);
}

#pragma --
#pragma mark 執行緒執行階段

- (void)main {
    
    [conditionReady lock];

    _thread = [NSThread currentThread];
    
    isReady = YES;
	[conditionReady signal];
	[conditionReady unlock];
    
    [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(runtest) userInfo:nil repeats:YES];
    
    do {
        if ([[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate distantFuture]]) {
            //NSLog(@"socketproc ret  Y");
        } else {
            //NSLog(@"socketproc ret  N");
        }
    } while (1);
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode {
    BOOL fromQueue = NO;
    
    //當訊息從主機由iStream端進入時
    if (eventCode == NSStreamEventHasBytesAvailable) {

        [lockInPacketQueue lock];
        NSInputStream *inputStream = (NSInputStream *)stream;
        InPacket *packet;
        
        if ([queueInPacket count] > 0) {
            fromQueue = YES;
            packet = [queueInPacket firstObject];
            
        }
        else {
            packet = [[InPacket alloc] init];
        }
        
        NSInteger bytesread = [inputStream read:(uint8_t *)[packet getBuffer]
                                      maxLength:(NSUInteger)[packet getBufferSize]];
        
        if (!bytesread) {
            [lockInPacketQueue unlock];
            return;
        }
        [packet adjustBuffer:(int)bytesread];
        
        
        if ([packet getBufferSize] > 0) {
            if (!fromQueue) {
                [queueInPacket addObject:packet];                
            }

        }
        else {
//            NSLog(@"BufferSize %d",[packet getBufferSize]);
            // 全部封包已取得
            FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
            [packet performSelector:@selector(decode) onThread:dataModel.thread withObject:nil waitUntilDone:YES];
            
            if (fromQueue) {
                [queueInPacket removeObject:packet];
            }
        }
        
        [lockInPacketQueue unlock];
        
    }
    
    else if (eventCode == NSStreamEventOpenCompleted) {
        _isConnected = YES;
        _isLoginStage = NO;
        
        // oStream是最後收到的
        if (stream == oStream) {
            FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
            FSLoginService *loginService = [dataModel loginService];
            [loginService loginServiceServer];
        }
    }
    
    else if (eventCode == NSStreamEventHasSpaceAvailable) {
//        NSLog(@"NSStreamEventHasSpaceAvailable");
        [lockOutPacketQueue lock];
        if ([queueOutPacket count] > 0) {
            OutPacket *packet = [queueOutPacket objectAtIndex:0];
            NSUInteger bytewritten = [oStream write:[packet getBuffer] maxLength:(NSUInteger)[packet getBufferSize]];
            [packet adjustBuffer:(int)bytewritten];
            
            if (![packet getBufferSize]) {
                [queueOutPacket removeObjectAtIndex:0];
            }
        }
        [lockOutPacketQueue unlock];
    }
    else if (eventCode == NSStreamEventErrorOccurred) {
        NSLog(@"NSStreamEventErrorOccurred");
        _isConnected = NO;
        _isLoginStage = NO;
        
        // iStream是最先收到的
        if (stream == iStream) {
            [FSHUD hideGlobalHUD];
//            [FSHUD showGlobalProgressHUDWithTitle:NSLocalizedStringFromTable(@"Reconnecting...", @"Launcher", nil)];
            
            [lockInPacketQueue lock];
            [queueInPacket removeAllObjects];
            [lockInPacketQueue unlock];

            [lockOutPacketQueue lock];
            [queueOutPacket removeAllObjects];
            [lockOutPacketQueue unlock];
            
            FSLoginService *loginService = [[FSDataModelProc sharedInstance] loginService];
            [loginService performSelector:@selector(disconnectReloginAuth) withObject:nil];
        }
    }
}

- (void)openSession {

    // 進行登入階段
    _isLoginStage = YES;
    
    CFReadStreamRef readStream = NULL;
    CFWriteStreamRef writeStream = NULL;
    
    CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (__bridge CFStringRef)_ipAddress, (UInt32)_portNumber, &readStream, &writeStream);
    
    if (readStream && writeStream) {
        CFReadStreamSetProperty(readStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        CFWriteStreamSetProperty(writeStream, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
        
        iStream = (__bridge_transfer NSInputStream *)readStream;
        [iStream setDelegate:self];
        [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [iStream open];
        
        oStream = (__bridge_transfer NSOutputStream *)writeStream;
        [oStream setDelegate:self];
        [oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [oStream open];
    }
}

- (void)closeSession {
    [iStream close];
    [oStream close];
    _isConnected = NO;
}

- (void)disconnect {
    if (_isConnected)
    [self closeSession];
}

- (void)reconnect {
    if (_isConnected) {
        [self closeSession];
    }
    [self openSession];
}

- (void)runtest {
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    if (_isConnected && !dataModel.isRejectReLogin) {
        KeepAliveOut *keepAliveOut = [[KeepAliveOut alloc] initWithTimeStamp:[[NSDate date] timeIntervalSince1970] identifier:123];
		[FSDataModelProc sendData:self WithPacket:keepAliveOut];
    }
}

// old format
- (BOOL)sendPacket:(OutPacket *)packet {
	int count;
    
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    dataModel.isRejectReLogin = NO;
	
	// The streaming maybe closed by the user.
	if ([oStream streamStatus] == NSStreamStatusNotOpen)
		return NO;
    
    if ([oStream hasSpaceAvailable] == YES) {
        @try {
            count = (int)[oStream write:[packet getBuffer] maxLength:[packet getBufferSize]];
            [packet adjustBuffer:count];
            if (![packet getBufferSize]) {
                return YES;
            }
        }
        @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }
        @finally {
            
        }
    }
    
    [lockOutPacketQueue lock];
	[queueOutPacket addObject:packet];
	[lockOutPacketQueue unlock];
	
	return YES;
}

@end
