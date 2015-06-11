//
//  BtnCollectionView.m
//  WirtsLeg
//
//  Created by Neil on 13/10/8.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "BtnCollectionView.h"
#import "BtnCollectionViewCell.h"
#import "MarqueeCollectionViewCell.h"

static NSString *ItemIdentifier = @"ItemIdentifier";
static NSString *ItemIdentifier2 = @"ItemIdentifier2";
@implementation BtnCollectionView


- (void)dealloc {
    
}

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)aFlowLayout rowCount:(NSInteger)rowCount {
    _rowCount = rowCount;
    self = [self initWithFrame:frame collectionViewLayout:aFlowLayout];
    return self;
}
- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewFlowLayout *)aFlowLayout
{
    self = [super initWithFrame:frame collectionViewLayout:aFlowLayout];
    if (self) {
        // Initialization code
        //self.btnArray = [[NSMutableArray alloc]initWithObjects:@"集中",@"店頭",@"興櫃",@"集團",@"成份",@"國際",@"集中",@"店頭",@"興櫃",@"集團",@"成份",@"國際",@"集中",@"店頭",@"興櫃",@"集團",@"成份",@"國際", nil];
        self.btnDictionary = [[NSMutableDictionary alloc]init];
        self.btnArray = [[NSMutableArray alloc]init];
        self.chooseArray = [[NSMutableArray alloc]init];
        self.holdBtn = 0;
        self.searchGroup = 0;
        self.collectionViewLayout = aFlowLayout;
        
        [self registerClass:[MarqueeCollectionViewCell class] forCellWithReuseIdentifier:ItemIdentifier2];
        [self registerClass:[BtnCollectionViewCell class] forCellWithReuseIdentifier:ItemIdentifier];

        self.delegate = self;
        self.dataSource = self;
        self.bounces = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.showsVerticalScrollIndicator = YES;
        self.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    }
    return self;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cell click");
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_btnArray count];//物件數量
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_rowCount != 0) {
        return CGSizeMake(collectionView.frame.size.width / _rowCount - 5, 33);
    }
    return CGSizeMake(collectionView.frame.size.width / 3 - 5, 33);
}



-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BtnCollectionViewCell *cell;
    if(self.btnFlag == 1){
        cell = (MarqueeCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ItemIdentifier2 forIndexPath:indexPath];
    }else{
        cell = (BtnCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:ItemIdentifier forIndexPath:indexPath];
    }
//    return cell;
    cell.delegate = self;
    cell.btnFlag = self.btnFlag;

    [cell setButtonText:[_btnArray objectAtIndex:indexPath.row]];
    [cell setButtonTextColor:[UIColor blackColor]];
    [cell setButtonTag:(int)indexPath.row];
    cell.button.selected = NO;
    if (_searchGroup == 1) {
        [cell.button setContentHorizontalAlignment:_aligment];
    }
    [_btnDictionary setObject:cell.button forKey:[NSString stringWithFormat:@"btn%d", (int)indexPath.row]];
    if (_holdBtn<99999) {
        if (cell.button.tag ==_holdBtn) {
            cell.button.selected = YES;
            [cell.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
    if ([_chooseArray count]!=0) {
        for (int i =0; i<[_chooseArray count]; i++) {
            if (cell.button.tag ==[[_chooseArray objectAtIndex:i]intValue]) {
                cell.button.selected = YES;
                [cell.button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }
    
    return cell;
}

-(void)titleButtonClick:(FSUIButton *)button{
    if ([_myDelegate respondsToSelector:@selector(titleButtonClick:)]) {
        [_myDelegate titleButtonClick:button];
    }else{
        _holdBtn = (int)button.tag;
        if (_btnSelectOnlyOne) {
            for (int i=0; i<[_btnDictionary count]; i++) {
                FSUIButton * otherBtn =  [_btnDictionary objectForKey:[NSString stringWithFormat:@"btn%d",i]];
                otherBtn.selected = NO;
                [otherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            button.selected =YES;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }else{
            button.selected = !button.selected;
            if (button.selected) {
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }else {
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            
        }
        
        
        [_myDelegate groupButtonClick:button Object:self];
    }
    
    //NSLog(@"back");
    
    
}

-(void)buttonPan:(UILongPressGestureRecognizer *)sender{
    if (_myDelegate != nil && [_myDelegate respondsToSelector:@selector(buttonPan:)]) {
        [_myDelegate buttonPan:sender];
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
