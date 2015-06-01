//
//  OperationalIndicator.m
//  WirtsLeg
//
//  Created by Neil on 13/12/4.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "OperationalIndicator.h"
#import "Indicator.h"
#import "HistoricDataAgent.h"
#import "DrawAndScrollController.h"

extern const float valueUnitBase[];

@implementation OperationalIndicator
    
- (id)init {
    self = [super init];
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if(![fileManager fileExistsAtPath:[self parameterFilenameOnDocumentDirectory]] && ![self parameterFileExist])
		{
            [self copyParameterFile];
        }
        self.indicator = [[FSDataModelProc sharedInstance]indicator];
        self.MA1Array = [[NSMutableArray alloc] init];
        self.MA2Array = [[NSMutableArray alloc] init];
        self.MA3Array = [[NSMutableArray alloc] init];
        self.MA4Array = [[NSMutableArray alloc] init];
        self.MA5Array = [[NSMutableArray alloc] init];
        self.MA6Array = [[NSMutableArray alloc] init];
        self.AVLArray = [[NSMutableArray alloc] init];
        self.AVSArray = [[NSMutableArray alloc] init];
        self.PSYArray = [[NSMutableArray alloc] init];
        self.BB1Array = [[NSMutableArray alloc] init];
        self.BB2Array = [[NSMutableArray alloc] init];
        self.WRArray = [[NSMutableArray alloc] init];
        self.VRArray = [[NSMutableArray alloc] init];
        self.RSI1Array = [[NSMutableArray alloc] init];
        self.RSI2Array = [[NSMutableArray alloc] init];
        self.OBVArray = [[NSMutableArray alloc] init];
        self.OSCArray = [[NSMutableArray alloc] init];
        self.OSCMAArray = [[NSMutableArray alloc] init];
        self.ARArray = [[NSMutableArray alloc] init];
        self.BRArray = [[NSMutableArray alloc] init];
        self.BIASArray = [[NSMutableArray alloc] init];
        self.DMIplusArray = [[NSMutableArray alloc] init];
        self.DMIminusArray = [[NSMutableArray alloc] init];
        self.DMIadxArray = [[NSMutableArray alloc] init];
        self.KDKArray = [[NSMutableArray alloc] init];
        self.KDDArray = [[NSMutableArray alloc] init];
        self.KDJArray = [[NSMutableArray alloc] init];
        self.MTMArray = [[NSMutableArray alloc]init];
        self.MTMMAArray = [[NSMutableArray alloc]init];
        self.diffEMAArray = [[NSMutableArray alloc]init];
        self.MACDArray = [[NSMutableArray alloc]init];
        self.SARArray = [[NSMutableArray alloc]init];
        self.SARBreakArray = [[NSMutableArray alloc]init];
        self.TLBopenArray = [[NSMutableArray alloc]init];
        self.TLBcloseArray = [[NSMutableArray alloc]init];
        self.dataDictionary = [[NSMutableDictionary alloc]init];
        
        datalock = [[NSRecursiveLock alloc]init];
        
    }
    return self;
}

- (void)copyParameterFile
{
	NSError *error;
	
    //	NSFileManager *FileManager = [NSFileManager defaultManager];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
	
	NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"IndicatorParameterUrlTable.plist"];
    
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"IndicatorParameterUrlTable.plist"];
	
	//Copy the database file to the users document directory.
	if (![fileManager copyItemAtPath:dbPath toPath:filePath error:&error])
		NSLog(@"Failed to copy the ParameterFile. Error: %@.", [error localizedDescription]);
    
}

- (NSString*)parameterFilenameOnDocumentDirectory
{
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); //
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"IndicatorParameterUrlTable.plist"];
	return filePath;
}

- (BOOL)parameterFileExist
{
	NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [CodingUtil fonestockDocumentsPath];
	
	NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"IndicatorParameterUrlTable.plist"];
	
	return [fileManager fileExistsAtPath:filePath];
}

