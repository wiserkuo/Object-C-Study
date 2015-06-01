//
//  CustomBtnInScrollView.h
//  Bullseye
//
//  Created by Neil on 13/9/12.
//
//

#import <UIKit/UIKit.h>
#import "SecuritySearchDelegate.h"



@interface CustomBtnInScrollView : UIView<UIScrollViewDelegate>

@property (strong, nonatomic) id <SecuritySearchDelegate> delegate;
@property (strong, nonatomic) UIScrollView *mainScrollView;
@property (strong, nonatomic)UIView * secView;

@property (strong) NSMutableDictionary * btnDictionary;
@property (strong) NSMutableArray * btnArrayH;
@property (strong) NSMutableArray * btnArrayV;
@property (strong) NSMutableArray * dataArray;
@property (strong) NSMutableArray * imgArray;
@property (nonatomic) int row;
@property (nonatomic) int column;
@property (nonatomic)enum FSUIButtonType type;

-(id)initWithDataArray:(NSMutableArray *)array Row:(int)row Column:(int)column ButtonType:(enum FSUIButtonType)type;

-(void)initButtonArray:(NSMutableArray *)array;

-(id)initWithDataArrayAndImgArray:(NSMutableArray *)dataArray :(NSMutableArray *)imgArray Row:(int)row Column:(int)column ButtonType:(enum FSUIButtonType)type;
-(void)initButtonArrayAndImg:(NSMutableArray *)dataArray :(NSMutableArray *)imgArray;

@end
