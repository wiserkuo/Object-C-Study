//
//  URLParser.h
//  WirtsLeg
//
//  Created by Connor on 13/12/6.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLParser : NSObject {
    NSArray *variables;
}

@property (nonatomic, strong) NSArray *variables;

- (id)initWithURLString:(NSString *)url;
- (id)initWithURL:(NSURL *)url;
- (NSString *)valueForVariable:(NSString *)varName;

@end