-(void)prepareDataToDrawByPeriod
{
    
    [datalock lock];
    
    DecompressedHistoricData *hist;
    self.range = 7;
    
    NSString * period = @"";
    
    if (self.drawAndScrollController.analysisPeriod==0) {
        _type = 'D';
        _range =0;
        period = @"dayLine";
    }else if (self.drawAndScrollController.analysisPeriod==1){
        _type = 'W';
        _range =1;
        period = @"weekLine";
    }else if (self.drawAndScrollController.analysisPeriod==2){
        _type = 'M';
        _range =2;
        period = @"monthLine";
    }else if (self.drawAndScrollController.analysisPeriod==3){
        _type = '5';
        period = @"minuteLine";
        _range =3;
    }else if (self.drawAndScrollController.analysisPeriod==4){
        _type = 'F';
        period = @"minuteLine";
        _range =4;
    }else if (self.drawAndScrollController.analysisPeriod==5){
        _type = 'T';
        period = @"minuteLine";
        _range =5;
    }else if (self.drawAndScrollController.analysisPeriod==6){
        _type = 'S';
        period = @"minuteLine";
        _range =6;
    }
    
    
    int totalDayCnt = [self.historicData tickCount:(AnalysisPeriod)_range];
    
    int startIndex = 0;
    int endIndex = startIndex + totalDayCnt - 1;
    
    NSMutableDictionary *parmDict1 = [_indicator readNewIndicatorParameterByPeriod:period];
    
    float sum;
    int n, i, m, seq, count;
    double min, max;
/////////////////MA////////////////
//    int MA1parameter = [[parmDict1 objectForKey:@"MA1parameter"]intValue];
//    int MA2parameter = [[parmDict1 objectForKey:@"MA2parameter"]intValue];
//    int MA3parameter = [[parmDict1 objectForKey:@"MA3parameter"]intValue];
//    int MA4parameter = [[parmDict1 objectForKey:@"MA4parameter"]intValue];
//    int MA5parameter = [[parmDict1 objectForKey:@"MA5parameter"]intValue];
//    int MA6parameter = [[parmDict1 objectForKey:@"MA6parameter"]intValue];
//    
//    NSMutableArray *maParameterArray = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:MA1parameter],
//                                        [NSNumber numberWithInt:MA2parameter],
//                                        [NSNumber numberWithInt:MA3parameter],
//                                        [NSNumber numberWithInt:MA4parameter],
//                                        [NSNumber numberWithInt:MA5parameter],
//                                        [NSNumber numberWithInt:MA6parameter],nil];
//    
//    [_MA1Array removeAllObjects];
//    [_MA2Array removeAllObjects];
//    [_MA3Array removeAllObjects];
//    [_MA4Array removeAllObjects];
//    [_MA5Array removeAllObjects];
//    [_MA6Array removeAllObjects];
//
//    for (n = 0; n < [maParameterArray count]; n++)
//    {
//        m = [[maParameterArray objectAtIndex:n]intValue];
//        
//        if (endIndex < m)
//        continue;
//        
//        sum = 0;
//        count = 0;
//        seq = 0;
//        
//        for (i = startIndex; i <= endIndex; i++)
//        {
//            hist = [self.historicData copyHistoricTick:_type sequenceNo:i];
//            seq = i;
//            
//            if (hist == nil)
//            {
//                
//                if(n == 0)
//                    [_MA1Array addObject:[NSNumber numberWithInt:0]];
//                else if(n == 1)
//                    [_MA2Array addObject:[NSNumber numberWithInt:0]];
//                else if(n == 2)
//                    [_MA3Array addObject:[NSNumber numberWithInt:0]];
//                else if(n == 3)
//                    [_MA4Array addObject:[NSNumber numberWithInt:0]];
//                else if(n == 4)
//                    [_MA5Array addObject:[NSNumber numberWithInt:0]];
//                else if(n == 5)
//                    [_MA6Array addObject:[NSNumber numberWithInt:0]];
//                
//                continue;
//                
//            }
//            
//            sum += hist.close;
//            
//            if (count >= m)
//            {
//                
//                hist = [self.historicData copyHistoricTick:_type sequenceNo:seq-m];
//                sum -= hist.close;
//                
//                if(n == 0)
//                    [_MA1Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                else if(n == 1)
//                    [_MA2Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                else if(n == 2)
//                    [_MA3Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                else if(n == 3)
//                    [_MA4Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                else if(n == 4)
//                    [_MA5Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                else if(n == 5)
//                    [_MA6Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//            }
//            else if (count == m-1)
//            {
//                
//                if(n == 0)
//                    [_MA1Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                else if(n == 1)
//                    [_MA2Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                else if(n == 2)
//                    [_MA3Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                else if(n == 3)
//                    [_MA4Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                else if(n == 4)
//                    [_MA5Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                else if(n == 5)
//                    [_MA6Array addObject:[NSNumber numberWithFloat:(sum / m)]];
//                
//            }
//            
//            else
//            {
//                
//                if(n == 0)
//                    [_MA1Array addObject:[NSNumber numberWithInt:0]];
//                else if(n == 1)
//                    [_MA2Array addObject:[NSNumber numberWithInt:0]];
//                else if(n == 2)
//                    [_MA3Array addObject:[NSNumber numberWithInt:0]];
//                else if(n == 3)
//                    [_MA4Array addObject:[NSNumber numberWithInt:0]];
//                else if(n == 4)
//                    [_MA5Array addObject:[NSNumber numberWithInt:0]];
//                else if(n == 5)
//                    [_MA6Array addObject:[NSNumber numberWithInt:0]];
//                
//            }
//            
//            seq++;
//            count++;
//        }
//        
//    }
//    
///////////////////AVG VOL//////////////////
    int AVLparameter = [(NSNumber *)[parmDict1 objectForKey:@"AVLparameter"]intValue];
    int AVSparameter = [(NSNumber *)[parmDict1 objectForKey:@"AVSparameter"]intValue];

    NSMutableArray *avParameterArray = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:AVLparameter],[NSNumber numberWithInt:AVSparameter],nil];
    
    [_AVLArray removeAllObjects];
    [_AVSArray removeAllObjects];

    for (n = 0; n < [avParameterArray count]; n++)
    {
        m = [(NSNumber *)[avParameterArray objectAtIndex:n]intValue];
        
        if (endIndex < m)
            continue;
        
        sum = 0;
        count = 0;
        seq = 0;
        
        for (i = startIndex; i <= endIndex; i++)
        {
            hist = [self.historicData copyHistoricTick:_type sequenceNo:i];
            seq = i;
            
            if (hist == nil)
            {
                
                if(n == 0)
                    [_AVLArray addObject:(NSNumber *)kCFNumberNaN];
                else if(n == 1)
                    [_AVSArray addObject:(NSNumber *)kCFNumberNaN];
                
                continue;
                
            }
            
            sum += hist.volume * pow(1000,hist.volumeUnit);
            
            if (count >= m)
            {
                
                hist = [self.historicData copyHistoricTick:_type sequenceNo:seq-m];
                sum -= hist.volume * pow(1000,hist.volumeUnit);
                
                if(n == 0)
                    [_AVLArray addObject:[NSNumber numberWithFloat:(sum / m)]];
                else if(n == 1)
                    [_AVSArray addObject:[NSNumber numberWithFloat:(sum / m)]];
            }
            else if (count == m-1)
            {
                
                if(n == 0)
                    [_AVLArray addObject:[NSNumber numberWithFloat:(sum / m)]];
                else if(n == 1)
                    [_AVSArray addObject:[NSNumber numberWithFloat:(sum / m)]];
            }
            
            else
            {
                
                if(n == 0)
                    [_AVLArray addObject:(NSNumber *)kCFNumberNaN];
                else if(n == 1)
                    [_AVSArray addObject:(NSNumber *)kCFNumberNaN];
            }
            seq++;
            count++;
        }
        
    }
