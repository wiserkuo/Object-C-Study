//
//  BottonView.m
//  BullsEyeAlpha
//
//  Created by Ming-Zhe Wu on 2008/10/2.
//  Copyright 2008 NHCUE. All rights reserved.
//

#import "BottonView.h"
#import "RSIView.h"
#import "KDJView.h"
#import "MACDView.h"
#import "VolumeView.h"
#import "BiasView.h"
#import "OBVView.h"
#import "PsychologicalLine.h"
#import "WilliamsView.h"
#import "MomentumView.h"
#import "OscillatorView.h"
#import "ARBRView.h"
#import "DMIView.h"
#import "TowerView.h"
#import "BottomDataView.h"
#import "VRView.h"
#import "GainView.h"
//#define _kNumberOfTables 14 //( all bottom view indicator)
//#define day_kNumberOfTables 15

@implementation BottonView

@synthesize targetView;

@synthesize dataView; // 對映page呈現某個view : RSIView, KDView, MACDView...
@synthesize subDataViews; // 擺所有要被scroll的view (RSIView, KDView, MACDView..)
@synthesize dataScrollView;

@synthesize subDataViewsIndex;

@dynamic historicData;

@synthesize yLines;
@synthesize drawAndScrollController;
@synthesize subViewChartFrame;
@synthesize subViewChartFrameOffset;

@synthesize indicatorTableNumber;
@synthesize indicator;
@synthesize selectedIndicator;
@synthesize selectedIndicatorParameterCount;

- (id)init {
	if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
		dataView = [[BottomDataView alloc]initWithFrame:self.bounds];
        dataView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dataView.bottonView = self;
        subDataViews = [[NSMutableArray alloc]init];
        
        [self addSubview:dataView];
	}
	return self;
}

- (void)setHistoricData:(NSObject<HistoricTickDataSourceProtocol> *)historicData {

    for (UIView<AnalysisChart> *view in subDataViews) {
        if ((id)view != [NSNull null])
            view.historicData = historicData;
    }
}

-(void)dealloc{

}

- (void)loadWithDefaultPage:(NSInteger)page {
    dataView.drawAndScrollController = drawAndScrollController;
	ShowPicker = NO;
    cellNumber = 1;
    self.ShowIndex = [[NSMutableArray alloc]init];
    CGFloat chartWidth = [drawAndScrollController chartWidth];
    //CGFloat chartHeight = drawAndScrollController.bottonView1.frame.size.height;
    CGFloat chartHeight = drawAndScrollController.bottomViewHeight;
    CGFloat zoomOrigin = drawAndScrollController.chartZoomOrigin;

    // chartFrame (線圖矩型方框大小) & chartFrameOffset(線圖矩型方框與所在view左上頂點的offset)
    CGRect chartFrame;
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        chartFrame = CGRectMake(0, 0, chartWidth, chartHeight-17);
    }else{
        chartFrame = CGRectMake(0, 0, chartWidth, chartHeight-13);
    }
    CGPoint chartFrameOffset = CGPointMake(zoomOrigin, 0);

    /*
    // set scrollView
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, scrollView.frame.size.height * _kNumberOfTables); // size.height * pages
    scrollView.showsHorizontalScrollIndicator = YES;
    scrollView.showsVerticalScrollIndicator = YES;
    scrollView.scrollsToTop = NO;
    scrollView.contentOffset = CGPointMake(0, scrollView.frame.size.height * page);
    */

    currentPage = page;

    CGRect dataBounds = dataView.bounds;
    CGRect frameRect = CGRectMake(dataBounds.origin.x+1, dataBounds.origin.y+14, chartWidth, chartHeight-11);

    UIScrollView *view = [[UIScrollView alloc] initWithFrame:frameRect];
    dataScrollView = view;
    dataScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    dataScrollView.showsVerticalScrollIndicator = NO;
    dataScrollView.directionalLockEnabled = YES;
    dataScrollView.clipsToBounds = YES;
    dataScrollView.contentInset = UIEdgeInsetsMake(0, -1, 0, -1);
    dataScrollView.delegate = self;
    dataScrollView.minimumZoomScale = 1;
    dataScrollView.maximumZoomScale = drawAndScrollController.chartZoomMax;
    [dataView addSubview:dataScrollView];

    subViewChartFrame = chartFrame;

    subViewChartFrameOffset = chartFrameOffset;
    
//    subDataViews = [[NSMutableArray alloc] initWithCapacity:_kNumberOfTables];

