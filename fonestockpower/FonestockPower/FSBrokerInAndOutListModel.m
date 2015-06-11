//
//  FSBrokerInAndOutListModel.m
//  FonestockPower
//
//  Created by Michael.Hsieh on 2014/12/4.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "FSBrokerInAndOutListModel.h"
#import <QuartzCore/QuartzCore.h>

@implementation FSBrokerInAndOutListModel

@end

@implementation FSBrokerChoice

@end

@implementation FSBrokerByBrokerData

@end

@implementation FSBrokerCustomData

@end


@interface FSBrokerParametersCell () {
    NSMutableArray *layoutConstraints;
}
@end

@implementation FSBrokerParametersCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        layoutConstraints = [NSMutableArray new];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 90, 50)];
        self.titleLabel.textColor = [UIColor redColor];
        self.titleLabel.font = [UIFont systemFontOfSize:19.0f];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addSubview:self.titleLabel];
        
        self.detailLabel = [[UILabel new]init];//WithFrame:CGRectMake(90, 0, 230, 50)];
        self.detailLabel.backgroundColor = [UIColor clearColor];
        self.detailLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.detailLabel.numberOfLines = 0;
        self.detailLabel.textColor = [UIColor blueColor];
        
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(90, 0)];
        [linePath addLineToPoint:CGPointMake(90, 555)];
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.lineWidth = 1.0;
        lineLayer.strokeColor = [UIColor grayColor].CGColor;
        lineLayer.fillColor = nil;
        lineLayer.path = linePath.CGPath;
        
        [self.contentView.layer addSublayer:lineLayer];
        [self addSubview:self.detailLabel];
        
        [self setNeedsUpdateConstraints];

    }

    return self;
}

-(void)updateConstraints
{
//    [self.contentView removeConstraints:self.contentView.constraints];
    [super updateConstraints];
    
    [self removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];

//    NSMutableArray *constraints = [NSMutableArray new];
    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_titleLabel, _detailLabel);
    
//    NSDictionary *metrics = @{@"titleLabelWidth":@ CELL_TITLE_CONTENT_WIDTH};
    
    // detailLabel
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel(titleLabelWidth)][_detailLabel(230)]|" options:0 metrics:metrics views:viewControllers]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]|" options:0 metrics:nil views:viewControllers]];
//    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[_detailLabel]|" options:0 metrics:nil views:viewControllers]];
    

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_titleLabel(90)][_detailLabel(230)]" options:0 metrics:nil views:viewControllers]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_titleLabel]|" options:0 metrics:nil views:viewControllers]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_detailLabel]|" options:0 metrics:nil views:viewControllers]];
    
//    [self replaceCustomizeConstraints:constraints];
    
    [self addConstraints:layoutConstraints];

}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.titleLabel.text = nil;
    self.detailLabel.text = nil;
}

- (void)addCustomizeConstraints:(NSArray *)newConstraints {
    [layoutConstraints addObjectsFromArray:newConstraints];
    [self.contentView addConstraints:layoutConstraints];
}

- (void)removeCustomizeConstraints {
    [self.contentView removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
}

- (void)replaceCustomizeConstraints:(NSArray *)newConstraints {
    [self removeCustomizeConstraints];
    [self addCustomizeConstraints:newConstraints];
}
@end


@interface FSBrokerParametersMainCell () {
    NSMutableArray *layoutConstraints;
}
@end

@implementation FSBrokerParametersMainCell


- (instancetype)initWithLStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        layoutConstraints = [[NSMutableArray alloc] init];
        
        self.mainLbl = [[UILabel alloc] init];
        self.mainLbl.textColor = [UIColor blueColor];
        self.mainLbl.translatesAutoresizingMaskIntoConstraints = NO;
        self.mainLbl.adjustsFontSizeToFitWidth = YES;
        self.mainLbl.textAlignment = NSTextAlignmentLeft;
        
        self.subLbl = [[UILabel alloc] init];
        self.subLbl.translatesAutoresizingMaskIntoConstraints = NO;
        self.subLbl.textAlignment = NSTextAlignmentRight;
        self.subLbl.textColor = [StockConstant PriceUpColor];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView addSubview:self.mainLbl];
        [self.contentView addSubview:self.subLbl];
        [self.contentView setTag:0];
        [self.contentView setNeedsUpdateConstraints];

    }
    return self;
}

- (instancetype)initWithRStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        layoutConstraints = [[NSMutableArray alloc] init];

        self.mainLbl = [[UILabel alloc] init];
        self.mainLbl.textColor = [UIColor blueColor];
        self.mainLbl.translatesAutoresizingMaskIntoConstraints = NO;
        self.mainLbl.adjustsFontSizeToFitWidth = YES;
        self.mainLbl.textAlignment = NSTextAlignmentRight;

        self.subLbl = [[UILabel alloc] init];
        self.subLbl.translatesAutoresizingMaskIntoConstraints = NO;
        self.subLbl.textAlignment = NSTextAlignmentLeft;
        self.subLbl.textColor = [StockConstant PriceDownColor];
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView addSubview:self.mainLbl];
        [self.contentView addSubview:self.subLbl];
        [self.contentView setTag:1];
        [self.contentView setNeedsUpdateConstraints];

    }
    return self;
}

-(void)updateConstraints
{
    [super updateConstraints];

    [self.contentView removeConstraints:layoutConstraints];

    NSNumber *mainWidth = [[NSNumber alloc] initWithFloat:60];
    NSDictionary *metrics = @{@"mainWidth":mainWidth};

    NSDictionary *viewControllers = NSDictionaryOfVariableBindings(_mainLbl, _subLbl);
//    NSMutableArray *constraints = [NSMutableArray new];
    
    [layoutConstraints removeAllObjects];
    if (self.contentView.tag == 0) {
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_mainLbl(90)][_subLbl(mainWidth)]" options:0 metrics:metrics views:viewControllers]];
    }else{
        [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_subLbl(mainWidth)][_mainLbl(90)]" options:0 metrics:metrics views:viewControllers]];
    }

    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainLbl]|" options:0 metrics:nil views:viewControllers]];
    [layoutConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_subLbl]|" options:0 metrics:nil views:viewControllers]];
    
//    if (self.contentView.tag == 0) {
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_mainLbl][_subLbl(mainWidth)]-2-|" options:0 metrics:metrics views:viewControllers]];
//    }else{
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-2-[_subLbl(mainWidth)][_mainLbl]-2-|" options:0 metrics:metrics views:viewControllers]];
//    }
//    
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_mainLbl]|" options:0 metrics:nil views:viewControllers]];
//        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_subLbl]|" options:0 metrics:nil views:viewControllers]];

//    [self replaceCustomizeConstraints:constraints];
    [self.contentView addConstraints:layoutConstraints];

}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.mainLbl.text = @"";
    self.subLbl.text = @"";
}
- (void)addCustomizeConstraints:(NSArray *)newConstraints {
    [layoutConstraints addObjectsFromArray:newConstraints];
    [self.contentView addConstraints:layoutConstraints];
}

- (void)removeCustomizeConstraints {
    [self.contentView removeConstraints:layoutConstraints];
    [layoutConstraints removeAllObjects];
}

- (void)replaceCustomizeConstraints:(NSArray *)newConstraints {
    [self removeCustomizeConstraints];
    [self addCustomizeConstraints:newConstraints];
}
@end
