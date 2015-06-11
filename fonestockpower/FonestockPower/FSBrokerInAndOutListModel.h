//
//  FSBrokerInAndOutListModel.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CELL_TITLE_CONTENT_WIDTH 90.0f

@interface FSBrokerInAndOutListModel : NSObject

@end

@interface FSBrokerCustomData : NSObject

@property int optionalBranchID;
@property NSString *optionalName;
@property NSString *headOfficeName;

@end

@interface FSBrokerChoice : NSObject

@property NSString *brokerName;
@property NSString *branchName;
@property int brokerID;
@property NSString *brokerBranchID;
@property int groupIndex;
@end

@interface FSBrokerByBrokerData : NSObject
@property NSString *name;
@property double overBought;
@property double buy;
@property double sell;
@property double buyAvg;
@property double sellAvg;

@end

@interface FSBrokerParametersCell : UITableViewCell

@property UILabel *titleLabel;
@property UILabel *detailLabel;

@end

@interface FSBrokerParametersMainCell : UITableViewCell

@property UILabel *mainLbl;
@property UILabel *subLbl;

- (instancetype)initWithLStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

- (instancetype)initWithRStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
@end