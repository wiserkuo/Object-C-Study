//
//  MacroeconomicDrawViewController.h
//  FonestockPower
//
//  Created by Kenny on 2014/7/21.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MacroeconomicDrawViewController : UIViewController<NSXMLParserDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, HistoricDataArriveProtocol>
@property (nonatomic) int secondNameIndex;
@property (nonatomic) int secondRow;
@property (nonatomic,strong)UILabel *vertical;
@property (nonatomic) BOOL portfolioFlag;
-(id)initWithIndexID:(NSString *)IndexID ID:(NSMutableArray *)IDArray Name:(NSMutableArray *)NameArray Index:(int)NameIndex IndexRow:(int)Row Title:(NSMutableArray *)TitleArray;
- (void)doTouchesWithPoint:(CGPoint)point number:(int)num;
-(void)setSecondFlag;
@end
