//
//  CYQModel.m
//  Bullseye
//
//  Created by Connor on 13/8/28.
//
//

#import "CYQModel.h"

@interface CYQModel()

@end

@implementation CYQModel

- (id)init {
	if(self = [super init]) {
        
        if (_currentSearchType == 0) {
            _currentSearchType = CYQSearchType_dailyMode;
        }
        
        _recentlyDay = 10;

	}
	return self;
}

+ (CYQModel *)sharedInstance
{
    static CYQModel *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[CYQModel alloc] init];
    });
    return sharedInstance;
}
@end
