//
//  FigureSearchModel.m
//  WirtsLeg
//
//  Created by Connor on 13/10/19.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "FigureSearchModel.h"
#import "FigureSearchCollectionViewCell.h"
#import "FigureSearchMyProfileModel.h"
#import "FMDB.h"

@interface FigureSearchModel(){
    BOOL isUS;
}

@property (strong, nonatomic) FigureSearchMyProfileModel * customModel;
@property (strong, nonatomic) NSMutableArray * figureSearchArray;
@end

static NSString *itemIdentifier = @"FigureSearchItemIdentifier";

@implementation FigureSearchModel

+ (FigureSearchModel *)sharedInstance {
    static FigureSearchModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[FigureSearchModel alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.figureSearchArray = [[NSMutableArray alloc]init];
        self.customModel = [[FigureSearchMyProfileModel alloc]init];
        self.currentOption = kFigureSearchSystemLong;
        NSString * appid = [FSFonestock sharedInstance].appId;
        NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
        
        if ([group isEqualToString:@"us"])
        {
            isUS = YES;
        }else{
            isUS = NO;
        }
    }
    return self;
}

-(int)countFigureSearchWithGategory:(NSString *)gategory{
    NSMutableArray * totalCount = [[NSMutableArray alloc]init];
    FSDataModelProc *dataModel = [FSDataModelProc sharedInstance];
    FSDatabaseAgent *dbAgent = dataModel.mainDB;
    
    [ dbAgent  inDatabase: ^ ( FMDatabase  * db )  {
        
        FMResultSet *message = [db executeQuery:@"SELECT count(*) AS count FROM FigureSearch WHERE gategory = ?",gategory];
        while ([message next]) {
            [totalCount addObject:[NSNumber numberWithInt:[message intForColumn:@"count"]]];
        }
    }];
    return [(NSNumber *)[totalCount objectAtIndex:0]intValue];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    if (self.currentOption == kFigureSearchSystemLong) {
        return [self countFigureSearchWithGategory:@"LongSystem"];
    } else if (self.currentOption == kFigureSearchSystemShort) {
        return [self countFigureSearchWithGategory:@"ShortSystem"];
    }else if (self.currentOption == kFigureSearchMyProfileLong){
        return [self countFigureSearchWithGategory:@"LongCustom"];
    }else if (self.currentOption == kFigureSearchMyProfileShort){
        return [self countFigureSearchWithGategory:@"ShortCustom"];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FigureSearchCollectionViewCell *cell = (FigureSearchCollectionViewCell *) [cv dequeueReusableCellWithReuseIdentifier:itemIdentifier forIndexPath:indexPath];
    
    if (self.currentOption == kFigureSearchSystemLong) {
        _figureSearchArray = [_customModel searchFigureSearchIdWithGategory:@"LongSystem" ItemOrder:[NSNumber numberWithInteger:indexPath.row+1]];
        
    } else if (self.currentOption == kFigureSearchSystemShort) {
        _figureSearchArray = [_customModel searchFigureSearchIdWithGategory:@"ShortSystem" ItemOrder:[NSNumber numberWithInteger:indexPath.row+1]];
    } else if (self.currentOption == kFigureSearchMyProfileLong){
        _figureSearchArray = [_customModel searchFigureSearchIdWithGategory:@"LongCustom" ItemOrder:[NSNumber numberWithInteger:indexPath.row+1]];
    }else if (self.currentOption == kFigureSearchMyProfileShort){
        _figureSearchArray = [_customModel searchFigureSearchIdWithGategory:@"ShortCustom" ItemOrder:[NSNumber numberWithInteger:indexPath.row+1]];
    }
    cell.title.text = NSLocalizedStringFromTable([_figureSearchArray objectAtIndex:1], @"FigureSearch", nil);
    if (isUS) {
        cell.title.font = [UIFont systemFontOfSize:13];
    }else{
        cell.title.font = [UIFont systemFontOfSize:16];
    }
    
    cell.imageView.image = [UIImage imageWithData:[_figureSearchArray objectAtIndex:5]];

    return cell;
}

@end