//
//////////////PSY//////////////////
//    int PSYparameter = [[parmDict1 objectForKey:@"PSYparameter"]intValue];
//    
//    [_PSYArray removeAllObjects];
//    sum = 0;
//    count = 0;
//    seq = 0;
//    
//    for (int i = startIndex; i <= endIndex; i++) {
//        
//        seq = i;
//        
//        sum += [self getPsyValue:_type sequence:seq];
//        
//        if (seq >= PSYparameter) {
//            
//            sum -= [self getPsyValue:_type sequence:seq-PSYparameter];
//            
//        }
//        
//		[_PSYArray addObject:[NSNumber numberWithDouble:100*(sum / PSYparameter)]];
//        seq++;
//    }
//
//////////////////////BB/////////////////////
//    int BBparameter = [[parmDict1 objectForKey:@"BBparameter"]intValue];
//    
//    m = BBparameter;
//    sum = 0;
//    count = 0;
//    seq = 0;
//    [_BB1Array removeAllObjects];
//    [_BB2Array removeAllObjects];
//    
//    
//    float price, ma, dev, upValue, downValue;
//    
//    count = [self.historicData tickCount:_type];
//    float sqrSum = 0;
//    int devNum = [[parmDict1 objectForKey:@"SDparameter"]intValue];
//    
//    for (int i = 0; i < count; i++) 
//    {
//        hist = [self.historicData copyHistoricTick:_type sequenceNo:i];
//        price = hist.close;
//        
//        sum += price;
//        sqrSum += price * price;
//        
//        if (i >= BBparameter - 1)
//        {
//            
//            if (i >= BBparameter)
//            {
//                
//                hist = [self.historicData copyHistoricTick:_type sequenceNo:i-BBparameter];
//                price = hist.close;
//                
//                sum -= price;
//                sqrSum -= price * price;
//            }
//            
//            ma = sum / BBparameter;
//            dev = sqrSum / BBparameter - sum * sum / (BBparameter * BBparameter);
//            dev = dev >= 0 ? sqrtf(dev * devNum * devNum) : 0;
//            
//            upValue = ma + dev;
//            downValue = ma > dev ? ma - dev : 0;
//            
//            [_BB1Array addObject:[NSNumber numberWithFloat:upValue]];
//            [_BB2Array addObject:[NSNumber numberWithFloat:downValue]];
//        }
//        else
//        {
//            
//            [_BB1Array addObject:(NSNumber *)kCFNumberNaN];
//            [_BB2Array addObject:(NSNumber *)kCFNumberNaN];
//        }
//    }
//    
//    
///////////////W%R//////////////
//    int WRparameter = [[parmDict1 objectForKey:@"WRparameter"]intValue];
//    
//    sum = 0;
//    count = 0;
//    seq = 0;
//    m = 0;
//    int j;
//    double close, min, max,mm;
//    float v;
//    [_WRArray removeAllObjects];
//    
//    for (i = startIndex; i <= endIndex; i++) {
//        
//        seq = i;
//        
//        if (seq >= WRparameter-1) {
//            
//            hist = [self.historicData copyHistoricTick:_type sequenceNo:seq];
//            close = hist.close;
//            
//            min = MAXFLOAT;
//            max = 0;
//            
//            for (j = 0; j < WRparameter; j++) {
//                
//                hist = [self.historicData copyHistoricTick:_type sequenceNo:seq-j];
//                if (max < hist.high)
//                    max = hist.high;
//                if (min > hist.low)
//                    min = hist.low;
//            }
//            
//            mm = max - min;
//            v = mm > 0 ? (max - close) / mm : 0.5;
//            
//        }
//		[_WRArray addObject:[NSNumber numberWithDouble:100*v]];
//        seq++;
//    }
//    
////////////////////VR//////////////////
//    _VRparameter = [[parmDict1 objectForKey:@"VRparameter"]intValue];
//    
//    sum = 0;
//    seq = 0;
//    m = 0;
//    
//    [_VRArray removeAllObjects];
//    
//    count = [self.historicData tickCount:_type];
//	for (int i = 0; i < count; i++) {
//		
//		if(i < _VRparameter)
//		{
//			[_VRArray addObject:[NSNumber numberWithDouble:0]];
//		}
//		else{
//            /*
//             1．24天以来凡是股价上涨那一天的成交量都称为AV，将24天内的AV总和相加后称为AVS。
//             2．24天以来凡是股价下跌那一天的成交量都称为BV，将24天内的BV总和相加后称为BVS。
//             3．24天以来凡是股价不涨不跌，则那一天的成交量都称为CV，将24天内的CV总和相加后称为CVS。
//             4． 24天开始计算：
//             VR= 100*（AVS+1/2CVS）/（BVS+1/2CVS）
//             */
//			double avs = 0 , bvs = 0 , cvs = 0;
//			double vrV=0;
//			[self getAVS:&avs BVS:&bvs CVS:&cvs Index:i];
//			vrV = (avs+cvs/2)/(bvs+cvs/2);
//			[_VRArray addObject:[NSNumber numberWithDouble:vrV*100]];
//		}
//	}
//    
////////////////////RSI/////////////////////
//    
//    int RSI1parameter = [[parmDict1 objectForKey:@"RSI1parameter"]intValue];
//    int RSI2parameter = [[parmDict1 objectForKey:@"RSI2parameter"]intValue];
//    
//    
//    NSMutableArray *rsiParameterArray = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:RSI1parameter],[NSNumber numberWithInt:RSI2parameter],nil];
//    
//    [_RSI1Array removeAllObjects];
//    [_RSI2Array removeAllObjects];
//
//    for (n = 0; n < [rsiParameterArray count]; n++)
//    {
//    
//        sum = 0;
//        seq = 0;
//        m = [[rsiParameterArray objectAtIndex:n]intValue];
//        
//        int cntValue;
//        
//        //取某一天
//        float rsiValue;
//        float avgUp = 0;
//        float avgDown = 0;
//        
//        UInt32 count = [self.historicData tickCount:_type];
//        
//        for (int i = 0; i < count; i++) {
//            
//            if(i < m){     // 假設 ndays = 5 以符合下面兩case
//                cntValue = 0;      // case1: 3-5=-2<0 取4天 (3 2 1 0) ; 2-5=-3<0 取3天 (2 1 0) ; 1-5<0 取2天 (1 0)
//            }
//            else{
//                //cntValue = i - ndays + 1;  // case2 : 10-5=5>=0 cntValue=5 取5天(取 10 9 8 7 6) ; 5-5=0>=0 cntValue=0 (取 5 4 3 2 1) ; 8-5=3 cntValue=3 (取 8 7 6 5 4)
//                cntValue = i - m;
//            }
//
//            
//            if(i<m){ //沒有資料
//                
//                rsiValue = 50;
//            }
//            
//            else{ // i >= ndays 可以計算rsi的資料
//                
//				//判斷是否為第一筆
//				//if(i == firstRsiIndex){
//				if (i == m) {
//                    
//					//第一筆 avgUp avgDown 與 rsi值
//					int cnt = 0; //計數下面迴圈做了幾次
//					//for(int j=firstRsiIndex;j>cntValue;j--){ //遞減 做 ndays次
//					for (int j = m; j > cntValue; j--) { //遞減 做 ndays次
//                        
//						// if j=i=1 , j>0 則： (1)j=1 int subValue = 第1筆 減去 第0筆
//						
//						// if j=2 , j>0 則： (1)j=2 int subValue = 第2筆 減去 第1筆
//						//                  (2)j=1 int subValue = 第1筆 減去 第0筆
//						
//						// 第Ｎ天收盤價 減去 第Ｎ-1天的收盤價
//						
//						//int subValue = [[[dataList objectAtIndex:j]valueForKey:@"dataClose"]intValue] - [[[dataList objectAtIndex:j-1]valueForKey:@"dataClose"]intValue];
//                        
//                        hist = [self.historicData copyHistoricTick:_type sequenceNo:j];
//                        float subValue = hist.close;
//                        
//                        hist = [self.historicData copyHistoricTick:_type sequenceNo:j-1];
//                        subValue -= hist.close;
//                        
//						if(subValue>0){ //正數=漲
//							avgUp += subValue;
//						}
//						else if(subValue<0){ //負數=跌
//							//avgDown += abs(subValue);
//							avgDown += fabs(subValue);
//						}
//						
//						cnt = cnt+1;
//						
//					} // end for(int j=i;j>cntValue;j--)     //case j=i1 : cntValue=0
//					
//					avgUp = avgUp/(cnt);		// cnt必須等於 nday
//					avgDown = avgDown/(cnt);
//					rsiValue = 100 * avgUp/(avgUp + avgDown);
//                }else{ //第二筆
//
//                    //int subValue = [[[dataList objectAtIndex:i]valueForKey:@"dataClose"]intValue] - [[[dataList objectAtIndex:i-1]valueForKey:@"dataClose"]intValue];
//                    
//                    hist = [self.historicData copyHistoricTick:_type sequenceNo:i];
//                    float subValue = hist.close;
//                    
//                    hist = [self.historicData copyHistoricTick:_type sequenceNo:i-1];
//                    subValue -= hist.close;
//                    
//					if(subValue>0){ //正數=漲
//						avgUp = (avgUp*(m-1) + subValue) / m;
//						avgDown = (avgDown*(m-1)) / m;
//					    rsiValue = 100 * avgUp/(avgUp + avgDown);
//					}
//					else if(subValue<0){ //負數=跌
//						avgUp = (avgUp*(m-1)) / m;
//						//avgDown = (avgDown*(ndays-1) +abs(subValue)) / ndays;													
//						avgDown = (avgDown*(m-1) + fabsf(subValue)) / m;
//					    rsiValue = 100 * avgUp/(avgUp + avgDown);												
//					}
//					else{ //不漲 不跌
//					    rsiValue = 100 * avgUp/(avgUp + avgDown);					
//					}
//				}
//            } 
//            
//            if(n == 0)
//                [_RSI1Array addObject:[NSNumber numberWithFloat:rsiValue]];
//            else if(n == 1)
//                [_RSI2Array addObject:[NSNumber numberWithFloat:rsiValue]];
//        }
//    }
//    
//////////////////OBV////////////////
//    
//    int OBVparameter = [[parmDict1 objectForKey:@"OBVparameter"]intValue];
//    double obv = 0;
//    [_OBVArray removeAllObjects];
//    
//    
//    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:_type sequenceNo:0];
//    _maxVolUnit = historic.volumeUnit;
//    
//    for (int i = 1; i < totalDayCnt; i++) {
//        historic = [self.historicData copyHistoricTick:_type sequenceNo:i];
//        if (_maxVolUnit > historic.volumeUnit && historic.volume > 0)
//            _maxVolUnit = historic.volumeUnit;
//    }
//    
//    for (int i = 0; i < totalDayCnt; i++) {
//        
//        obv += [self getObvBySequence:i];
//        
//        if (i >= OBVparameter) {
//            
//            obv -= [self getObvBySequence:i-OBVparameter];
//
//        }
//        
//        [_OBVArray addObject:[NSNumber numberWithDouble:obv]];
//    }
//    
//////////////////OSC////////////
//    _OSCparameter = [[parmDict1 objectForKey:@"OSCparameter"]intValue];
//    float osc=0;
//    [_OSCArray removeAllObjects];
//    
//    for (int i = startIndex; i <= endIndex; i++) {
//        
//        seq = i;
//        
//        if (seq >= _OSCparameter) {
//            
//            osc = [self getOscBySequence:seq];
//            
//        }
//		[_OSCArray addObject:[NSNumber numberWithDouble:osc*100]];
//        
//        seq++;
//    }
//    [self indictorMA:_OSCArray Target:@"OSC"];
//    
/////////////////AR/////////////////////
//    int ARparameter = [[parmDict1 objectForKey:@"ARparameter"]intValue];
//    double up = 0;
//    double dn = 0;
//    double arPrice;
//    [_ARArray removeAllObjects];
//    
//    for (int i = 0; i < totalDayCnt; i++) {
//        v=0;
//        historic = [self.historicData copyHistoricTick:_type sequenceNo:i];
//        arPrice = historic.open;
//        up += historic.high - arPrice;
//        dn += arPrice - historic.low;
//        
//        if (i >= ARparameter-1) {
//            
//            historic = [self.historicData copyHistoricTick:_type sequenceNo:i-ARparameter];
//            arPrice = historic.open;
//            up -= historic.high - arPrice;
//            dn -= arPrice - historic.low;
//            
//            v = dn ? up / dn : 0;
//
//        }
//        
//        [_ARArray addObject:[NSNumber numberWithFloat:v]];
//    }
//    
///////////////////////BR/////////////////////
//    int BRparameter = [[parmDict1 objectForKey:@"BRparameter"]intValue];
//    v = 0;
//    up = dn = arPrice =0;
//    [_BRArray removeAllObjects];
//    [_BRArray addObject:[NSNumber numberWithFloat:0]];
//    
//    for (int i = 1; i < totalDayCnt; i++) {
//        historic = [self.historicData copyHistoricTick:_type sequenceNo:i-1];
//        arPrice = historic.close;
//        
//        historic = [self.historicData copyHistoricTick:_type sequenceNo:i];
//        up += historic.high - arPrice;
//        dn += arPrice - historic.low;
//        
//        if (i >= BRparameter) {
//            if (i>BRparameter) {
//                historic = [self.historicData copyHistoricTick:_type sequenceNo:i-BRparameter-1];
//                arPrice = historic.close;
//                
//                historic = [self.historicData copyHistoricTick:_type sequenceNo:i-BRparameter];
//                up -= historic.high - arPrice;
//                dn -= arPrice - historic.low;
//
//                v = dn ? up / dn : 0;
//            }else{
//                v = dn ? up / dn : 0;
//
//            }
//        }
//        
//        [_BRArray addObject:[NSNumber numberWithFloat:v]];
//    }
//    
/////////////////////BIAS////////////////
//    int BIASparameter = [[parmDict1 objectForKey:@"BIASparameter"]intValue];
//    [_BIASArray removeAllObjects];
//    
//    double avg;
//    double BIASsum = 0;
//    
//    float maxValue = 0;
//    
//    for (int i = 0; i < totalDayCnt; i++) {
//        
//        historic = [self.historicData copyHistoricTick:_type sequenceNo:i];
//        close = historic.close;
//        
//        v = 0;
//        BIASsum += close;
//        
//        if (i >= BIASparameter-1) {
//            
//            if (i >= BIASparameter) {
//                historic = [self.historicData copyHistoricTick:_type sequenceNo:i-BIASparameter];
//                BIASsum -= historic.close;
//            }
//            
//            avg = BIASsum / BIASparameter;
//            
//            if (avg != 0) {
//                v = close / avg - 1;
//                if (maxValue < fabsf(v))
//                    maxValue = fabsf(v);
//            }
//        }
//        
//        double bValue = 0;
//        bValue = v / maxValue;
//        bValue = (maxValue*100) * bValue;
//        
//        [_BIASArray addObject:[NSNumber numberWithFloat:bValue]];
//    }
//    
//////////////////////DMI///////////////////
//    int DMIparameter = [[parmDict1 objectForKey:@"DMIparameter"]intValue];
//    
//    
//    float high, low, high0, low0, close0, highDif, lowDif, plus, minus, tr, dx;
//    float plusSum = 0, minusSum = 0, trSum = 0, dxSum = 0;
//    float plusVal = 0, minusVal = 0, adxVal = 0;
//    
//    
//    [_DMIplusArray removeAllObjects];
//    [_DMIminusArray removeAllObjects];
//    [_DMIadxArray removeAllObjects];
//    
//    [_DMIplusArray addObject:[NSNumber numberWithFloat:0]];
//    [_DMIminusArray addObject:[NSNumber numberWithFloat:0]];
//    [_DMIadxArray addObject:[NSNumber numberWithFloat:0]];
//    
//    for (int i = 1; i < totalDayCnt; i++) {
//        
//        historic = [self.historicData copyHistoricTick:_type sequenceNo:i-1];
//        high0 = historic.high;
//        low0 = historic.low;
//        close0 = historic.close;
//        
//        historic = [self.historicData copyHistoricTick:_type sequenceNo:i];
//        high = historic.high;
//        low = historic.low;
//        
//        highDif = high - high0;
//        lowDif = low0 - low;
//        if (highDif < 0) highDif = 0;
//        if (lowDif < 0) lowDif = 0;
//        
//        plus = minus = 0;
//        if (highDif > lowDif)
//            plus = highDif;
//        else if (highDif < lowDif)
//            minus = lowDif;
//        else
//            plus = minus = highDif;
//        
//        tr = fabsf(high - low);
//        v = fabsf(high - close0);
//        if (tr < v) tr = v;
//        v = fabsf(low - close0);
//        if (tr < v) tr = v;
//        
//        if (i <= DMIparameter-1) {
//            plusSum += plus;
//            minusSum += minus;
//            trSum += tr;
//        }
//        else {
//            plusSum = plusSum * (DMIparameter-1) / DMIparameter + plus;
//            minusSum = minusSum * (DMIparameter-1) / DMIparameter + minus;
//            trSum = trSum * (DMIparameter-1) / DMIparameter + tr;
//            
//            if (trSum > 0) {
//                plusVal = plusSum / trSum;
//                minusVal = minusSum / trSum;
//            }
//            else
//                plusVal = minusVal = 0;
//            
//            v = plusVal + minusVal;
//            dx = v ? fabsf(plusVal - minusVal) / v : 0;
//            
//            if (i <= DMIparameter+DMIparameter-2)
//                dxSum += dx;
//            else {
//                dxSum = dxSum * (DMIparameter-1) / DMIparameter + dx;
//                adxVal = dxSum / DMIparameter;
//
//            }
//        }
//        
//        [_DMIplusArray addObject:[NSNumber numberWithFloat:plusVal*100]];
//        [_DMIminusArray addObject:[NSNumber numberWithFloat:minusVal*100]];
//        [_DMIadxArray addObject:[NSNumber numberWithFloat:adxVal*100]];
//    }
//    
/////////////////////KDJ//////////////////
//    int KDparameter = [[parmDict1 objectForKey:@"KDparameter"]intValue];
//    float rsv,tmpRsv;
//    count = [self.historicData tickCount:_type];
//    [_KDKArray removeAllObjects];
//    [_KDDArray removeAllObjects];
//    [_KDJArray removeAllObjects];
//	
//    for (int i = 0; i < count; i++) {
//		
//		if(i < KDparameter)
//		{
//			rsv = 0;
//			[_KDKArray addObject:[NSNumber numberWithFloat:0]];
//			[_KDDArray addObject:[NSNumber numberWithFloat:0]];
//			[_KDJArray addObject:[NSNumber numberWithFloat:0]];
//		}
//		else{
//			// do
//			if (i == KDparameter) {
//				
//				//KD(3,3,3):
//				//當日K值(%K)= 2/3 前一日 K值 + 1/3 RSV
//				//當日D值(%D)= 2/3 前一日 D值＋ 1/3 當日K值
//				
//				//init 無前一日的Ｋ值與Ｄ值
//				rsv = [self RSVonTheDateOfIndex:i parameter:KDparameter];
//				
//				float kValue = (float)2/3 * 50 + (float)1/3 * rsv;
//				float dValue = (float)2/3 * 50 + (float)1/3 * kValue;
//				float jValue = 3*dValue - 2*kValue;
//				
//				[_KDKArray addObject:[NSNumber numberWithFloat:kValue]];
//				[_KDDArray addObject:[NSNumber numberWithFloat:dValue]];
//				[_KDJArray addObject:[NSNumber numberWithFloat:jValue]];
//								
//			}
//			else{
//				
//				rsv = [self RSVonTheDateOfIndex:i parameter:KDparameter];
//				if([[NSNumber numberWithFloat:rsv] isEqualToNumber:(NSNumber*)kCFNumberNaN])
//					rsv = tmpRsv;
//				else
//					tmpRsv = rsv;
//				
//				//kExponentialSmoothing
//				//dExponentialSmoothing
//				
//				float kValue = (float)2/3 * [[_KDKArray objectAtIndex:i-1] floatValue] + (float)1/3*rsv;
//				float dValue = (float)2/3 * [[_KDDArray objectAtIndex:i-1] floatValue] + (float)1/3*kValue;
//				float jValue = 3*dValue - 2*kValue;
//                
//				[_KDKArray addObject:[NSNumber numberWithFloat:kValue]];
//				[_KDDArray addObject:[NSNumber numberWithFloat:dValue]];
//				[_KDJArray addObject:[NSNumber numberWithFloat:jValue]];
//                
//			}
//		}
//	}
//    
///////////////////////MTM////////////////////////
//    _MTMparameter = [[parmDict1 objectForKey:@"MTMparameter"]intValue];
//    [_MTMArray removeAllObjects];
//    float mtm;
//    
//    for (int i = startIndex; i <= endIndex; i++) {
//        
//        seq = i;
//        
//        if (seq >= _MTMparameter) {
//            
//            mtm = [self getMtmValueBySequence:seq];
//            
//        }
//		[_MTMArray addObject:[NSNumber numberWithDouble:mtm]];
//        seq++;
//    }
//    [self indictorMA:_MTMArray Target:@"MTM"];
//    
////////////////////MACD////////////////////
//    int MACDparameter = [[parmDict1 objectForKey:@"MACDparameter"]intValue];
//    int EMA1parameter = [[parmDict1 objectForKey:@"EMA1parameter"]intValue];
//    int EMA2parameter = [[parmDict1 objectForKey:@"EMA2parameter"]intValue];
//    
//    int emaDayStart = fmax(EMA1parameter, EMA2parameter);
//    count = [self.historicData tickCount:_type];
//    
//    [self diffEMAWithDataRange:count emaParameter1:EMA1parameter emaParameter2:EMA2parameter];
//    [self macdWithGivenArray:_diffEMAArray hDays:MACDparameter emaParameter:emaDayStart];
//    
//    
//    
////////////////////SAR///////////////////
    int SARparameter = [(NSNumber *)[parmDict1 objectForKey:@"SARparameter"]intValue];
    count = [self.historicData tickCount:_type];
    DecompressedHistoricData *historic ;
    int len =  0;
    int af = 0;
    
    double sar0 = 0;
    double sar;
    BOOL upward = YES;
    BOOL toChange;
    [_SARArray removeAllObjects];
    [_SARBreakArray removeAllObjects];
    
    for (int index = 0; index <= endIndex; index++) {
        
        if (index == endIndex-1) {
            NSLog(@"");
        }
        
        max = 0;
        min = MAXFLOAT;
        DecompressedHistoricData *historicBefore = [self.historicData copyHistoricTick:_type sequenceNo:index-1];
        DecompressedHistoricData *historicNow = [self.historicData copyHistoricTick:_type sequenceNo:index];
        DecompressedHistoricData *historicAfter = [self.historicData copyHistoricTick:_type sequenceNo:index+1];
        
        for (int i = 1; i < SARparameter; i++) {
            if (index < i)
                break;
            historic = [self.historicData copyHistoricTick:_type sequenceNo:index-i];
            if (max < historic.high)
                max = historic.high;
            if (min > historic.low)
                min = historic.low;
        }
        
        if (upward) {
            if (len == 0)
                sar = MIN(min, historicNow.low);
            else {
                if (len == 1)
                    af = 2;
                else if (historicNow.high > max && af < 20)
                    af += 2;
                sar = sar0 + (historicBefore.high - sar0)
                * af / 100;
				
            }
            toChange = (index + 1 < count) && (sar > historicAfter.low);
        } else {
            if (len == 0)
                sar = MAX(max, historicNow.high);
            else {
                if (len == 1)
                    af = 2;
                else if (historicNow.low < min && af < 20)
                    af += 2;
                sar = sar0 - (sar0 - historicBefore.low) * af / 100;
            }
            toChange = (index + 1 < count) && (sar < historicAfter.high);
        }
        sar0 = sar;
        if (toChange) {
            upward = !upward;
            len = 0;
        } else {
            len++;
        }
        [_SARArray addObject:[NSNumber numberWithDouble:sar0]];
        [_SARBreakArray addObject:[NSNumber numberWithDouble:toChange?1:0]];
    }

