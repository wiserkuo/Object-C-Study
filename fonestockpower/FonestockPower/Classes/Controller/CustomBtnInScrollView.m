//
//  CustomBtnInScrollView.m
//  Bullseye
//
//  Created by Neil on 13/9/12.
//
//

#import "CustomBtnInScrollView.h"

@implementation CustomBtnInScrollView

-(id)initWithDataArrayAndImgArray:(NSMutableArray *)dataArray :(NSMutableArray *)imgArray Row:(int)row Column:(int)column ButtonType:(enum FSUIButtonType)type
{
    self = [super init];
    if (self) {
        _dataArray = dataArray;
        _imgArray = imgArray;
        _column = column;
        _row = row;
        _type = type;
        
        self.btnDictionary = [[NSMutableDictionary alloc]init];
        self.btnArrayH = [[NSMutableArray alloc]init];
        self.btnArrayV = [[NSMutableArray alloc]init];
        
        self.mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        _mainScrollView.bounces = NO;
        _mainScrollView.delegate = self;
        _mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_mainScrollView];
        if(imgArray.count > 2){
            [self initButtonArrayAndImg:dataArray :imgArray];
        }else{
            [self initButtonArray:dataArray];
        }
        
    }
    return self;
}

-(void)initButtonArrayAndImg:(NSMutableArray *)dataArray :(NSMutableArray *)imgArray
{
    _dataArray = dataArray;
    _imgArray = imgArray;
    [_btnDictionary setObject:_mainScrollView forKey:@"mainScrollView"];
    self.secView =[[UIView alloc]init];
    for (int i =0; i<[_dataArray count]; i++) {
        FSUIButton * btn = [[FSUIButton alloc]initWithButtonType:_type];
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        if ([[_dataArray objectAtIndex:i] length]>4) {
            btn.textLabel.text = [NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:i]];
            [btn.flagImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[_imgArray objectAtIndex:i]]]];
        }else{
            btn.textLabel.text = [NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:i]];
            [btn.flagImg setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@",[_imgArray objectAtIndex:i]]]];
        }
        
        //        if (_type ==3) {
        //            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        }
        btn.tag = i;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_btnDictionary setObject:btn forKey:[NSString stringWithFormat:@"btn%d",i]];
        [btn addTarget:self action:@selector(buttonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
        [_secView addSubview:btn];
    }
    [_mainScrollView addSubview:_secView];
    
    [self setNeedsUpdateConstraints];
    
}


-(id)initWithDataArray:(NSMutableArray *)array Row:(int)row Column:(int)column ButtonType:(enum FSUIButtonType)type{
    self = [super init];
    if (self) {
        _dataArray = array;
        _column = column;
        _row = row;
        _type = type;
        
        self.btnDictionary = [[NSMutableDictionary alloc]init];
        self.btnArrayH = [[NSMutableArray alloc]init];
        self.btnArrayV = [[NSMutableArray alloc]init];
        
        self.mainScrollView = [[UIScrollView alloc] init];
        _mainScrollView.backgroundColor = [UIColor whiteColor];
        _mainScrollView.bounces = NO;
        _mainScrollView.delegate = self;
        _mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:_mainScrollView];
        [self initButtonArray:array];
                
    }
    return self;
}

-(void)initButtonArray:(NSMutableArray *)array{
    _dataArray = array;
    [_btnDictionary setObject:_mainScrollView forKey:@"mainScrollView"];
    self.secView =[[UIView alloc]init];
    for (int i =0; i<[_dataArray count]; i++) {
        FSUIButton * btn = [[FSUIButton alloc]initWithButtonType:_type];
        
        btn.translatesAutoresizingMaskIntoConstraints = NO;
        if ([[_dataArray objectAtIndex:i] length]>4) {
            [btn setTitle:[NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:i]] forState:UIControlStateNormal];
        }else{
            [btn setTitle:[NSString stringWithFormat:@"%@",[_dataArray objectAtIndex:i]] forState:UIControlStateNormal];
        }
        
//        if (_type ==3) {
//            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        }
        btn.tag = i;
        btn.titleLabel.adjustsFontSizeToFitWidth = YES;
        [_btnDictionary setObject:btn forKey:[NSString stringWithFormat:@"btn%d",i]];
        [btn addTarget:self action:@selector(buttonClickHandler:) forControlEvents:UIControlEventTouchUpInside];
        [_secView addSubview:btn];
    }
    [_mainScrollView addSubview:_secView];

    [self setNeedsUpdateConstraints];
    
}

