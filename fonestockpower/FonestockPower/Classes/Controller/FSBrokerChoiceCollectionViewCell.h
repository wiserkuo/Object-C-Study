//
//  FSBrokerChoiceCollectionViewCell.h
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/3.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FSBrokerChoiceCollectionViewCell : UICollectionViewCell

@property UILabel *label;

@end

@interface FStrackCollectionViewCell : UICollectionViewCell

@property FSUIButton *btn;

@end

@interface FSheadOfficeCollectionViewCell : UICollectionViewCell

@property FSUIButton *btn;

@end

@interface FSbranchOfficeCollectionViewCell : FSheadOfficeCollectionViewCell

@end