///////////////////////TLB///////////////////
//    
//    historic = [self.historicData copyHistoricTick:_type sequenceNo:0];
//    count = [self.historicData tickCount:_type];
//    float value, open, openBreak, closeBreak = 0;
//    close = 0;
//    BOOL add, reset;
//    openBreak = open = historic.close;
//    int index, showStart = 0;
//    int level = 1;
//    [_TLBopenArray removeAllObjects];
//    [_TLBcloseArray removeAllObjects];
//    NSMutableArray  * openArray = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0],[NSNumber numberWithFloat:0], nil];
//    [openArray setObject:[NSNumber numberWithFloat:open] atIndexedSubscript:0];
//    
//    for (index = 0; index < count; index++) {
//        historic = [self.historicData copyHistoricTick:_type sequenceNo:index];
//        value = historic.close;
//        [_TLBopenArray addObject:[NSNumber numberWithFloat:open]];
//        [_TLBcloseArray addObject:[NSNumber numberWithDouble:value]];
//        
//        if (value != open) {
//            closeBreak = close = value;
//            showStart = index;
//            index++;
//            break;
//        }
//    }
//    
//    for (; index < count; index++) {
//        historic = [self.historicData copyHistoricTick:_type sequenceNo:index];
//        value = historic.close;
//        add = reset = false;
//        
//        if (closeBreak > openBreak) {
//            if (value > closeBreak)
//                add = true;
//            else if (value < openBreak)
//                reset = true;
//        } else if (closeBreak < openBreak) {
//            if (value < closeBreak)
//                add = true;
//            else if (value > openBreak)
//                reset = true;
//        }
//        
//        if (add) {
//            open = close;
//            closeBreak = close = value;
//            
//            if (level < 3){
//                level+=1;
//                [openArray setObject:[NSNumber numberWithFloat:open] atIndexedSubscript:level];
//            }else {
//                openBreak = [[openArray objectAtIndex:1]floatValue];
//                [openArray setObject:[openArray objectAtIndex:1] atIndexedSubscript:0];
//                [openArray setObject:[openArray objectAtIndex:2] atIndexedSubscript:1];
//                [openArray setObject:[NSNumber numberWithFloat:open] atIndexedSubscript:2];
//            }
//            
//        }
//        
//        if (reset) {
//            openBreak = open;
//            closeBreak = close = value;
//            [openArray setObject:[NSNumber numberWithFloat:open] atIndexedSubscript:0];
//            level = 1;
//        }
//        
//        [_TLBopenArray addObject:[NSNumber numberWithFloat:open]];
//        [_TLBcloseArray addObject:[NSNumber numberWithDouble:close]];
//
//    }
    
     [datalock unlock];
}

