//
//  FSBValueFormat.m
//  FonestockPower
//
//  Created by Connor on 14/8/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBValueFormat.h"

@interface FSBTimeFormat()

@end

@implementation FSBValueFormat
@synthesize type, decimal, sign, value, subType, exponent, exponentType, calcValue, packType;

- (instancetype)initWithByte:(UInt8 **)sptr needOffset:(BOOL)needOffset {
    if (self = [super init]) {
        UInt8 *ptr = *sptr;
        int offset = 0;

        type = [CodingUtil getUint8FromBuf:ptr Offset:0 Bits:1];
        
        // Bit1=0, 2 bytes
        if (type == 0) {
            offset += 2;
            // 2 byte
            decimal = [CodingUtil getUint8FromBuf:ptr Offset:1 Bits:1];
            sign = [CodingUtil getUint8FromBuf:ptr Offset:2 Bits:1];
            value = [CodingUtil getUint16FromBuf:ptr Offset:3 Bits:13];
        }
        
        // Bit1=1 and Bit2=0, 4 bytes
        else if (type == 1) {
            subType = [CodingUtil getUint8FromBuf:ptr Offset:1 Bits:1];
            
            if (subType == 0) {
                // 4 byte
                offset += 4;
                
                decimal = [CodingUtil getUint8FromBuf:ptr Offset:2 Bits:2];
                sign = [CodingUtil getUint8FromBuf:ptr Offset:4 Bits:1];
                value = [CodingUtil getUint32FromBuf:ptr Offset:5 Bits:27];
            
            } else if (subType == 1) {
                // 8 byte
                offset += 8;
                exponent = [CodingUtil getUint8FromBuf:ptr Offset:2 Bits:3];
                packType = [CodingUtil getUint8FromBuf:ptr Offset:5 Bits:1];
                exponentType = [CodingUtil getUint8FromBuf:ptr Offset:6 Bits:1];
                sign = [CodingUtil getUint8FromBuf:ptr Offset:7 Bits:1];
                
                if (packType == FSBValueFormatPackTypeBinary) {
                    value = [CodingUtil getUint64FromBuf:ptr Offset:8 Bits:56];
                }
                else if (packType == FSBValueFormatPackTypePackBCD) {
                    NSMutableString *valString = [[NSMutableString alloc] init];
                    for (int i = 0; i < 14; i++) {
                        long long sNum = [CodingUtil getUint64FromBuf:ptr Offset:8 + i * 4 Bits:4];
                        [valString appendFormat:@"%lld", sNum];
                    }
                    value = [valString longLongValue];
                }
            }
        }
        
        [self __calcValue];
        
        if (needOffset) {
            *sptr += offset;
        }
    }
    return self;
}

- (void)__calcValue {
    
    if (type == 0) {
        if (decimal == 0) {
            // 0小數位
            calcValue = value;
        } else if (decimal == 1) {
            // 2小數位
            calcValue = value * 0.01;
        }
    }
    else if (type == 1) {
        if (subType == 0) {
            if (decimal == 0) {
                // 0 小數位
                calcValue = value;
            } else if (decimal == 1) {
                // 2 小數位
                calcValue = value * 0.01;
            } else if (decimal == 2) {
                // 3 小數位
                calcValue = value * 0.001;
            } else if (decimal == 3) {
                // 4 小數位
                calcValue = value * 0.0001;
            }
        }
        else if (subType == 1) {
            
            if (packType == FSBValueFormatPackTypeBinary) {
                if (exponentType == 0) {
                    calcValue = value * pow(10, exponent);
                } else if (exponentType == 1) {
                    calcValue = value * pow(0.1, exponent);
                }
            }
            else if (packType == FSBValueFormatPackTypePackBCD) {
                
                if (exponentType == 0) {
                    calcValue = value * pow(10, exponent);
                } else if (exponentType == 1) {
                    calcValue = value * pow(0.1, exponent);
                }
                
                
                
                /*****
                 
                 
                 
                 
                 // TODO:
                 
                 
                 
                 
                 *****/
            }
            
        }
        
    }
    
    if (sign == 0) {
        // 正數
    } else if (sign == 1) {
        // 負數
        calcValue *= -1;
    }
}

- (NSString *)format {
    NSString *dataValue;
    
    if (type == 0) {
        if (decimal == 0) {
            // 0小數位
            dataValue = [NSString stringWithFormat:@"%lld", value];
        } else if (decimal == 1) {
            // 2小數位
            dataValue = [NSString stringWithFormat:@"%.2f", value * 0.01];
        }
    }
    else if (type == 1) {
        if (subType == 0) {
            if (decimal == 0) {
                // 0 小數位
                dataValue = [NSString stringWithFormat:@"%lld", value];
            } else if (decimal == 1) {
                // 2 小數位
                dataValue = [NSString stringWithFormat:@"%.2f", value * 0.01];
            } else if (decimal == 2) {
                // 3 小數位
                dataValue = [NSString stringWithFormat:@"%.3f", value * 0.001];
            } else if (decimal == 3) {
                // 4 小數位
                dataValue = [NSString stringWithFormat:@"%.4f", value * 0.0001];
            }
        }
        else if (subType == 1) {
            
            if (packType == FSBValueFormatPackTypeBinary) {
                if (exponentType == 0) {
                    value = value * pow(10, exponent);
                } else if (exponentType == 1) {
                    value = value * pow(0.1, exponent);
                }
                dataValue = [NSString stringWithFormat:@"%lld", value];

            }
            else if (packType == FSBValueFormatPackTypePackBCD) {
                
                /*****
                 
                 
                 
                
                // TODO:
                
                
                
                
                *****/
            }
            
        }
        
    }

    if (sign == 0) {
        dataValue = [NSString stringWithFormat:@"%@", dataValue];
    } else if (sign == 1) {
        // 負數
        dataValue = [NSString stringWithFormat:@"-%@", dataValue];
    }
    
    return dataValue;
}

@end
