//
//  Commodity.m
//  Bullseye
//
//  Created by Yehsam on 2008/11/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "Commodity.h"


@implementation Commodity

@synthesize symbol;

- (id)initWithIdentCode:(char*)i symbol:(NSString*)s
{
	if (self = [super init])
	{
		memcpy(&ident_Code, i , 2);
		symbol = s;
		IdenSymbol = malloc([self getSize]);
		memcpy(IdenSymbol, ident_Code , 2);
		*(IdenSymbol+2) = [symbol lengthOfBytesUsingEncoding:NSASCIIStringEncoding];
		memcpy(IdenSymbol+3, [symbol cStringUsingEncoding:NSASCIIStringEncoding] , [self getSize]-3);
	}
	return self;
}

- (int)getSize
{
	return (3+(int)[symbol lengthOfBytesUsingEncoding:NSASCIIStringEncoding]);
}

- (UInt8*)getIdentSymbol
{
	return IdenSymbol;
}

- (NSString*)getIdentSymbolString
{
	return [NSString stringWithFormat:@"%c%c %@",ident_Code[0], ident_Code[1], symbol];
    //[NSString stringWithIdentCode:ident_Code Symbol:symbol];
}

-(void)dealloc{
    if (IdenSymbol) {
        free(IdenSymbol);
    }
}


@end