-(void)indictorMA:(NSMutableArray *)array Target:(NSString *)name{
    [datalock lock];
    if ([name isEqualToString:@"OSC"]) {
        [_OSCMAArray removeAllObjects];
    }else if([name isEqualToString:@"MTM"]){
        [_MTMMAArray removeAllObjects];
    }
    int totalDayCnt = [self.historicData tickCount:(AnalysisPeriod)_range];
    
    int startIndex = 0;
    int endIndex = startIndex + totalDayCnt - 1;
    
    float sum = 0;
    int count = 0;
    int seq = 0;
    int m=20;
    float hist;
    
    for (int i = startIndex; i < endIndex; i++)
    {
        if ([name isEqualToString:@"OSC"]) {
            hist = [(NSNumber *)[_OSCArray objectAtIndex:i]floatValue];
        }else if([name isEqualToString:@"MTM"]){
            hist = [(NSNumber *)[_MTMArray objectAtIndex:i]floatValue];
        }
        seq = i;
        
        sum += hist;
        
        if (count >= m)
        {
            if ([name isEqualToString:@"OSC"]) {
                hist = [(NSNumber *)[_OSCArray objectAtIndex:seq-10]floatValue];
            }else if([name isEqualToString:@"MTM"]){
                hist = [(NSNumber *)[_MTMArray objectAtIndex:seq-10]floatValue];
            }
            sum -= hist;
            
            if ([name isEqualToString:@"OSC"]) {
                [_OSCMAArray addObject:[NSNumber numberWithFloat:(sum / 10)]];
            }else if([name isEqualToString:@"MTM"]){
                [_MTMMAArray addObject:[NSNumber numberWithFloat:(sum / 10)]];
            }

        }
        else if (count == m-1)
        {
            
            if ([name isEqualToString:@"OSC"]) {
                [_OSCMAArray addObject:[NSNumber numberWithFloat:(sum / 10)]];
            }else if([name isEqualToString:@"MTM"]){
                [_MTMMAArray addObject:[NSNumber numberWithFloat:(sum / 10)]];
            }
            
        }
        
        else
        {
            
            if ([name isEqualToString:@"OSC"]) {
                [_OSCMAArray addObject:(NSNumber *)kCFNumberNaN];
            }else if([name isEqualToString:@"MTM"]){
                [_MTMMAArray addObject:(NSNumber *)kCFNumberNaN];
            }
            
        }
        
        seq++;
        count++;
    }
    [datalock unlock];
}

