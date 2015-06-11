//
//  SpecialStateModel.h
//  Bullseye
//
//  Created by Neil on 13/9/5.
//
//

#import <Foundation/Foundation.h>


@interface SpecialStateModel : NSObject{
    id notifyObj;
}

-(void)showSpecialStateWithState:(NSNumber *)s;
-(void)setTarget:(id)obj;
-(void)backToControllerWithArray:(NSMutableArray *)array;
@end