//    self.subDataViews = array;

    for (int i = 0; i < _kNumberOfTables; i++){
        [subDataViews addObject:[NSNull null]];
    }

    CGRect rect = CGRectMake(0, 0, (chartFrame.size.width+2)*zoomOrigin, dataScrollView.bounds.size.height);
    subViewFrame = rect;

    subViewTransform = CGAffineTransformIdentity;
	self.indicator = [[FSDataModelProc sharedInstance]indicator];
	subDataViewsIndex = page;
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    
//    UIView * touchView = [[UIView alloc]initWithFrame:CGRectMake(chartWidth+1, 11, self.frame.size.width-chartWidth, 20)];
//    touchView.backgroundColor = [UIColor grayColor];
//    [touchView addGestureRecognizer:tap];
//    touchView.userInteractionEnabled = YES;
//    [self addSubview:touchView];
    
	
}


-(void)changeWidth{
    CGFloat chartWidth;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if(version>=8.0f){
        if ([[UIScreen mainScreen] applicationFrame].size.width<400) {
            chartWidth = [[UIScreen mainScreen] applicationFrame].size.width*0.86;
        }else{
            if (drawAndScrollController.arrowUpDownType==4 || drawAndScrollController.arrowUpDownType == 5) {
                chartWidth = [[UIScreen mainScreen] applicationFrame].size.width*0.915;
            }else{
                chartWidth = [[UIScreen mainScreen] applicationFrame].size.width*0.825;
            }
            
        }
    }else{
        if ([[UIScreen mainScreen] applicationFrame].size.width==320) {
            chartWidth = [[UIScreen mainScreen] applicationFrame].size.width*0.86;
        }else{
            if (drawAndScrollController.arrowUpDownType==4 || drawAndScrollController.arrowUpDownType == 5) {
                chartWidth = [[UIScreen mainScreen] applicationFrame].size.height*0.915;
            }else{
                chartWidth = [[UIScreen mainScreen] applicationFrame].size.height*0.825;
            }
            
        }
    }
    
    CGFloat chartHeight = drawAndScrollController.bottomViewHeight;
    CGFloat zoomOrigin = drawAndScrollController.chartZoomOrigin;
    CGRect chartFrame;
    int screenHeight = [[UIScreen mainScreen] applicationFrame].size.height;
    if (screenHeight==460) {
        chartFrame = CGRectMake(0, 0, chartWidth, chartHeight-17);
    }else{
        chartFrame = CGRectMake(0, 0, chartWidth, chartHeight-13);
    }
    CGRect dataBounds = dataView.bounds;
    [dataScrollView setFrame:CGRectMake(dataBounds.origin.x+1, dataBounds.origin.y+14, chartWidth, chartHeight-11)];
    subViewChartFrame = chartFrame;
    CGRect rect = CGRectMake(0, 0, (chartFrame.size.width+2)*zoomOrigin, dataScrollView.bounds.size.height);
    subViewFrame = rect;
}


- (void)updateDateRange:(int)xLines chartWidth:(float)width frameX:(float)x frameWidth:(float)frameWidth {

    subViewChartFrame = CGRectMake(0, 0, width, subViewChartFrame.size.height);
    subViewFrame = CGRectMake(x, 0, frameWidth, subViewFrame.size.height);

    for (UIView<AnalysisChart> *view in subDataViews) {

        if ((id)view == [NSNull null]) continue;

        view.xLines = xLines;
        view.chartFrame = subViewChartFrame;
        view.frame = subViewFrame;
    }

    dataScrollView.contentSize = CGSizeMake(frameWidth, dataScrollView.contentSize.height);
}


- (void)updateZoomScale:(float)scale andWidth:(float)width {

    subViewTransform = CGAffineTransformMakeScale(scale, 1);

    for (UIView<AnalysisChart> *view in subDataViews) {

        if ((id)view == [NSNull null]) continue;

        view.transform = subViewTransform;
        view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    }

    dataScrollView.contentSize = CGSizeMake(width, dataScrollView.contentSize.height);
}


- (void)postZoomToScale:(float)scale andWidth:(float)width {

    subViewTransform = CGAffineTransformMakeScale(scale, 1);

    for (UIView<AnalysisChart> *view in subDataViews) {

        if ((id)view == [NSNull null]) continue;

        view.zoomTransform = subViewTransform;
    }

    dataScrollView.contentSize = CGSizeMake(width, dataScrollView.contentSize.height);
}


