//
//  FSTeachPopView2.m
//  WirtsLeg
//
//  Created by Neil on 14/4/14.
//  Copyright (c) 2014年 fonestock. All rights reserved.
//

#import "FSTeachPopView.h"

@implementation FSTeachPopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        kx = [[KxMenu alloc]init];
        [self initView];
    }
    return self;
}

-(void)initView{
    closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setFrame:CGRectMake(self.frame.size.width-44, 0, 44, 44)];
    //    [closeBtn setTitle:@"關閉教學" forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage imageNamed:@"RedDeleteButton"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    
    //不再顯示的勾選按鈕
    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    UIView * checkBtnView;
    UILabel * label;
    if ([group isEqualToString:@"us"]) {
        checkBtnView = [[UIView alloc]initWithFrame:CGRectMake(25, self.frame.size.height-41, 270, 40)];
        label = [[UILabel alloc]initWithFrame:CGRectMake(45, 5, 220, 33)];
    }else{
        checkBtnView = [[UIView alloc]initWithFrame:CGRectMake(100, self.frame.size.height-41, 120, 40)];
        label = [[UILabel alloc]initWithFrame:CGRectMake(45, 5, 70, 33)];
    }
    
    checkBtnView.backgroundColor = [UIColor whiteColor];
    
    checkBtnView.layer.borderColor = [UIColor blackColor].CGColor;
    checkBtnView.layer.borderWidth = 1;
    
    [self addSubview:checkBtnView];
    
    
    self.checkBtn = [[FSUIButton alloc]initWithButtonType:FSUIButtonTypeCheckBox];
    _checkBtn.frame = CGRectMake(5, 5, 30, 30);
    [_checkBtn addTarget:self action:@selector(checkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    _checkBtn.backgroundColor = [UIColor clearColor];
    [checkBtnView addSubview:_checkBtn];
    
    label.text = NSLocalizedStringFromTable(@"teachText", @"FigureSearch",nil);
    label.backgroundColor = [UIColor whiteColor];
    [checkBtnView addSubview:label];
}

- (void)showMenuWithRect:(CGRect)rect String:(NSString *)str Detail:(BOOL)detail Direction:(KxMenuViewArrowDirection)direction
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //[btn setTitle:@"i" forState:UIControlStateNormal];
    
    NSArray *menuItems =[[NSArray alloc]init];
    
    
    if (detail) {
        menuItems =
        @[
          [KxMenuItem menuItem:str
                        Button:btn
                        Target:self
                        Action:@selector(pushMenuItem:)],
          ];
    }else{
        menuItems =
        @[
          [KxMenuItem menuItem:str
                        Button:nil
                        Target:self
                        Action:nil],
          ];
    }
    
    [kx showMenuInView:self
              fromRect:rect
             menuItems:menuItems
             direction:direction];
}


-(void)addHandImageWithType:(NSString *)type Rect:(CGRect)rect{
    UIImageView * handImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@.png",type]]];
    handImage.frame = rect;
    
    [self addSubview:handImage];
}

-(void)closeBtnClick{
    if (self.delegate && [self.delegate respondsToSelector:@selector(closeTeachPop:)])
    {
        [self.delegate closeTeachPop:self];
    }
}

-(void)pushMenuItem:(KxMenuItem *)sender{
    NSString * message = @"";
    NSString *tmp = [NSString stringWithFormat:@"%@說明", sender.title];
    message = NSLocalizedStringFromTable(tmp, @"FigureSearch",nil);
    
    UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle: NSLocalizedStringFromTable(@"取消", @"FigureSearch",nil)otherButtonTitles:nil];
    [alert show];
    
}

-(void)checkBtnClick:(FSUIButton *)btn{
    btn.selected = !btn.selected;
}


@end
