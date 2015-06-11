//
//  DiscreteTickout.h
//  Bullseye
//
//  Created by Shen Kevin on 13/8/6.
//
//

#import <Foundation/Foundation.h>

@interface DiscreteTickOut : NSObject <EncodeProtocol>

- (id)initWithCommodityNum:(UInt32)aCommodityNum beginSN:(UInt16)aBeginSN endSN:(UInt16)anEndSN tickSnDivideRatio:(UInt8)aTickSnDivideRatio;

@end
