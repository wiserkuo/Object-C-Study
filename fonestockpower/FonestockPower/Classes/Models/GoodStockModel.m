//
//  GoodStockModel.m
//  WirtsLeg
//
//  Created by Neil on 13/10/9.
//  Copyright (c) 2013年 fonestock. All rights reserved.
//

#import "GoodStockModel.h"
#import "RealTimeOut.h"

@implementation GoodStockModel

-(void)setTarget:(id)obj{
    notifyObj = obj;
}

-(void)searchStockWithArray:(NSArray *)array update:(NSNumber *)up{
    int filter = [(NSNumber *)[array objectAtIndex:0]intValue];
    int sector = [(NSNumber *)[array objectAtIndex:1]intValue];
    NSLog(@"search: %d, group: %d",filter,sector);
    NSMutableArray * sectorArray = [[NSMutableArray alloc]init];
    NSMutableArray * searchArray = [[NSMutableArray alloc]init];
    NSMutableArray * sortingArray = [[NSMutableArray alloc]init];
    int size = 0;
    if (sector == 0) {//搜尋上市
        [sectorArray addObject:[NSNumber numberWithInt:2]];
        [sectorArray addObject:[NSNumber numberWithInt:21]];
        size += 4;
    }else if(sector == 1){//搜尋上櫃
        [sectorArray addObject:[NSNumber numberWithInt:1]];
        [sectorArray addObject:[NSNumber numberWithInt:2]];
        size +=4;
    }
    
    if (filter == 0) {//開高走低
        [searchArray addObject:[NSNumber numberWithInt:102]];
        [searchArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        size +=2;
    }else if (filter == 1){//開低走高
        [searchArray addObject:[NSNumber numberWithInt:102]];
        [searchArray addObject:[NSNumber numberWithInt:2]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
        size +=2;
    }else if (filter == 2){//連續買單
        [searchArray addObject:[NSNumber numberWithInt:103]];
        [searchArray addObject:[NSNumber numberWithInt:1]];
        [searchArray addObject:[NSNumber numberWithInt:5]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
        size +=3;
    }else if (filter == 3){//連續賣單
        [searchArray addObject:[NSNumber numberWithInt:103]];
        [searchArray addObject:[NSNumber numberWithInt:2]];
        [searchArray addObject:[NSNumber numberWithInt:5]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        size +=3;
    }else if (filter == 4){//瞬間拉抬
        [searchArray addObject:[NSNumber numberWithInt:104]];
        [searchArray addObject:[NSNumber numberWithInt:1]];
        [searchArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
        size +=4;
    }else if (filter == 5){//瞬間殺盤
        [searchArray addObject:[NSNumber numberWithInt:104]];
        [searchArray addObject:[NSNumber numberWithInt:2]];
        [searchArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        size +=4;
    }else if (filter == 6) {//買盤強勢
        [sortingArray addObject:[NSNumber numberWithInt:8]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
    }else if (filter == 7) {//賣盤主導
        [sortingArray addObject:[NSNumber numberWithInt:9]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
    }else if (filter == 8) {//買氣強大
        [sortingArray addObject:[NSNumber numberWithInt:13]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
    }else if (filter == 9) {//賣壓沈重
        [sortingArray addObject:[NSNumber numberWithInt:13]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
    }else if (filter == 10){//瞬間巨量
        [searchArray addObject:[NSNumber numberWithInt:101]];
        [searchArray addObject:[NSNumber numberWithInt:500]];
        [searchArray addObject:[NSNumber numberWithInt:5]];
        [sortingArray addObject:[NSNumber numberWithInt:14]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
        size +=5;
    }else if (filter == 11){//漲幅排行
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
    }else if (filter == 12){//跌幅排行
        [sortingArray addObject:[NSNumber numberWithInt:1]];
        [sortingArray addObject:[NSNumber numberWithInt:1]];
    }else if (filter == 13){//振幅排行
        [sortingArray addObject:[NSNumber numberWithInt:6]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
    }else if (filter == 14){//成交價
        [sortingArray addObject:[NSNumber numberWithInt:4]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
    }else if (filter == 15){//昨量比
        [sortingArray addObject:[NSNumber numberWithInt:10]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
    }else if (filter == 16){//成交總量
        [sortingArray addObject:[NSNumber numberWithInt:3]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
    }else if (filter == 17){//成交總值
        [sortingArray addObject:[NSNumber numberWithInt:5]];
        [sortingArray addObject:[NSNumber numberWithInt:0]];
    }
    
    RealTimeOut * realTimePacket = [[RealTimeOut alloc]initWithSectorArray:sectorArray SearchArray:searchArray SortingArray:sortingArray Size:size Update:[up boolValue]];
    [FSDataModelProc sendData:self WithPacket:realTimePacket];
}

@end
