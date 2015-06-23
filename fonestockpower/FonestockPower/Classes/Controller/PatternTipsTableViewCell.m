//
//  PatternTipsTableViewCell.m
//  FonestockPower
//
//  Created by Kenny on 2015/1/14.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "PatternTipsTableViewCell.h"
#import "PatternTipsModel.h"
@interface PatternTipsTableViewCell ()
{
    NSMutableArray *symbolArray;
    NSMutableArray *constraints;
}
@end
static NSString *itemIdentifier = @"CollectionIdentifier";
@implementation PatternTipsTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        constraints = [[NSMutableArray alloc] init];
        
        self.imgView = [[UIImageView alloc] init];
        _imgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_imgView];
        
        self.imgName = [[MarqueeLabel alloc]initWithFrame:CGRectZero duration:6.0 andFadeLength:0.0f];
        _imgName.font = [UIFont systemFontOfSize:13.0f];
        [_imgName setLabelize:NO];
        _imgName.marqueeType = 4;
        _imgName.continuousMarqueeExtraBuffer = 10.0f;
        _imgName.textAlignment = NSTextAlignmentCenter;
        _imgName.translatesAutoresizingMaskIntoConstraints = NO;
        _imgName.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(labelTap:)];
        [_imgName addGestureRecognizer:tapRecognizer];
        [self.contentView addSubview:_imgName];
        
        //此為顯示tableView 左方圖示下方個數數字的給值的地方，因目前不需要，暫時註解起來
//        self.imgCount = [[UILabel alloc] init];
//        self.imgCount.font = [UIFont boldSystemFontOFize:18.0f];
//        _imgCount.translatesAutoresizingMaskIntoConstraints = NO;
//        [self.contentView addSubview:_imgCount];
        
        self.verticalLine = [[UIView alloc] init];
        _verticalLine.translatesAutoresizingMaskIntoConstraints = NO;
        _verticalLine.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:_verticalLine];
        
        self.rightView = [[UIView alloc] init];
        _rightView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_rightView];
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        flowLayout.itemSize = CGSizeMake(73, 31);
        flowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
        flowLayout.minimumLineSpacing = 1.0f;
        flowLayout.minimumInteritemSpacing = 1.0f;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [_collectionView registerClass:[PatternsTipsCollectionCell class] forCellWithReuseIdentifier:itemIdentifier];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.bounces = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.scrollEnabled = NO;
        _collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        [self.rightView addSubview:_collectionView];
        
        [self updateConstraintsIfNeeded];
    }
    return self;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(collectionView.frame.size.width / 3 - 5, 33);
}

- (void)labelTap:(UITapGestureRecognizer *)recognizer{
    [(MarqueeLabel *)recognizer.view setLabelize:NO];
}

-(void)setImgArray:(NSMutableArray*)array
{
    symbolArray = array;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)updateConstraints
{
    [super updateConstraints];
    
    [self.contentView removeConstraints:constraints];
    [constraints removeAllObjects];
    
    NSDictionary *cellDictionary = NSDictionaryOfVariableBindings(_imgView, _imgName, _verticalLine, _rightView, _collectionView);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_imgView(60)][_imgName(20)]" options:NSLayoutFormatAlignAllCenterX metrics:nil views:cellDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_imgView(60)]-10-[_verticalLine(1)]-5-[_rightView]|" options:0 metrics:nil views:cellDictionary]];
    
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_imgName(60)]-10-[_verticalLine(1)]-5-[_rightView]|" options:0 metrics:nil views:cellDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_verticalLine]|" options:0 metrics:nil views:cellDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightView]|" options:0 metrics:nil views:cellDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightView]|" options:0 metrics:nil views:cellDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_collectionView]|" options:0 metrics:nil views:cellDictionary]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_collectionView]|" options:0 metrics:nil views:cellDictionary]];
    
    
    [self.contentView addConstraints:constraints];
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [symbolArray count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PatternsTipsCollectionCell *collectionCell = (PatternsTipsCollectionCell *)[collectionView dequeueReusableCellWithReuseIdentifier:itemIdentifier forIndexPath:indexPath];
    if(!collectionCell){
        collectionCell = [[PatternsTipsCollectionCell alloc] initWithFrame:CGRectZero];
    }
    TipsSymbolObject *obj = [symbolArray objectAtIndex:indexPath.row];
    
    if ([FSFonestock sharedInstance].marketVersion == FSMarketVersionUS) {
        [collectionCell.btn setTitle:obj.Symbol forState:UIControlStateNormal];
    } else {
        [collectionCell.btn setTitle:obj.fullName forState:UIControlStateNormal];
    }
    
    
    
    return collectionCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate cellBtnBeClicked:self.tag CollectionRow:indexPath.row];
}

-(void)prepareForReuse
{
    [_imgName setLabelize:NO];
}

@end
