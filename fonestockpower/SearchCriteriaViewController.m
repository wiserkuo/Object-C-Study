//
//  SearchCriteriaViewController.m
//  FonestockPower
//
//  Created by Kenny on 2014/10/27.
//  Copyright (c) 2014年 Fonestock. All rights reserved.
//

#import "SearchCriteriaViewController.h"
#import "SearchCriteriaModel.h"
#import "CheckBoxTableViewCell.h"
#import "UIViewController+CustomNavigationBar.h"
#import "FigureSearchConditionViewController.h"

@interface SearchCriteriaViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *mainTableView;
    NSMutableArray *sliderArray;
    SearchCriteriaModel *model;
    BOOL firstFlag;
    NSString *fileName;
    NSMutableDictionary *searchDict;
    FigureSearchConditionViewController *searchViewController;
    NSString *detailFormula;
}
@end


@implementation SearchCriteriaViewController
//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//        _formula = @"";
//    }
//    return self;
//}
-(id)initWithName:(NSString *)name
{
    self = [super init];
    if(self) {
        _formula = @"";
        fileName = name;
        searchDict = [NSKeyedUnarchiver unarchiveObjectWithFile:[[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]]];
        if(searchDict){
            sliderArray = [searchDict objectForKey:@"SliderArray"];
            _formula = [searchDict objectForKey:@"Formula"];
        }else{
            searchDict = [[NSMutableDictionary alloc] init];
            model = [[SearchCriteriaModel alloc]init];
            sliderArray = [model getCriteriaArray];
        }
    }
    return self;
}

