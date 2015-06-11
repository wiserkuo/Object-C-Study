//
//  EDOActionTableCell.m
//  FonestockPower
//
//  Created by Kenny on 2014/5/30.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "EODActionTableCell.h"
#import "EODActionCollectionViewLayout.h"
#import "FigureSearchCollectionViewCell.h"


@implementation EODActionTableCell
{
    EODActionCollectionViewLayout *layout;
    int imgCount;
    NSMutableArray *imgArray;
    NSMutableArray *nameArray;
    BOOL isUS;
}
static NSString *itemIdentifier = @"FigureSearchItemIdentifier";
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier controller:(id)obj
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.stockName = [[UILabel alloc] init];
        _stockName.textAlignment = NSTextAlignmentCenter;
        _stockName.font = [UIFont boldSystemFontOfSize:20.0f];
        _stockName.textColor = [UIColor blueColor];
        _stockName.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_stockName];
        
        self.verticalLine = [[UIView alloc] init];
        _verticalLine.backgroundColor = [UIColor blackColor];
        _verticalLine.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_verticalLine];
        
        
        self.rightView = [[UIView alloc] init];
        _rightView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_rightView];
        
        self.horizontalLine = [[UIView alloc] init];
        _horizontalLine.translatesAutoresizingMaskIntoConstraints = NO;
        _horizontalLine.backgroundColor = [UIColor grayColor];
        [self addSubview:_horizontalLine];
        
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        if ([group isEqualToString:@"us"])
        {
            isUS = YES;
        }else{
            isUS = NO;
        }
        
        imgArray = [[NSMutableArray alloc] init];
        nameArray = [[NSMutableArray alloc] init];
        
        [self initCollectionView];
        [self processLayout];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initCollectionView
{
    layout = [[EODActionCollectionViewLayout alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[FigureSearchCollectionViewCell class] forCellWithReuseIdentifier:itemIdentifier];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    _collectionView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.rightView addSubview:_collectionView];
}


-(void)processLayout
{
    NSDictionary *viewController = NSDictionaryOfVariableBindings(_verticalLine, _stockName, _rightView,_horizontalLine);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_stockName(80)]-20-[_verticalLine(2)]-[_rightView(200)]" options:0 metrics:nil views:viewController]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-45-[_stockName(45)]" options:0 metrics:nil views:viewController]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightView(128)][_horizontalLine(2)]" options:0 metrics:nil views:viewController]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_verticalLine(130)]" options:0 metrics:nil views:viewController]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_horizontalLine(500)]" options:0 metrics:nil views:viewController]];
}

-(void)setCount:(int)count
{
    imgCount = count;
    [self.collectionView setFrame:CGRectMake(0, -25, 200, 145)];
}

-(void)setImgCount:(int)count
{
    imgCount = count;
}

-(void)setImgArray:(NSMutableArray*)array
{
    imgArray = array;
}

-(void)setNameArray:(NSMutableArray*)array
{
    nameArray = array;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imgCount;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FigureSearchCollectionViewCell *cell = (FigureSearchCollectionViewCell *)[cv dequeueReusableCellWithReuseIdentifier:itemIdentifier forIndexPath:indexPath];
    if(!cell){
        cell = [[FigureSearchCollectionViewCell alloc] initWithFrame:CGRectZero];
    }
    if([imgArray count]){
        cell.imageView.image = [UIImage imageWithData:[imgArray objectAtIndex:indexPath.row]];
        cell.title.text = [nameArray objectAtIndex:indexPath.row];
    }
    cell.title.adjustsFontSizeToFitWidth = NO;
    cell.title.lineBreakMode = NSLineBreakByWordWrapping;
    cell.title.numberOfLines = 2;
    if (isUS) {
        cell.title.font = [UIFont boldSystemFontOfSize:13.0f];
    }else{
        cell.title.font = [UIFont boldSystemFontOfSize:18.0f];
    }

    return cell;
}

- (void)prepareForReuse {
	[super prepareForReuse];
    self.collectionView = nil;
    self.rightView = nil;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate btnBeClick:self.tag];
}

@end
