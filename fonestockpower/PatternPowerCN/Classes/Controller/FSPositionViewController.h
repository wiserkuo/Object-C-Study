//
//  FSPositionViewController.h
//  FonestockPower
//
//  Created by Derek on 2014/7/11.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FSActionTableView.h"
#import "FSActionCell.h"

@interface arrowData : NSObject{
@public
    NSString * type;
	int arrowType;
    NSString * date;
    NSString * note;
    NSString * reason;
}

@end


@interface FSPositionViewController : UIViewController <FSActionTableViewDelegate>
@property (strong, nonatomic)FSActionTableView *tableView;

@end
