//
//  PromodoroModel.m
//  Pomodoro
//
//  Created by  rjt on 16/6/28.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "PromodoroModel.h"

#define kPromodoroKey @"kPromodoroDurationKey"
#define kResetShortKey @"kResetShortDurationKey"
#define kResetLongKey @"kResetLongDurationKey"
#define kPromodoroVal 25
#define kResetShortVal 5
#define kResetLongVal 30

@implementation PromodoroModel
-(void)viewModelDidLoad{
    //默认一个番茄时间25分钟，休息5分钟
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _promodoroDuration = [ud objectForKey:kPromodoroKey]? [[ud objectForKey:kPromodoroKey] intValue] :kPromodoroVal;
    _resetShortDuration = [ud objectForKey:kResetShortKey]? [[ud objectForKey:kResetShortKey] intValue] :kResetShortVal;
    _promodoroDuration = [ud objectForKey:kPromodoroKey]? [[ud objectForKey:kPromodoroKey] intValue] :kPromodoroVal;
    _clockType = ClockTypePromodoro;
}

-(void)startPromodoroTime{
    if () {
        
    }
}

-(void)setResetLongDuration:(int)resetLongDuration{
    _resetLongDuration = resetLongDuration;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:resetLongDuration]  forKey:kResetLongKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setResetShortDuration:(int)resetShortDuration{
    _resetShortDuration = resetShortDuration;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:resetShortDuration]  forKey:kResetShortKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setPromodoroDuration:(int)promodoroDuration{
    if (promodoroDuration>0) {
        _promodoroDuration = promodoroDuration;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:promodoroDuration]  forKey:kPromodoroKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