-(void)setTarget:(id)obj
{
    searchViewController = (FigureSearchConditionViewController *)obj;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedStringFromTable(@"設定篩選條件", @"SearchCriteria", nil);
    [self setUpImageBackButton];
    [self initView];
    [self.view setNeedsUpdateConstraints];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [mainTableView setContentOffset:CGPointMake(0, 0)];
    detailFormula = _formula;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(searchViewController != nil){
        if(detailFormula != _formula){
            [searchViewController goSearch];
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initView
{
    mainTableView = [[UITableView alloc] init];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    mainTableView.bounces = NO;
    mainTableView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:mainTableView];
    [mainTableView reloadData];
}

-(void)updateViewConstraints
{
    [super updateViewConstraints];
    
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(mainTableView);
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[mainTableView]|" options:0 metrics:nil views:viewDictionary]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[mainTableView]|" options:0 metrics:nil views:viewDictionary]];
    [self replaceCustomizeConstraints:constraints];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SliderObj *obj = [sliderArray objectAtIndex:indexPath.row];
    if(indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3){
        NSString *CellIdentifier = [NSString stringWithFormat:@"cell%d",(int)indexPath.row];
        CheckBoxTableViewCell *cell = (CheckBoxTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if(cell == nil){
            cell=[[CheckBoxTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = obj.title;
        cell.checkBtn.selected = obj.selected;
        if(obj.selected){
            [cell.titleLabel setAlpha:1];
        }else{
            [cell.titleLabel setAlpha:0.5];
        }
        [cell.checkBtn addTarget:self action:@selector(checkHandler:) forControlEvents:UIControlEventTouchUpInside];
        [cell.checkBtn addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }else{
        NSString *CellIdentifer= [NSString stringWithFormat:@"cell%d",(int)indexPath.row];
        SliderTableViewCell *cell=(SliderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifer];
        if(cell == nil){
            cell=[[SliderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifer];

        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.titleLabel.text = obj.title;
        cell.slider.minimumValue = obj.lowerLimit - obj.rangeValue;
        cell.slider.maximumValue = obj.upperLimit + obj.rangeValue;
        cell.slider.sliderMin = obj.lowerLimit;
        cell.slider.sliderMax = obj.upperLimit;
        cell.slider.stepValue = obj.rangeValue;
        cell.slider.minimumRange = obj.rangeValue;
        cell.slider.stepValueContinuously = YES;
        cell.slider.upperValue = obj.maxValue;
        cell.slider.lowerValue = obj.minValue;
        [cell.slider addTarget:self action:@selector(valueChange:) forControlEvents:UIControlEventValueChanged];
        [cell.slider setLowerValue:obj.minValue upperValue:obj.maxValue animated:NO];
        

        cell.checkBtn.selected = obj.selected;
        [cell.checkBtn addTarget:self action:@selector(checkHandler:) forControlEvents:UIControlEventTouchUpInside];
        if(obj.selected){
            cell.slider.enabled = YES;
            [cell.slider setAlpha:1];
            [cell.titleLabel setAlpha:1];
            [cell.valueLabel setAlpha:1];
            [cell.minLabel setAlpha:1];
            [cell.maxLabel setAlpha:1];
            [cell.midLabel setAlpha:1];
        }else{
            cell.slider.enabled = NO;
            [cell.slider setAlpha:0.5];
            [cell.titleLabel setAlpha:0.5];
            [cell.valueLabel setAlpha:0.5];
            [cell.minLabel setAlpha:0.5];
            [cell.maxLabel setAlpha:0.5];
            [cell.midLabel setAlpha:0.5];
        }
        if(indexPath.row == 4){
            cell.minLabel.text = [NSString stringWithFormat:@"↓%d", (int)obj.lowerLimit];
            cell.maxLabel.text = [NSString stringWithFormat:@"%d↑", (int)obj.upperLimit];
            cell.midLabel.text = [NSString stringWithFormat:@"%.0f", obj.medianValue];
            if(cell.slider.lowFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%d", NSLocalizedStringFromTable(@"小於", @"SearchCriteria", nil),(int)cell.slider.upperValue];
            }else if(cell.slider.upperFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%d", NSLocalizedStringFromTable(@"大於", @"SearchCriteria", nil), (int)cell.slider.lowerValue];
            }else{
                cell.valueLabel.text = [NSString stringWithFormat:@"%d ~ %d", (int)cell.slider.lowerValue, (int)cell.slider.upperValue];
            }
        }else if(indexPath.row == 5){
            cell.minLabel.text = [NSString stringWithFormat:@"↓%d", (int)obj.lowerLimit+1000];
            cell.maxLabel.text = [NSString stringWithFormat:@"%d↑", (int)obj.upperLimit+1000];
            cell.midLabel.text = [NSString stringWithFormat:@"%d", (int)obj.medianValue+1000];
            if(cell.slider.lowFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%d", NSLocalizedStringFromTable(@"小於", @"SearchCriteria", nil), (int)cell.slider.upperValue+1000];
            }else if(cell.slider.upperFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%d", NSLocalizedStringFromTable(@"大於", @"SearchCriteria", nil), (int)cell.slider.lowerValue+1000];
            }else{
                cell.valueLabel.text = [NSString stringWithFormat:@"%d ~ %d", (int)cell.slider.lowerValue+1000, (int)cell.slider.upperValue+1000];
            }
        }else if(indexPath.row == 6){
            cell.minLabel.text = [NSString stringWithFormat:@"↓%.1f", obj.lowerLimit+0.1];
            cell.maxLabel.text = [NSString stringWithFormat:@"%.1f↑", obj.upperLimit+0.1];
            cell.midLabel.text = [NSString stringWithFormat:@"%.1f", obj.medianValue+0.1];
            if(cell.slider.lowFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%.1f", NSLocalizedStringFromTable(@"小於", @"SearchCriteria", nil), cell.slider.upperValue+0.1];
            }else if(cell.slider.upperFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%.1f", NSLocalizedStringFromTable(@"大於", @"SearchCriteria", nil), cell.slider.lowerValue+0.1];
            }else{
                cell.valueLabel.text = [NSString stringWithFormat:@"%.1f ~ %.1f", cell.slider.lowerValue+0.1, cell.slider.upperValue+0.1];
            }
        }else if(indexPath.row == 7){
            cell.minLabel.text = [NSString stringWithFormat:@"↓%d", (int)obj.lowerLimit+10];
            cell.maxLabel.text = [NSString stringWithFormat:@"%d↑", (int)obj.upperLimit+10];
            cell.midLabel.text = [NSString stringWithFormat:@"%d", (int)obj.medianValue];
            if(cell.slider.lowFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%d", NSLocalizedStringFromTable(@"小於", @"SearchCriteria", nil), (int)cell.slider.upperValue+10];
            }else if(cell.slider.upperFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%d", NSLocalizedStringFromTable(@"大於", @"SearchCriteria", nil), (int)cell.slider.lowerValue+10];
            }else{
                cell.valueLabel.text = [NSString stringWithFormat:@"%d ~ %d", (int)cell.slider.lowerValue+10, (int)cell.slider.upperValue+10];
            }
        }else if(indexPath.row == 8){
            cell.minLabel.text = [NSString stringWithFormat:@"↓%.1f", obj.lowerLimit];
            cell.maxLabel.text = [NSString stringWithFormat:@"%.1f↑", obj.upperLimit];
            cell.midLabel.text = [NSString stringWithFormat:@"%.0f", obj.medianValue];
            if(cell.slider.lowFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%.1f", NSLocalizedStringFromTable(@"小於", @"SearchCriteria", nil), cell.slider.upperValue];
            }else if(cell.slider.upperFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%.1f", NSLocalizedStringFromTable(@"大於", @"SearchCriteria", nil), cell.slider.lowerValue];
            }else{
                if(cell.slider.lowerValue ==-0){
                    cell.valueLabel.text = [NSString stringWithFormat:@"0 ~ %.1f", cell.slider.upperValue];
                }else if(cell.slider.upperValue ==-0){
                    cell.valueLabel.text = [NSString stringWithFormat:@"%.1f ~ 0", cell.slider.lowerValue];
                }else{
                    cell.valueLabel.text = [NSString stringWithFormat:@"%.1f ~ %.1f", cell.slider.lowerValue, cell.slider.upperValue];
                }
            }
        }else{
            cell.minLabel.text = [NSString stringWithFormat:@"↓%.0f%%", obj.lowerLimit*100];
            cell.maxLabel.text = [NSString stringWithFormat:@"%.0f%%↑", obj.upperLimit*100];
            cell.midLabel.text = [NSString stringWithFormat:@"%.0f%%", obj.medianValue*100];
            if(cell.slider.lowFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%.0f%%", NSLocalizedStringFromTable(@"小於", @"SearchCriteria", nil), cell.slider.upperValue*100];
            }else if(cell.slider.upperFlag){
                cell.valueLabel.text = [NSString stringWithFormat:@"%@%.0f%%", NSLocalizedStringFromTable(@"大於", @"SearchCriteria", nil), cell.slider.lowerValue*100];
            }else{
                if(cell.slider.lowerValue ==-0){
                    cell.valueLabel.text = [NSString stringWithFormat:@"0 ~ %.0f%%", cell.slider.upperValue*100];
                }else if(cell.slider.upperValue ==-0){
                    cell.valueLabel.text = [NSString stringWithFormat:@"%.0f%% ~ 0", cell.slider.lowerValue*100];
                }else{
                    cell.valueLabel.text = [NSString stringWithFormat:@"%.0f%% ~ %.0f%%", cell.slider.lowerValue*100, cell.slider.upperValue*100];;
                }
            }
        }
        return cell;
    }
}

-(void)valueChange:(id)sender
{
    NSIndexPath *indexPath;
    SliderTableViewCell *cell;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if(version>=8.0f){
        cell = (SliderTableViewCell *)[sender superview];
        indexPath = [mainTableView indexPathForCell:cell];
    }
    else{
        UIView *view = [sender superview];
        cell = (SliderTableViewCell *)[view superview];
        indexPath = [mainTableView indexPathForCell:cell];
    }
    if(indexPath.row >3){
        SliderObj *obj = [sliderArray objectAtIndex:indexPath.row];
        obj.maxValue = cell.slider.upperValue;
        obj.minValue = cell.slider.lowerValue;
        if(indexPath.row == 4){
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f", obj.keyWrod, cell.slider.lowerValue];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.0f", obj.keyWrod, cell.slider.upperValue];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f and %@ <= %.0f",obj.keyWrod, cell.slider.lowerValue, obj.keyWrod, cell.slider.upperValue];
            }
        }else if(indexPath.row == 5){
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f", obj.keyWrod, cell.slider.lowerValue+1000];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.0f", obj.keyWrod, cell.slider.upperValue+1000];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f and %@ <= %.0f",obj.keyWrod, cell.slider.lowerValue+1000, obj.keyWrod, cell.slider.upperValue+1000];
            }
        }else if(indexPath.row == 6){
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.1f", obj.keyWrod, cell.slider.lowerValue+0.1];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.1f", obj.keyWrod, cell.slider.upperValue+0.1];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.1f and %@ <= %.1f",obj.keyWrod, cell.slider.lowerValue+0.1, obj.keyWrod, cell.slider.upperValue+0.1];
            }
        }else if(indexPath.row == 7){
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f", obj.keyWrod, cell.slider.lowerValue+10];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.0f", obj.keyWrod, cell.slider.upperValue+10];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f and %@ <= %.0f",obj.keyWrod, cell.slider.lowerValue+10, obj.keyWrod, cell.slider.upperValue+10];
            }
        }else if(indexPath.row == 8){
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.1f", obj.keyWrod, cell.slider.lowerValue];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.1f", obj.keyWrod, cell.slider.upperValue];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.1f and %@ <= %.1f",obj.keyWrod, cell.slider.lowerValue, obj.keyWrod, cell.slider.upperValue];
            }
        }else{
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.2f", obj.keyWrod, cell.slider.lowerValue];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.2f", obj.keyWrod, cell.slider.upperValue];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.2f and %@ <= %.2f",obj.keyWrod, cell.slider.lowerValue, obj.keyWrod, cell.slider.upperValue];
            }
        }
        [sliderArray setObject:obj atIndexedSubscript:indexPath.row];
        [mainTableView reloadData];
    }
    [self getFormula];
}

