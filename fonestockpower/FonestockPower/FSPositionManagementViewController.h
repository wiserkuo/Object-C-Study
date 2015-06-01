//
//  FSPositionManagementViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/11/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSPositionManagementTableView.h"
@interface arrowData : NSObject{
@public
    NSString * type;
    int arrowType;
    NSString * date;
    NSString * note;
    NSString * reason;
}

@end

@interface FSPositionManagementViewController : FSUIViewController <FSPositionManagementTableViewDelegate>
@property (strong, nonatomic) FSPositionManagementTableView *tableView;

@end
