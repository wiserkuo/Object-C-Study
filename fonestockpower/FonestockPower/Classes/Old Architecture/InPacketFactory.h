//
//  InPacketFactory.h
//  test4
//
//  Created by Yehsam on 2008/11/21.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface InPacketFactory : NSObject {

}

+ (id)createInPacketWithMessage:(int)message Command:(int)command;

@end
