//
//  UIImage+PixelColor.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/6/5.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "UIImage+PixelColor.h"

@implementation UIImage (PixelColor)


- (UIColor *)colorAtPoint:(CGPoint)pixelPoint
{
    if (pixelPoint.x > self.size.width ||
        pixelPoint.y > self.size.height) {
        return nil;
    }
    
    CGDataProviderRef provider = CGImageGetDataProvider(self.CGImage);
    CFDataRef pixelData = CGDataProviderCopyData(provider);
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    int numberOfColorComponents = 4; // R,G,B, and A
    float x = pixelPoint.x;
    float y = pixelPoint.y;
    float w = self.size.width;
    int pixelInfo = ((w * y) + x) * numberOfColorComponents;
    
    UInt8 red = data[pixelInfo];
    UInt8 green = data[(pixelInfo + 1)];
    UInt8 blue = data[pixelInfo + 2];
    UInt8 alpha = data[pixelInfo + 3];
    CFRelease(pixelData);
    
    // RGBA values range from 0 to 255
    return [UIColor colorWithRed:red/255.0
                           green:green/255.0
                            blue:blue/255.0
                           alpha:alpha/255.0];
}
@end
