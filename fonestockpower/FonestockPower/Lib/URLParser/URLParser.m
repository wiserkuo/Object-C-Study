//
//  URLParser.m
//  WirtsLeg
//
//  Created by Connor on 13/12/6.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "URLParser.h"

@implementation URLParser
@synthesize variables;

- (id)initWithURLString:(NSString *)url {
    self = [super init];
    if (self != nil) {
        [self parsingURL:url];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self != nil) {
        [self parsingURL:[url absoluteString]];
    }
    return self;
}

- (void)parsingURL:(NSString *)urlString {
    NSScanner *scanner = [NSScanner scannerWithString:urlString];
    [scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@"&?"]];
    NSString *tempString;
    NSMutableArray *vars = [NSMutableArray new];
    [scanner scanUpToString:@"?" intoString:nil];       //ignore the beginning of the string and skip to the vars
    while ([scanner scanUpToString:@"&" intoString:&tempString]) {
        [vars addObject:[tempString copy]];
    }
    self.variables = vars;
}

- (NSString *)valueForVariable:(NSString *)varName {
    for (NSString *var in self.variables) {
        if ([var length] > [varName length]+1 && [[var substringWithRange:NSMakeRange(0, [varName length]+1)] isEqualToString:[varName stringByAppendingString:@"="]]) {
            NSString *varValue = [var substringFromIndex:[varName length]+1];
            return varValue;
        }
    }
    return nil;
}

- (void)dealloc{
    self.variables = nil;
}

@end