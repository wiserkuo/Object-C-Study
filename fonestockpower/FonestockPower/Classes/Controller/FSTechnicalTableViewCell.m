//
//  FSTechnicalTableViewCell.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2015/1/5.
//  Copyright (c) 2015年 Fonestock. All rights reserved.
//

#import "FSTechnicalTableViewCell.h"

@interface FSTechnicalTableViewCell(){
    NSMutableArray *layoutConstraints;

}

@end

@implementation FSTechnicalTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 44)];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textAlignment = NSTextAlignmentRight;
        //        [self.detailLabel1 setTextColor:[UIColor blueColor]];
        //        self.detailLabel1.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_titleLabel];
        
        self.detailLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 70, 44)];
        self.detailLabel1.numberOfLines = 0;
        self.detailLabel1.textAlignment = NSTextAlignmentRight;
//        [self.detailLabel1 setTextColor:[UIColor blueColor]];
//        self.detailLabel1.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_detailLabel1];
        
        self.detailLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(120, 0, 70, 44)];
        self.detailLabel2.numberOfLines = 0;
        self.detailLabel2.textAlignment = NSTextAlignmentRight;
//        [self.detailLabel2 setTextColor:[UIColor blueColor]];
//        self.detailLabel2.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_detailLabel2];
        
        self.detailLabel3 = [[UILabel alloc] init];
        self.detailLabel3.numberOfLines = 0;
//        [self.detailLabel3 setTextColor:[UIColor blueColor]];
//        self.detailLabel3.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_detailLabel3];
        
        self.detailLabel4 = [[UILabel alloc] init];
        self.detailLabel4.numberOfLines = 0;
//        [self.detailLabel4 setTextColor:[UIColor blueColor]];
//        self.detailLabel4.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_detailLabel4];
        
        self.detailLabel5 = [[UILabel alloc] init];
        self.detailLabel5.numberOfLines = 0;
//        [self.detailLabel5 setTextColor:[UIColor redColor]];
//        self.detailLabel5.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_detailLabel5];
        
        self.detailLabel6 = [[UILabel alloc] init];
        self.detailLabel6.numberOfLines = 0;
//        [self.detailLabel6 setTextColor:[UIColor redColor]];
//        self.detailLabel6.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_detailLabel6];
        
        self.detailLabel7 = [[UILabel alloc] init];
        self.detailLabel7.numberOfLines = 0;
//        [self.detailLabel7 setTextColor:[UIColor redColor]];
//        self.detailLabel7.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_detailLabel7];
        
        self.detailLabel8 = [[UILabel alloc] init];
        self.detailLabel8.numberOfLines = 0;
//        [self.detailLabel8 setTextColor:[UIColor redColor]];
//        self.detailLabel8.translatesAutoresizingMaskIntoConstraints=NO;
        [self.contentView addSubview:_detailLabel8];
        
//        [self setNeedsUpdateConstraints];
    }
    return self;
}

//-(void)updateConstraints{
//    
//    [super updateConstraints];
//    
//    [self.contentView removeConstraints:layoutConstraints];
//    
//}
//
//- (void)addCustomizeConstraints:(NSArray *)newConstraints {
//    [layoutConstraints addObjectsFromArray:newConstraints];
//    [self.contentView addConstraints:layoutConstraints];
//}
//
//- (void)removeCustomizeConstraints {
//    [self.contentView removeConstraints:layoutConstraints];
//    [layoutConstraints removeAllObjects];
//}
//
//- (void)replaceCustomizeConstraints:(NSArray *)newConstraints {
//    [self removeCustomizeConstraints];
//    [self addCustomizeConstraints:newConstraints];
//}
//
- (void)prepareForReuse {
    [super prepareForReuse];
    self.detailLabel1.text = @"";
    self.detailLabel2.text = @"";
    self.detailLabel3.text = @"";
    self.detailLabel4.text = @"";
    self.detailLabel5.text = @"";
    self.detailLabel6.text = @"";
    self.detailLabel7.text = @"";
    self.detailLabel8.text = @"";

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