- (void)drawRect:(CGRect)rect {
    //畫外框
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context, 1);
	[[UIColor blackColor] set];
    if(self.bounds.size.width>320){
        UIRectFrame(CGRectMake(self.bounds.origin.x-1,self.bounds.origin.y-1,self.bounds.size.width,self.bounds.size.height+1.5));
    }else{
        UIRectFrame(CGRectMake(self.bounds.origin.x-1,self.bounds.origin.y-1,self.bounds.size.width+2,self.bounds.size.height+1.5));
    }
	
}


- (void)setNeedsDisplay {

    [super setNeedsDisplay];
    if (dataView) {
        [dataView setNeedsDisplay];
    }
	
	if(!haveCross)
		[[subDataViews objectAtIndex:subDataViewsIndex] setNeedsDisplay];
	haveCross = NO;

}

- (void)setNeedsDisplayInRect:(CGRect)invalidRect{
	
    [super setNeedsDisplayInRect:invalidRect];
	//NSLog([NSString stringWithFormat:@"%f,%f,%f,%f",invalidRect.origin.x,invalidRect.origin.y,invalidRect.size.width,invalidRect.size.height]);
	UIView* subView = [subDataViews objectAtIndex:subDataViewsIndex];
	CGRect rect = CGRectMake(invalidRect.origin.x, subView.frame.origin.y, invalidRect.size.width, subView.frame.size.height);
	//NSLog([NSString stringWithFormat:@"%f,%f,%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height]);
    if (dataView) {
        [dataView setNeedsDisplay];
    }
	if(!haveCross)
		[subView setNeedsDisplayInRect:rect];
	haveCross = NO;
	
}

- (void)openTypeControl:(BOOL)toOpen {

    if (!toOpen) return;

    [drawAndScrollController resetCrossView];


    NSString * appid = [FSFonestock sharedInstance].appId;
    NSString * group = [appid substringWithRange:NSMakeRange(0, 2)];
    NSString * numStr;
    if ([group isEqualToString:@"tw"])
    {
        if (indicatorTableNumber+1 == 1) {
            numStr = @"一";
        }else{
            numStr = @"二";
        }
        
    }else{
        numStr = [NSString stringWithFormat:@"%d",indicatorTableNumber+1];
    }
    
    cxAlertView = [[CustomIOS7AlertView alloc]init];
    float viewH,viewW;
    if (UIInterfaceOrientationIsPortrait(drawAndScrollController.interfaceOrientation)){
        viewH = 350;
        viewW = 250;
    }else{
        viewH = 190;
        viewW = 300;
    }
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 40,viewW , viewH)];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, viewW, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"%@(%@%@)", NSLocalizedStringFromTable(@"BottonIndicatorSheetTitle", @"Draw", @"The title of the picker list for selecting indicators"),NSLocalizedStringFromTable(@"圖", @"Draw",nil),numStr];
    [cxAlertView setTitleLabel:label];
    [cxAlertView setContainerView:view];
    cxAlertView.delegate = self;
    [cxAlertView setButtonTitles:@[NSLocalizedStringFromTable(@"取消", @"watchlists", nil)]];
    
    
//    cxAlertView = [[CXAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@(%@ %@)", NSLocalizedStringFromTable(@"BottonIndicatorSheetTitle", @"Draw", @"The title of the picker list for selecting indicators"),NSLocalizedStringFromTable(@"圖", @"Draw",nil),numStr] contentView:view cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"Draw", @"cancel")];
//    
//    cxAlertView.contentScrollViewMaxHeight = 380;
//    cxAlertView.contentScrollViewMinHeight = 300;
//    [cxAlertView.contentView setFrame:CGRectMake(0, 0, self.frame.size.width - 30, 380)];
    
        
    tableview=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height) style:UITableViewStylePlain];
    tableview.delegate=self;
    tableview.dataSource=self;
    tableview.bounces = NO;
    tableview.backgroundView=nil;
    [view addSubview:tableview];
    
    UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:NSLocalizedStringFromTable(@"完成", @"setting", @"Done")]];
    closeButton.momentary = YES; 
    closeButton.frame = CGRectMake(260, 5.0f, 50.0f, 28.0f);
    [closeButton addTarget:self action:@selector(dismissActionSheet) forControlEvents:UIControlEventValueChanged];
    [cxAlertView show];

	pickerType = 0;
    		
}

-(void)closeUpperIndicatorPicker{
    [cxAlertView close];
}