-(void)diffEMAWithDataRange:(int)totalDayCnt emaParameter1:(int)p1 emaParameter2:(int)p2{
    
	// En_t = En_[t-1] + 2/(1 + n) * (P_t – En_[t-1])
	// 即 En_t 為 P_t的 n 天exponential moving average(EMA)
    //int emaShortPvalue = fmin(p1, p2);
	int emaLongPvalue = fmax(p1, p2);
	
	int daysThreshold = emaLongPvalue;
    
	NSMutableArray *shortEMAValueArray = [[NSMutableArray alloc]init];
	NSMutableArray *longEMAValueArray = [[NSMutableArray alloc]init];
    [_diffEMAArray removeAllObjects];
	
	
	float shortEMAvalue;
	float longEMAvalue;
    
    float di;
    
    int count = [self.historicData tickCount:_type];
    
    for (int i = 0; i < count; i++) {
        
        di = [self demandIndexOnGivenDataIndex:i];
        
        // short EMA
        if (i < p1) {
            shortEMAvalue = (i == 0 ? 0 : [(NSNumber *)[shortEMAValueArray objectAtIndex:i-1] floatValue]) + di;
            if (i == p1 - 1)
                shortEMAvalue /= p1;
        }
        else {
            shortEMAvalue = ([(NSNumber *)[shortEMAValueArray objectAtIndex:i-1] floatValue] * (p1 - 2) + di * 2) / p1;
        }
        [shortEMAValueArray insertObject:[NSNumber numberWithFloat:shortEMAvalue] atIndex:i];
        
        // long EMA
        if (i < p2) {
            longEMAvalue = (i == 0 ? 0 : [(NSNumber *)[longEMAValueArray objectAtIndex:i-1] floatValue]) + di;
            if (i == p2 - 1)
                longEMAvalue /= p2;
        }
        else {
            longEMAvalue = ([(NSNumber *)[longEMAValueArray objectAtIndex:i-1] floatValue] * (p2 - 2) + di * 2) / p2;
        }
        [longEMAValueArray insertObject:[NSNumber numberWithFloat:longEMAvalue] atIndex:i];
        
        // diff EMA
        if (i < daysThreshold)
            [_diffEMAArray addObject:[NSNumber numberWithFloat:0]];
        else
            [_diffEMAArray addObject:[NSNumber numberWithFloat:(shortEMAvalue - longEMAvalue)]];
    }
	
}


- (void)macdWithGivenArray:(NSMutableArray *)emaArray hDays:(int)days emaParameter:(int)emaParameter {
    [_MACDArray removeAllObjects];
    int count = (int)emaArray.count;
    int n = days + emaParameter;
    float ema, macdV;
    
    for (int i = 0; i < count; i++) {
        
        ema = [(NSNumber *)[emaArray objectAtIndex:i] floatValue];
        
        if (i < n) {
            macdV = (i == 0 ? 0 : [(NSNumber *)[_MACDArray objectAtIndex:i-1] floatValue]) + ema;
            if (i == n - 1)
                macdV /= days;
        }
        else {
            macdV = ([(NSNumber *)[_MACDArray objectAtIndex:i-1] floatValue] * (days - 1) + ema * 2) / (days + 1);
        }
        
        [_MACDArray addObject:[NSNumber numberWithFloat:macdV]];
    }
    
}

// 計算 Demand Index 價格需求指數
- (float)demandIndexOnGivenDataIndex:(int)dataIndex{
    
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:_type sequenceNo:dataIndex];
    float high_t = historic.high;
    float low_t = historic.low;
    float close_t = historic.close;
    
	//Demand Index 價格需求指數
	float demandIndexValue = (float)(high_t + low_t + 2*close_t)/4;
	
	return demandIndexValue;
	
}


- (float)getMtmValueBySequence:(int)index {
    
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:_type sequenceNo:index];
    double v = historic.close;
    
    historic = [self.historicData copyHistoricTick:_type sequenceNo:index-_MTMparameter];
    v -= historic.close;
    

    return v;
}

- (float)RSVonTheDateOfIndex:(int)index parameter:(int)nDays{
	
	//             第n天收盤價-最近n天內最低價
	//   RSV ＝ ───────────────────────────── × 100
	//           最近n天內最高價-最近n天內最低價
	
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:_type sequenceNo:index];
    float closeValue = historic.close;
	
	float theMaxValue = [self theHighestValueOfRecentDays:nDays dataIndex:index];
	float theMinValue = [self theLowestValueOfRecentDays:nDays dataIndex:index];
	
	float rsv = (float)(closeValue - theMinValue)/(theMaxValue-theMinValue)*100;
	
	return rsv;
}