-(void)checkHandler:(FSUIButton *)sender
{
    NSIndexPath *indexPath;
    SliderTableViewCell *cell;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if(version>=8.0f){
        cell = (SliderTableViewCell *)[sender superview];
        indexPath = [mainTableView indexPathForCell:cell];
    }
    else{
        UIView *view = [sender superview];
        cell = (SliderTableViewCell *)[view superview];
        indexPath = [mainTableView indexPathForCell:cell];
    }
    
    SliderObj *obj = [sliderArray objectAtIndex:indexPath.row];
    if(sender.selected){
        obj.selected = NO;
    }else{
        obj.selected = YES;
    }
    
    if(indexPath.row >3){
        SliderObj *obj = [sliderArray objectAtIndex:indexPath.row];
        obj.maxValue = cell.slider.upperValue;
        obj.minValue = cell.slider.lowerValue;
        if(indexPath.row == 4){
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f", obj.keyWrod, cell.slider.lowerValue];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.0f", obj.keyWrod, cell.slider.upperValue];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f and %@ <= %.0f",obj.keyWrod, cell.slider.lowerValue, obj.keyWrod, cell.slider.upperValue];
            }
        }else if(indexPath.row == 5){
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f", obj.keyWrod, cell.slider.lowerValue+1000];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.0f", obj.keyWrod, cell.slider.upperValue+1000];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f and %@ <= %.0f",obj.keyWrod, cell.slider.lowerValue+1000, obj.keyWrod, cell.slider.upperValue+1000];
            }
        }else if(indexPath.row == 6){
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.1f", obj.keyWrod, cell.slider.lowerValue+0.1];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.1f", obj.keyWrod, cell.slider.upperValue+0.1];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.1f and %@ <= %.1f",obj.keyWrod, cell.slider.lowerValue+0.1, obj.keyWrod, cell.slider.upperValue+0.1];
            }
        }else if(indexPath.row == 7){
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f", obj.keyWrod, cell.slider.lowerValue+10];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.0f", obj.keyWrod, cell.slider.upperValue+10];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.0f and %@ <= %.0f",obj.keyWrod, cell.slider.lowerValue+10, obj.keyWrod, cell.slider.upperValue+10];
            }
        }else if(indexPath.row == 8){
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.1f", obj.keyWrod, cell.slider.lowerValue];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.1f", obj.keyWrod, cell.slider.upperValue];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.1f and %@ <= %.1f",obj.keyWrod, cell.slider.lowerValue, obj.keyWrod, cell.slider.upperValue];
            }
        }else{
            if(cell.slider.upperFlag){
                obj.formula = [NSString stringWithFormat:@"%@ >= %.2f", obj.keyWrod, cell.slider.lowerValue];
            }else if(cell.slider.lowFlag){
                obj.formula = [NSString stringWithFormat:@"%@ <= %.2f", obj.keyWrod, cell.slider.upperValue];
            }else{
                obj.formula = [NSString stringWithFormat:@"%@ >= %.2f and %@ <= %.2f",obj.keyWrod, cell.slider.lowerValue, obj.keyWrod, cell.slider.upperValue];
            }
        }
        [sliderArray setObject:obj atIndexedSubscript:indexPath.row];
    }
    [mainTableView reloadData];
    [self getFormula];
}


-(void)getFormula
{
    _formula = @"";
    firstFlag = YES;
    for(int i =0; i<[sliderArray count]; i++){
        SliderObj *obj = [sliderArray objectAtIndex:i];
        if(obj.selected){
            if(firstFlag){
                _formula = [NSString stringWithFormat:@"%@", obj.formula];
            }else{
                _formula = [NSString stringWithFormat:@"%@ and %@", _formula, obj.formula];
            }
            firstFlag = NO;
        }
    }
    
    NSString *pathDate = [[CodingUtil fonestockDocumentsPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", fileName]];
    [searchDict setObject:_formula forKey:@"Formula"];
    [searchDict setObject:sliderArray forKey:@"SliderArray"];
    [NSKeyedArchiver archiveRootObject:searchDict toFile:pathDate];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sliderArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2 || indexPath.row == 3){
        return 44.0f;
    }else{
        return 100.0f;
    }
}

@end