-(void)customIOS7dialogButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [cxAlertView close];
    drawAndScrollController.bottonView1Picker = NO;
    drawAndScrollController.bottonView2Picker = NO;
}

- (void)resetTypeControl {
	
    timestamp = 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _kNumberOfTables+1 ;// cellNumber;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (indexPath.row==0 ) {
        
        NSString *CELLID=[NSString stringWithFormat:@"cellid%d",(int)indexPath.row];
        
        FSUITableViewCell *cell=[tableview dequeueReusableCellWithIdentifier:CELLID];
        if (cell==nil) {
            cell=[[FSUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELLID];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            
        }
        cell.tag=indexPath.row;
        cell.textLabel.font=[UIFont systemFontOfSize:15];
        cell.textLabel.text=NSLocalizedStringFromTable(@"技術指標", @"Draw", nil);

        return cell;
        
    }
    else{
        
        static NSString *Cellid=@"cellid000";
        
        FSUITableViewCell *cell1=[tableview dequeueReusableCellWithIdentifier:Cellid];
        if (cell1==nil) {
            cell1=[[FSUITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Cellid];
            cell1.selectionStyle=UITableViewCellSelectionStyleNone;
        }
        cell1.tag=indexPath.row;
        cell1.textLabel.font=[UIFont systemFontOfSize:15];
        cell1.textLabel.text=[NSString stringWithFormat:@"         %@",[[NSString alloc]initWithString:[indicator indicatorNameByAnalysisType:(int)indexPath.row-1]]];
        
        return cell1;
        
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return 40.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row !=0) {
        selectPickerIndex = (int)indexPath.row-1;
        [self dismissActionSheet];
    }
}

-(void)changeBottonView{

    if (selectPickerIndex<_kNumberOfTables-1) {
        selectPickerIndex +=1;
        
    }else{
        selectPickerIndex =0;
    }
    [indicator setSelectedIndicatorByAnalysisType:selectPickerIndex];
	[indicator setIndicatorParameterCountWithAnalysisType:selectPickerIndex];
	self.selectedIndicator = [indicator getSelectIndicator];
	self.selectedIndicatorParameterCount = indicator.selectedIndicatorParameterCount;
	
	if(indicatorTableNumber == 0)
		[indicator setBottomViewDefaultIndicator:selectPickerIndex indicatorViewType:0 PeriodType:drawAndScrollController.analysisPeriod];
	else
		[indicator setBottomViewDefaultIndicator:selectPickerIndex indicatorViewType:1 PeriodType:drawAndScrollController.analysisPeriod];
	
	
    [self selectAnalysisType:selectedIndicator];
    [drawAndScrollController setDefaultValue];
}

- (void)insertRow:(NSIndexPath *)indexPath
{
    ShowPicker=YES;
    
    //[typePicker update];
    [_ShowIndex removeAllObjects];
    NSMutableArray* rowToInsert = [[NSMutableArray alloc] init];
    
    for (int i=1; i<=_kNumberOfTables; i++) {
        NSIndexPath* indexPathToInsert = [NSIndexPath indexPathForRow:(indexPath.row+i) inSection:0];
        [_ShowIndex addObject:indexPathToInsert];
        
        [rowToInsert addObject:indexPathToInsert];
    }
    
    cellNumber=_kNumberOfTables+1;
    [tableview beginUpdates];
    
    [tableview insertRowsAtIndexPaths:rowToInsert withRowAnimation:UITableViewRowAnimationTop];
    [tableview endUpdates];
    
}

//pickerView消失；

- (void)deleteRow:(NSIndexPath *)RowtoDelete
{
    ShowPicker=NO;
    NSMutableArray* rowToDelete = [[NSMutableArray alloc] init];
    for (int i=0; i<[_ShowIndex count]; i++) {
        NSIndexPath* indexPathToDelete = [_ShowIndex objectAtIndex:i];
        [rowToDelete addObject:indexPathToDelete];
    }
    
    cellNumber=1;
    [tableview beginUpdates];
    [tableview deleteRowsAtIndexPaths:rowToDelete withRowAnimation:UITableViewRowAnimationBottom];
    [tableview endUpdates];
    
}


- (void)doTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    timestamp = event.timestamp;
    if(drawAndScrollController.arrowUpDownType != 4 && drawAndScrollController.arrowUpDownType != 5){
        [self changeBottonView];
    }
    
}


- (void)doTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    timestamp = 0;
}