- (float)theHighestValueOfRecentDays:(int)nDays dataIndex:(int)index{
	
    int rearIndex = index;
	
	//最大index 減去 days區間 算區間頭在 dataList中的index
	int fontIndex = index - nDays +1;
	
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:_type sequenceNo:fontIndex];
    float maxValue = historic.high;
	
	for(int i=fontIndex+1;i<=rearIndex;i++){
		
        historic = [self.historicData copyHistoricTick:_type sequenceNo:i];
        if (maxValue < historic.high)
            maxValue = historic.high;

	}
	return maxValue;
}


- (float)theLowestValueOfRecentDays:(int)nDays dataIndex:(int)index{
	
    int rearIndex = index;
	
	//最大index 減去 days區間 算區間頭在 dataList中的index
	int fontIndex = index - nDays +1;
	
	
	//int minValue = [[[dataList objectAtIndex:fontIndex]valueForKey:@"dataLow"]intValue];
	
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:_type sequenceNo:fontIndex];
    float minValue = historic.low;
	
	for(int i=fontIndex+1;i<=rearIndex;i++){
		
        historic = [self.historicData copyHistoricTick:_type sequenceNo:i];
        if (minValue > historic.low)
            minValue = historic.low;
	}
	return minValue;
}

- (float)getOscBySequence:(int)index {
    
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:_type sequenceNo:index-_OSCparameter];
    double v = historic.close;
    
    historic = [self.historicData copyHistoricTick:_type sequenceNo:index];
    v = v ? historic.close / v : 0;
    
    return v;
}

- (double)getObvBySequence:(int)index {
    
    if (index == 0) return 0;
    
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:_type sequenceNo:index-1];
    double prevClose = historic.close;
    
    historic = [self.historicData copyHistoricTick:_type sequenceNo:index];
    double close = historic.close;
    double vol = historic.volume;
    UInt8 unit = historic.volumeUnit;
    
    if (unit > _maxVolUnit)
        vol *= valueUnitBase[unit - _maxVolUnit];
    
    return close > prevClose ? vol :
    close < prevClose ? -vol : 0;
}

- (void)getAVS:(double*)avs BVS:(double*)bvs CVS:(double*)cvs Index:(int)index
{
	int rearIndex = index;
	
	//最大index 減去 days區間 算區間頭在 dataList中的index
	int fontIndex = index - _VRparameter +1;
	
	for(int i=fontIndex ; i<=rearIndex ;i++){
		
		DecompressedHistoricData *historic = [self.historicData copyHistoricTick:_type sequenceNo:i];
        DecompressedHistoricData *oldHistoric = [self.historicData copyHistoricTick:_type sequenceNo:i-1];
		if(historic)
		{
			if(fabs(oldHistoric.close - historic.close) < 0.0001)		//平盤
				*cvs += historic.volume * pow(1000,historic.volumeUnit);
			else if(oldHistoric.close > historic.close)		//跌
				*bvs += historic.volume * pow(1000,historic.volumeUnit);
			else if(historic.close > oldHistoric.close)
				*avs += historic.volume * pow(1000,historic.volumeUnit);
		}
	}
}

- (int)getPsyValue:(UInt8)type sequence:(int)index {
    
    if (index == 0) return 0;
    
    DecompressedHistoricData *historic = [self.historicData copyHistoricTick:type sequenceNo:index-1];
    double prevClose = historic.close;
    
    historic = [self.historicData copyHistoricTick:type sequenceNo:index];
    int v = historic.close - prevClose > 0 ? 1 : 0;
    
    return v;
}

-(NSMutableDictionary *)getDataByIndex:(int)index{
    
    [datalock lock];
    
    [_dataDictionary removeAllObjects];
    
    double MA1Value = [self getValueFrom:index parm:@"MA1"];
    double MA2Value = [self getValueFrom:index parm:@"MA2"];
    double MA3Value = [self getValueFrom:index parm:@"MA3"];
    double MA4Value = [self getValueFrom:index parm:@"MA4"];
    double MA5Value = [self getValueFrom:index parm:@"MA5"];
    double MA6Value = [self getValueFrom:index parm:@"MA6"];
    
    double AVLvalue = [self getValueFrom:index parm:@"AVL"];
    double AVSvalue = [self getValueFrom:index parm:@"AVS"];
    
    double PSYvalue = [self getValueFrom:index parm:@"PSY"];
    double BB1value = [self getValueFrom:index parm:@"BB1"];
    double BB2value = [self getValueFrom:index parm:@"BB2"];
    double WRvalue = [self getValueFrom:index parm:@"WR"];
    double VRvalue = [self getValueFrom:index parm:@"VR"];
    double RSI1value = [self getValueFrom:index parm:@"RSI1"];
    double RSI2value = [self getValueFrom:index parm:@"RSI2"];
    double OBVvalue = [self getValueFrom:index parm:@"OBV"];
    double OSCvalue = [self getValueFrom:index parm:@"OSC"];
    double OSCMAvalue = [self getValueFrom:index parm:@"OSCMA"];
    double ARvalue = [self getValueFrom:index parm:@"AR"];
    double BRvalue = [self getValueFrom:index parm:@"BR"];
    double BIASvalue = [self getValueFrom:index parm:@"BIAS"];
    double DMIplusValue = [self getValueFrom:index parm:@"DMIplus"];
    double DMIminusValue = [self getValueFrom:index parm:@"DMIminus"];
    double DMIadxValue = [self getValueFrom:index parm:@"DMIadx"];
    double KDKValue = [self getValueFrom:index parm:@"KDK"];
    double KDDValue = [self getValueFrom:index parm:@"KDD"];
    double KDJValue = [self getValueFrom:index parm:@"KDJ"];
    double MTMValue = [self getValueFrom:index parm:@"MTM"];
    double MTMMAValue = [self getValueFrom:index parm:@"MTMMA"];
    double MACDValue = [self getValueFrom:index parm:@"MACD"];
    double diffEMAValue = [self getValueFrom:index parm:@"diffEMA"];
    double SARValue = [self getValueFrom:index parm:@"SAR"];
    double SARBreakValue = [self getValueFrom:index parm:@"SARBreak"];
    double TLBopenValue = [self getValueFrom:index parm:@"TLBopen"];
    double TLBcloseValue = [self getValueFrom:index parm:@"TLBclose"];
    
    
    [_dataDictionary setObject:[NSNumber numberWithDouble:MA1Value] forKey:@"MA1"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:MA2Value] forKey:@"MA2"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:MA3Value] forKey:@"MA3"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:MA4Value] forKey:@"MA4"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:MA5Value] forKey:@"MA5"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:MA6Value] forKey:@"MA6"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:AVLvalue] forKey:@"AVL"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:AVSvalue] forKey:@"AVS"];
    
    [_dataDictionary setObject:[NSNumber numberWithDouble:PSYvalue] forKey:@"PSY"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:BB1value] forKey:@"BB1"];
    
    [_dataDictionary setObject:[NSNumber numberWithDouble:BB2value] forKey:@"BB2"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:WRvalue] forKey:@"WR"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:VRvalue] forKey:@"VR"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:RSI1value] forKey:@"RSI1"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:RSI2value] forKey:@"RSI2"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:OBVvalue] forKey:@"OBV"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:OSCvalue] forKey:@"OSC"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:OSCMAvalue] forKey:@"OSCMA"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:ARvalue] forKey:@"AR"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:BRvalue] forKey:@"BR"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:BIASvalue] forKey:@"BIAS"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:DMIplusValue] forKey:@"DMIplus"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:DMIminusValue] forKey:@"DMIminus"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:DMIadxValue] forKey:@"DMIadx"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:KDKValue] forKey:@"KDK"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:KDDValue] forKey:@"KDD"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:KDJValue] forKey:@"KDJ"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:MTMValue] forKey:@"MTM"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:MTMMAValue] forKey:@"MTMMA"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:MACDValue] forKey:@"MACD"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:diffEMAValue] forKey:@"diffEMA"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:SARValue] forKey:@"SAR"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:SARBreakValue] forKey:@"SARBreak"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:TLBopenValue] forKey:@"TLBopen"];
    [_dataDictionary setObject:[NSNumber numberWithDouble:TLBcloseValue] forKey:@"TLBclose"];
    
    
    [datalock unlock];
    return _dataDictionary;
}


