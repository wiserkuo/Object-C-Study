//
//  UnitView.h
//  PutUIViewInScrollView
//
//  Created by CooperLin on 2014/10/28.
//  Copyright (c) 2014年 CooperLin. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FSEachSingleViewDeployDelegate <NSObject>
@required
-(void)tapOccurred:(NSInteger)viewNum :(UITapGestureRecognizer *)something;
@end
@interface UnitView : UIView{
    NSObject *targetObj;
}

@property (weak ,nonatomic) id <FSEachSingleViewDeployDelegate> delegate;

@property (nonatomic, strong) UIImageView *backgroundImg;

@property (nonatomic, strong) UIImageView *leftImg;
@property (nonatomic, strong) UILabel *inLeftImg;

@property (nonatomic, strong) UIImageView *topImg;
@property (nonatomic, strong) UILabel *inTopImg;

@property (nonatomic, strong) UIImageView *item1;
@property (nonatomic, strong) UIImageView *item2;
@property (nonatomic, strong) UIImageView *item3;
@property (nonatomic, strong) UILabel *label1;
@property (nonatomic, strong) UILabel *label2;
@property (nonatomic, strong) UILabel *label3;


//該method 是對使用者tap 到的目標item 所做回應的method，會根據建立UnitView 時所傳入的tag 為viewNum 後面的something 為1，2或3 代表按到UnitView 裡面的哪一個item

//以下三個method 所輸入的兩個陣列內容個數必須相同，如果不想要有文字，請輸入空字串
//最後的target 是指欲回傳回去的目標viewController ，所以通常傳入值皆為self
-(id)initWithEmptyView:(NSMutableArray *)forItem :(NSMutableArray *)forLabel :(NSInteger)tag :(id)target;
//欲建立一個沒有左邊及上邊的內圖的UnitView 呼叫此method

-(id)initWithLeftImageView:(NSMutableArray *)forItem :(NSMutableArray *)forLabel :(NSInteger)tag :(NSString *)inLeftImg :(id)target;
//欲建立一個只有左邊內圖的UnitView 呼叫此method, 且輸入的文字需自行用\n 一個字一個字換行

-(id)initWithTopImageView:(NSMutableArray *)forItem :(NSMutableArray *)forLabel :(NSInteger)tag :(NSString *)inTopImg :(id)target;
//欲建立一個只有上邊內圖的UnitView 呼叫此method

-(id)initWithSpecialize:(NSString *)forItem :(NSInteger)tag :(NSString *)inLeftImg :(id)target;
//欲建立一個只有左邊內圖且只有一個置中的item 的UnitView 呼叫此method

//最後，欲讓本檔案內的item 能夠回傳被按到的item 須註冊viewController 至tapHandler 裡喔！

@end


