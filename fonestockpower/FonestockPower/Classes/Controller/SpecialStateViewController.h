//
//  SpecialStateViewController.h
//  Bullseye
//
//  Created by Neil on 13/8/28.
//
//

#import <UIKit/UIKit.h>
#import "SKCustomTableView.h"




@interface SpecialStateViewController : UIViewController<SKCustomTableViewDelegate,UIActionSheetDelegate>

@property (nonatomic)int searchNum;
@property (strong, nonatomic) NSMutableArray * dataArray;
@property (strong, nonatomic) NSMutableArray * allDataArray;
@property (strong, nonatomic) NSMutableArray * stockArray;
@property (strong, nonatomic) NSMutableArray * fieldIdArray;
@property (strong, nonatomic) NSMutableArray * fieldDataArray;
@property (strong, nonatomic) NSMutableArray * changeFieldDataArray;

@end