- (double)getValueFrom:(int)index parm:(NSString *)type{
	if([type isEqualToString:@"MA1"]){
		
		if(index < [_MA1Array count])
			return [(NSNumber *)[_MA1Array objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"MA2"]){
		
		if(index < [_MA2Array count])
			return [(NSNumber *)[_MA2Array objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"MA3"]){
		
		if(index < [_MA3Array count])
			return [(NSNumber *)[_MA3Array objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"MA4"]){
		
		if(index < [_MA4Array count])
			return [(NSNumber *)[_MA4Array objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"MA5"]){
		
		if(index < [_MA5Array count])
			return [(NSNumber *)[_MA5Array objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"MA6"]){
		
		if(index < [_MA6Array count])
			return [(NSNumber *)[_MA6Array objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"AVL"]){
		
		if(index < [_AVLArray count])
			return [(NSNumber *)[_AVLArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"AVS"]){
		
		if(index < [_AVSArray count])
			return [(NSNumber *)[_AVSArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"PSY"]){
		
		if(index < [_PSYArray count])
			return [(NSNumber *)[_PSYArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"BB1"]){
		
		if(index < [_BB1Array count])
			return [(NSNumber *)[_BB1Array objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"BB2"]){
		
		if(index < [_BB2Array count])
			return [(NSNumber *)[_BB2Array objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"WR"]){
		
		if(index < [_WRArray count])
			return [(NSNumber *)[_WRArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"VR"]){
		
		if(index < [_VRArray count])
			return [(NSNumber *)[_VRArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"RSI1"]){
		
		if(index < [_RSI1Array count])
			return [(NSNumber *)[_RSI1Array objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"RSI2"]){
		
		if(index < [_RSI2Array count])
			return [(NSNumber *)[_RSI2Array objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"OBV"]){
		
		if(index < [_OBVArray count])
			return [(NSNumber *)[_OBVArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"OSC"]){
		
		if(index < [_OSCArray count])
			return [(NSNumber *)[_OSCArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"OSCMA"]){
		
		if(index < [_OSCMAArray count])
			return [(NSNumber *)[_OSCMAArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"AR"]){
		
		if(index < [_ARArray count])
			return [(NSNumber *)[_ARArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"BR"]){
		
		if(index < [_BRArray count])
			return [(NSNumber *)[_BRArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"BIAS"]){
		
		if(index < [_BIASArray count])
			return [(NSNumber *)[_BIASArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"DMIplus"]){
		
		if(index < [_DMIplusArray count])
			return [(NSNumber *)[_DMIplusArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"DMIminus"]){
		
		if(index < [_DMIminusArray count])
			return [(NSNumber *)[_DMIminusArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"DMIadx"]){
		
		if(index < [_DMIadxArray count])
			return [(NSNumber *)[_DMIadxArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"KDK"]){
		
		if(index < [_KDKArray count])
			return [(NSNumber *)[_KDKArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"KDD"]){
		
		if(index < [_KDDArray count])
			return [(NSNumber *)[_KDDArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"KDJ"]){
		
		if(index < [_KDJArray count])
			return [(NSNumber *)[_KDJArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"MTM"]){
		
		if(index < [_MTMArray count])
			return [(NSNumber *)[_MTMArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"MTMMA"]){
		
		if(index < [_MTMMAArray count])
			return [(NSNumber *)[_MTMMAArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"MACD"]){
		
		if(index < [_MACDArray count])
			return [(NSNumber *)[_MACDArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"diffEMA"]){
		
		if(index < [_diffEMAArray count])
			return [(NSNumber *)[_diffEMAArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"SAR"]){
		
		if(index < [_SARArray count])
			return [(NSNumber *)[_SARArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"SARBreak"]){
		
		if(index < [_SARBreakArray count])
			return [(NSNumber *)[_SARBreakArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"TLBopen"]){
		
		if(index < [_TLBopenArray count])
			return [(NSNumber *)[_TLBopenArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}else if([type isEqualToString:@"TLBclose"]){
		
		if(index < [_TLBcloseArray count])
			return [(NSNumber *)[_TLBcloseArray objectAtIndex:index]floatValue];
		else
			return -1;
		
	}

	else return -1;
}

- (NSMutableArray *)getArrayByType:(NSString *)type{
	
	if([type isEqualToString:@"MA1"]){
        return _MA1Array;
	}else if([type isEqualToString:@"MA2"]){
        return _MA2Array;
	}else if([type isEqualToString:@"MA3"]){
        return _MA3Array;
	}else if([type isEqualToString:@"MA4"]){
        return _MA4Array;
	}else if([type isEqualToString:@"MA5"]){
        return _MA5Array;
	}else if([type isEqualToString:@"MA6"]){
        return _MA6Array;
	}else if([type isEqualToString:@"AVL"]){
        return _AVLArray;
	}else if([type isEqualToString:@"AVS"]){
        return _AVSArray;
	}else if([type isEqualToString:@"PSY"]){
        return _PSYArray;
	}else if([type isEqualToString:@"BB1"]){
        return _BB1Array;
	}else if([type isEqualToString:@"BB2"]){
        return _BB2Array;
	}else if([type isEqualToString:@"WR"]){
        return _WRArray;
	}else if([type isEqualToString:@"VR"]){
        return _VRArray;
	}else if([type isEqualToString:@"RSI1"]){
        return _RSI1Array;
	}else if([type isEqualToString:@"RSI2"]){
        return _RSI2Array;
	}else if([type isEqualToString:@"OBV"]){
        return _OBVArray;
	}else if([type isEqualToString:@"OSC"]){
        return _OSCArray;
	}else if([type isEqualToString:@"OSCMA"]){
        return _OSCMAArray;
	}else if([type isEqualToString:@"AR"]){
        return _ARArray;
	}else if([type isEqualToString:@"BR"]){
        return _BRArray;
	}else if([type isEqualToString:@"BIAS"]){
        return _BIASArray;
	}else if([type isEqualToString:@"DMIplus"]){
        return _DMIplusArray;
	}else if([type isEqualToString:@"DMIminus"]){
        return _DMIminusArray;
	}else if([type isEqualToString:@"DMIadx"]){
        return _DMIadxArray;
	}else if([type isEqualToString:@"KDK"]){
        return _KDKArray;
	}else if([type isEqualToString:@"KDD"]){
        return _KDDArray;
	}else if([type isEqualToString:@"KDJ"]){
        return _KDJArray;
	}else if([type isEqualToString:@"MTM"]){
        return _MTMArray;
	}else if([type isEqualToString:@"MTMMA"]){
        return _MTMMAArray;
	}else if([type isEqualToString:@"MACD"]){
        return _MACDArray;
	}else if([type isEqualToString:@"diffEMA"]){
        return _diffEMAArray;

	}else if([type isEqualToString:@"SAR"]){
        return _SARArray;
        
	}else if([type isEqualToString:@"SARBreak"]){
        return _SARBreakArray;
        
    }else if([type isEqualToString:@"TLBopen"]){
        return _TLBopenArray;
        
	}else if([type isEqualToString:@"TLBclose"]){
        return _TLBcloseArray;
        
	}
    
    return nil;

}


@end
