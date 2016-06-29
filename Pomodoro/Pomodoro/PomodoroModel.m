//
//  PomodoroModel.m
//  Pomodoro
//
//  Created by  rjt on 16/6/28.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "PomodoroModel.h"
#import "ReactiveCocoa.h"

#define kPomodoroKey @"kPomodoroDurationKey"
#define kResetShortKey @"kResetShortDurationKey"
#define kResetLongKey @"kResetLongDurationKey"
#define kPomodoroVal 1
#define kResetShortVal 5
#define kResetLongVal 30

@implementation PomodoroModel
-(void)viewModelDidLoad{
    //默认一个番茄时间25分钟，休息5分钟
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _pomodoroDuration = [ud objectForKey:kPomodoroKey]? [[ud objectForKey:kPomodoroKey] intValue] :kPomodoroVal;
    _resetShortDuration = [ud objectForKey:kResetShortKey]? [[ud objectForKey:kResetShortKey] intValue] :kResetShortVal;
    _pomodoroDuration = [ud objectForKey:kPomodoroKey]? [[ud objectForKey:kPomodoroKey] intValue] :kPomodoroVal;
    _clockType = ClockTypePomodoro;
    _remainingTime = 0;
}

-(void)startPomodoroTime{
    if (_clockType == ClockTypePomodoro) {
        @weakify(self)
        [[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] takeUntilBlock:^BOOL(id x) {
            @strongify(self)
            return  self.remainingTime?(self.remainingTime.integerValue <= 0):false;
        }] subscribeNext:^(id x) {
            @strongify(self)
            if (self.remainingTime == 0) {
                self.remainingTime = @(self.pomodoroDuration*60);
            }else{
                self.remainingTime = [NSNumber numberWithInteger:self.remainingTime.integerValue - 1 ];
            }
        } ];
    }
}

-(void)setResetLongDuration:(int)resetLongDuration{
    _resetLongDuration = resetLongDuration;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:resetLongDuration]  forKey:kResetLongKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setResetShortDuration:(int)resetShortDuration{
    _resetShortDuration = resetShortDuration;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber  numberWithInt:resetShortDuration]  forKey:kResetShortKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)setPomodoroDuration:(int)pomodoroDuration{
    if (pomodoroDuration>0) {
        _pomodoroDuration = pomodoroDuration;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:pomodoroDuration]  forKey:kPomodoroKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
@end