-(void)setAutoLayoutRow:(int)row Column:(int)column{
    [_btnArrayH removeAllObjects];
    [_btnArrayV removeAllObjects];
    NSString * stringV = @"V:|";
    
    if (column ==0) {
        int columnOfRow = ceilf(([_dataArray count]/(float)row));
        for (int i =0; i<[_dataArray count]; i+=columnOfRow) {
            if (row==1) {
                stringV = [NSString stringWithFormat:@"%@[btn%d(44)]",stringV,i];
            }else{
                stringV = [NSString stringWithFormat:@"%@-3-[btn%d(44)]",stringV,i];
            }
            NSString * stringH = @"H:|";
            for (int j=i; j<i+columnOfRow; j++) {
                if (j<[_dataArray count]) {
                    if (j==0) {
                        if(_imgArray){
                            stringH = [NSString stringWithFormat:@"%@-3-[btn%d(80)]",stringH,j];
                        }else{
                            stringH = [NSString stringWithFormat:@"%@-3-[btn%d(53)]",stringH,j];
                        }
                    }else{
                        stringH = [NSString stringWithFormat:@"%@-3-[btn%d(==btn0)]",stringH,j];
                    }
                }
            }
            //NSLog(@"in H:%@",stringH);
            [_btnArrayH addObject:stringH];
        }
        [_btnArrayV addObject:stringV];
        //NSLog(@"in V:%@",stringV);
    }else{
        for (int i =0; i<[_dataArray count]; i+=column) {
            stringV = [NSString stringWithFormat:@"%@-3-[btn%d]",stringV,i];
            NSString * stringH = @"H:|";
            for (int j=i; j<i+column; j++) {
                if (j<[_dataArray count]) {//沒有超過資料量
                    if (j==0) {
                        stringH = [NSString stringWithFormat:@"%@-3-[btn%d]",stringH,j];
                    }else{
                        stringH = [NSString stringWithFormat:@"%@-3-[btn%d(==btn0)]",stringH,j];
                    }
                }
            }
            [_btnArrayH addObject:stringH];
        }
    }
    
    [_btnArrayV addObject:stringV];
}


- (void)updateConstraints {
    
    [self removeConstraints:self.constraints];
    
    [self setAutoLayoutRow:_row Column:_column];
    
    //NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_mainScrollView);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainScrollView]|" options:0 metrics:nil views:_btnDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainScrollView]|" options:0 metrics:nil views:_btnDictionary]];
    
    if ([_dataArray count]!=0) {
        [self.secView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[_btnArrayV objectAtIndex:0] options:NSLayoutFormatAlignAllLeft metrics:nil views:_btnDictionary]];
        //NSLog(@"-%@",[NSString stringWithFormat:@"%@",[_btnArrayV objectAtIndex:0]]);
        
        if ([_btnArrayH count]==1) {
            [self.secView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@",[_btnArrayH objectAtIndex:0]] options:NSLayoutFormatAlignAllCenterY metrics:nil views:_btnDictionary]];
            //NSLog(@"-%@",[NSString stringWithFormat:@"%@-3-|",[_btnArrayH objectAtIndex:0]]);
        }else{
            for (int i =0; i<[_btnArrayH count]; i++) {
                
                if (i==0) {
                    [self.secView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@",[_btnArrayH objectAtIndex:i]] options:NSLayoutFormatAlignAllCenterY metrics:nil views:_btnDictionary]];
                    //NSLog(@"-%@",[NSString stringWithFormat:@"%@-3-|",[_btnArrayH objectAtIndex:i]]);
                }else{
                    [self.secView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[_btnArrayH objectAtIndex:i] options:NSLayoutFormatAlignAllCenterY metrics:nil views:_btnDictionary]];
                    //NSLog(@"-%@",[NSString stringWithFormat:@"%@",[_btnArrayH objectAtIndex:i]]);
                }        
            }
        }
    }
    [super updateConstraints];
}

-(void)buttonClickHandler:(FSUIButton *)btn{
    if (_delegate != nil && [_delegate respondsToSelector:@selector(titleButtonClick:Object:)]) {
        [_delegate titleButtonClick:btn Object:self];

    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
