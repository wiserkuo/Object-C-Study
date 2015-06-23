//
//  FSURLConnectCenter.m
//  FonestockPower
//
//  Created by Connor on 14/4/2.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSURLConnectCenter.h"

@interface FSURLConnectCenter() <NSURLConnectionDelegate>
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSMutableData *receivedData;
@property (unsafe_unretained, nonatomic) BOOL connect;
@end

@implementation FSURLConnectCenter

#pragma mark -
#pragma mark URLConnectCenter life circle

- (id)initURLRequestWithURL:(NSURL *)requestURL requestString:(NSString *)requestString {
	if (self = [super init]) {
        
        NSLog(@"\nup :\n====================\n%@\n====================", requestString);
        
        NSData *requestData = [requestString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:FS_REQUEST_TIMEOUT];
        [request setHTTPBody:requestData];
        [request setHTTPMethod:@"POST"];
        
        self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
        [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
	}
	return self;
}

- (void)dealloc {
//    NSLog(@"dealloc %@", [self description]);
	[self.connection cancel];
}

#pragma mark -
#pragma mark URLConnectCenter operating methods

- (void)commit {
    [self.connection start];
}

- (void)cancel {
    [self.connection cancel];
}


#pragma mark -
#pragma mark NSURLConnectionDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// 可能會redirect, 所以清空重新計算
    self.receivedData = nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if (!self.receivedData) {
		// no store yet, make one
		self.receivedData = [[NSMutableData alloc] initWithData:data];
	}
	else {
		// append to previous chunks
		[self.receivedData appendData:data];
	}
}

// 資料已完整傳輸
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"\ndown : \n====================\n%@\n====================",
          [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding]);
    
    if ([self.delegate respondsToSelector:@selector(urlConnectCenter:didFinishWithData:)]) {
        [self.delegate urlConnectCenter:self didFinishWithData:self.receivedData];
    }
}

// 錯誤發生處理
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Error retrieving data, %@", [error localizedDescription]);
    
    if ([self.delegate respondsToSelector:@selector(urlConnectCenter:didFailWithError:)]) {
        [self.delegate urlConnectCenter:self didFailWithError:error];
    }
}


#pragma mark -
#pragma mark self-signed certificate trust

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    
//	if ([challenge.protectionSpace.authenticationMethod
//		 isEqualToString:NSURLAuthenticationMethodServerTrust])
//	{
//		// we only trust our own domain
//		if ([challenge.protectionSpace.host isEqualToString:@"points.fonestock.com"])
//		{
//			NSURLCredential *credential =
//            [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//			[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//		}
//
//        if ([challenge.protectionSpace.host isEqualToString:@"usauth.fonestock.com"])
//		{
//			NSURLCredential *credential =
//            [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//			[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//		}
//        
//        if ([challenge.protectionSpace.host isEqualToString:@"cnauth.fonestock.com"])
//		{
//			NSURLCredential *credential =
//            [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//			[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//		}
//        
//        if ([challenge.protectionSpace.host isEqualToString:@"kqauth.fonestock.com"])
//		{
//			NSURLCredential *credential =
//            [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//			[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//		}
//        
//        if ([challenge.protectionSpace.host isEqualToString:@"twauth.fonestock.com"])
//        {
//            NSURLCredential *credential =
//            [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//        }
//        
//        if ([challenge.protectionSpace.host isEqualToString:@"uspush.fonestock.com"])
//        {
//            NSURLCredential *credential =
//            [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//        }
//        else {
//            NSURLCredential *credential =
//            [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//            [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
//        }
//        
//	}
    
    
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    [challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
    
}

@end