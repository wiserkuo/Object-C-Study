//
//  FSMultiChartViewFlowLayout.m
//  Bullseye
//
//  Created by Shen Kevin on 13/8/5.
//
//

#import "FSMultiChartViewFlowLayout.h"

@implementation FSMultiChartViewFlowLayout
- (id)init
{
    if (self = [super init])
    {
        self.itemSize = CGSizeMake(100, 130);
        self.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        self.minimumInteritemSpacing = 1.0f;
        self.minimumLineSpacing = 1.0f;
//        self.headerReferenceSize = CGSizeMake([[UIScreen mainScreen] bounds].size.width, 44);
//        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        self.sectionInset = UIEdgeInsetsMake(32, 32, 32, 32);
    }
    return self;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //this is what forces the collectionview to only display 4 cells for both orientations. Changing the "-80" will adjust the horizontal space between the cells.
    CGSize retval = CGSizeMake(100, 161);
    
    return retval;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    // for the entire section, which we have set to 1, adjust the space at
    // (top, left, bottom, right)
    // keep in mind if you change this, you will need to adjust the retVal
    // in the method above
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    CGFloat interimSpacing = 0.0f;
    
    return interimSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    CGFloat lineSpacing = 0.0f;
    
    return lineSpacing;
}

@end
