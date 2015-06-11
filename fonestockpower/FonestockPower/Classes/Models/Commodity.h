//
//  Commodity.h
//  Bullseye
//
//  Created by Yehsam on 2008/11/26.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
	kCommodityTypeStock = 1,
	kCommodityTypeWarrant,
	kCommodityTypeIndex,
	kCommodityTypeFuture,
	kCommodityTypeOption,
	kCommodityTypeMarketIndex,
	kCommodityTypeETF,
	kCommodityTypeNews,
	kCommodityTypeOther,
	kCommodityTypeCurrency,
	kCommodityTypeFutureOptionTarget,
	kCommodityTypeConsultancy
} CommodityType;


@interface Commodity : NSObject {
	UInt8 *IdenSymbol;
	char ident_Code[2];
	NSString *symbol;
}

@property (nonatomic,strong) NSString *symbol;

- (id)initWithIdentCode:(char*)i symbol:(NSString*)s;
- (int)getSize;
- (UInt8*)getIdentSymbol;
- (NSString*)getIdentSymbolString;

@end