- (void)doTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event timeInterval:(NSTimeInterval)interval {

    if (event.timestamp - timestamp < interval) {

        //[self openTypeControl:YES];
    }
}


- (void)doTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    [self doTouchesEnded:touches withEvent:event timeInterval:0.25];
}


- (UIView *)createDataView:(BottomViewAnalysisType)type {

    UIView<AnalysisChart> *view = nil;
    selectPickerIndex = type;
    switch (type) {
        case BottomViewAnalysisTypeVOL: view = [[VolumeView alloc]init]; break;
        case BottomViewAnalysisTypeRSI: view = [[RSIView alloc]init]; break;
        case BottomViewAnalysisTypeMACD: view = [[MACDView alloc]init]; break;
        case BottomViewAnalysisTypeBias: view = [[BiasView alloc]init]; break;
        case BottomViewAnalysisTypeOBV: view = [[OBVView alloc]init]; break;
        case BottomViewAnalysisTypePSY: view = [[PsychologicalLine alloc]init]; break;
        case BottomViewAnalysisTypeWR: view = [[WilliamsView alloc]init]; break;
        case BottomViewAnalysisTypeMTM: view = [[MomentumView alloc]init]; break;
        case BottomViewAnalysisTypeOSC: view = [[OscillatorView alloc]init]; break;
        case BottomViewAnalysisTypeARBR: view = [[ARBRView alloc]init]; break;
        case BottomViewAnalysisTypeDMI: view = [[DMIView alloc]init]; break;
        case BottomViewAnalysisTypeTower: view = [[TowerView alloc]init]; break;
        case BottomViewAnalysisTypeKDJ: view = [[KDJView alloc]init]; break;
        case BottomViewAnalysisTypeVR: view = [[VRView alloc]init]; break;
        case BottomViewAnalysisTypeGain: view = [[GainView alloc]init]; break;
    }

    view = [view initWithChartFrame:subViewChartFrame chartFrameOffset:subViewChartFrameOffset];
    view.backgroundColor = [UIColor clearColor];
    view.frame = subViewFrame;
    view.drawAndScrollController = drawAndScrollController;
    view.historicData = drawAndScrollController.historicData;
    view.bottonView = self;
    view.xLines = drawAndScrollController.xLines;
    view.yLines = drawAndScrollController.yLines;

    [dataScrollView addSubview:view];

    [view setZoomTransform:subViewTransform];

    return view;
}


// set visable frame range & load table data
- (void)loadScrollViewWithPage:(NSInteger)page {
    if (page < 0) return;
    if (page >= _kNumberOfTables) return;

    
    
    if ([subDataViews objectAtIndex:page] == [NSNull null]) {

        UIView *view = [self createDataView:(BottomViewAnalysisType)page];
        [subDataViews replaceObjectAtIndex:page withObject:view];

    }

	[dataView updateValueWithIndex:-1];

    //交換subView view, 將目前顯示的view放在screen後面(sendSubviewToBack), 再將欲顯示的與拉到screen上顯示(bringSubviewToFront)
//    [dataScrollView sendSubviewToBack:[subDataViews objectAtIndex:subDataViewsIndex]];
//    [dataScrollView bringSubviewToFront:[subDataViews objectAtIndex:page]];
    [[subDataViews objectAtIndex:subDataViewsIndex] removeFromSuperview];
    [dataScrollView addSubview:[subDataViews objectAtIndex:page]];
    dataScrollView.bounces = NO;
    subDataViewsIndex = page;

}


- (void)selectAnalysisType:(BottomViewAnalysisType)select {

    //if (subDataViewsIndex != select) { //參數可能會改變

    currentPage = select;

    if (currentPage >= 0 && currentPage < _kNumberOfTables) {

			
        [self loadScrollViewWithPage:currentPage];

        [[subDataViews objectAtIndex:currentPage] setNeedsDisplay];
        if (dataView) {
            [dataView setNeedsDisplay];
        }
    }
}



- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	
	NSInteger componentCount;
	
	if(pickerType==0)
	{
		componentCount = 1;
	}
		
	else
	{
		switch (selectedIndicatorParameterCount) {
			case 0:
				componentCount = 1;
				break;
			case 1:
				componentCount = 2;
				break;
			case 2:
				componentCount = 3;
				break;
			case 3:
				componentCount = 4;
				break;
		}
	
	}
	return componentCount;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {

	if(pickerType==0){
		return _kNumberOfTables;
	}
	else{
		if(component==0)
			return 1;
		else
			return 99;
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	
	float componentWidth;
	if(pickerType==0){
		
		componentWidth = 240;
	
	}
	else{
		
		switch (selectedIndicatorParameterCount) {
			case 0:
				if(component==0)
					componentWidth = 240;
				else
					componentWidth = 240;
				break;
				
			case 1:
				if(component==0)
					componentWidth = 140;
				else
					componentWidth = 100;
				break;				
				
			case 2:
				if(component==0)
					componentWidth = 100;
				else
					componentWidth = 70;
				break;				
				
			case 3:
				if(component==0)
					componentWidth = 75;
				else
					componentWidth = 55;
				break;
		}
	}
    return componentWidth;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {

	if(pickerType==0){ //技術指標選取 Picker view
		
		if (view == nil) {
			
			CGSize size = [pickerView rowSizeForComponent:0];
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
			
			label.backgroundColor = [UIColor clearColor];
			label.textAlignment = NSTextAlignmentCenter;
			label.font = [label.font fontWithSize:24];			
			view = label;
		}
		
		//((UILabel *)view).text = [self titleForAnalysisType:row];
		NSString *string = [[NSString alloc]initWithString:[indicator indicatorNameByAnalysisType:(int)row]];
		((UILabel *)view).text = string;
	
	}
	
	else{ //指標參數輸入Picker view
		
		if (view == nil) {
			
			CGSize size = [pickerView rowSizeForComponent:0];
			UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
			
			label.backgroundColor = [UIColor clearColor];
			label.textAlignment = NSTextAlignmentCenter;
			label.font = [label.font fontWithSize:24];
			
			view = label;
		}
		
//		if(component==0)
////			((UILabel *)view).text = [indicator indicatorNameForAnalysisType:selectedIndicator];
//		else
//			((UILabel *)view).text = [NSString stringWithFormat:@"%d",row+1];

	}
	

    return view;
}


- (void)dismissActionSheet
{
	[indicator setSelectedIndicatorByAnalysisType:selectPickerIndex];
	[indicator setIndicatorParameterCountWithAnalysisType:selectPickerIndex];
	self.selectedIndicator = [indicator getSelectIndicator]; 
	self.selectedIndicatorParameterCount = indicator.selectedIndicatorParameterCount;
	
	if(indicatorTableNumber == 0)
		[indicator setBottomViewDefaultIndicator:selectPickerIndex indicatorViewType:0 PeriodType:drawAndScrollController.analysisPeriod];
	else
		[indicator setBottomViewDefaultIndicator:selectPickerIndex indicatorViewType:1 PeriodType:drawAndScrollController.analysisPeriod];
	
	
	
    [cxAlertView close];
    drawAndScrollController.bottonView1Picker = NO;
    drawAndScrollController.bottonView2Picker = NO;
	[self selectAnalysisType:selectedIndicator];
	[drawAndScrollController setDefaultValue];
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (sender != tableview) {
        [self resetTypeControl];
    }

    if (sender == dataScrollView) {

        DrawAndScrollController *controller = dataView.drawAndScrollController;

        UIScrollView *view = controller.indexScrollView;
        view.contentOffset = CGPointMake(sender.contentOffset.x, view.contentOffset.y);

        if (controller.bottonView1 == self)
            controller.bottonView2.dataScrollView.contentOffset = sender.contentOffset;
        else if (controller.bottonView2 == self)
            controller.bottonView1.dataScrollView.contentOffset = sender.contentOffset;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (scrollView != tableview) {
        [drawAndScrollController scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (scrollView != tableview) {
        if(!decelerate)
        {
            [drawAndScrollController scrollViewDidEndDecelerating:scrollView];
        }
    }
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {

    return [drawAndScrollController viewForZoomingInScrollView:scrollView];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    [drawAndScrollController scrollViewDidEndZooming:scrollView withView:view atScale:scale];
}

- (void)loadScrollViewPage {
	
	//設定技術指標是上面的還是下面的
	if(self == drawAndScrollController.bottonView1)
		indicatorTableNumber = 0;
	else
		indicatorTableNumber = 1;


    [self loadScrollViewWithPage:currentPage];
}

- (void)updateValueWithIndex:(int)index		//畫技術分析值用
{
	[dataView updateValueWithIndex:index];
	if(dataView && index >= 0)
		haveCross = YES;
	else
		haveCross = NO;
}

@end
