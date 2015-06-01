//
//  FSRSAEncrypt.h
//  FonestockOrder
//
//  Created by Connor on 2014/11/13.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FSRSAEncrypt : NSObject {
    SecKeyRef publicKey;
    SecCertificateRef certificate;
    SecPolicyRef policy;
    SecTrustRef trust;
    size_t maxPlainLen;
}

- (NSData *)encryptWithData:(NSData *)content;
- (NSData *)encryptWithString:(NSString *)content;
- (NSString *)encryptToString:(NSString *)content;

@end
