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

@interface PomodoroModel()
@property (nonatomic) BOOL isStart;

@end

@implementation PomodoroModel
-(void)viewModelDidLoad{
    //默认一个番茄时间25分钟，休息5分钟
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    _pomodoroDuration = [ud objectForKey:kPomodoroKey]? [[ud objectForKey:kPomodoroKey] intValue] :kPomodoroVal;
    
    _remainingTime = 0;
    
    _isStart = NO;
    
    @weakify(self)
    self.startCmd = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            @strongify(self)
            [self startPomodoroTime];
            [subscriber sendNext:@1];
            [subscriber sendCompleted];
            return nil;
        }];
        
    }];
}

-(void)startPomodoroTime{
    if (!_isStart) {
        @weakify(self)
        [[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] takeUntilBlock:^BOOL(id x) {
            @strongify(self)
            return  self.remainingTime?(self.remainingTime.integerValue <= 0):false;
        }] subscribeNext:^(id x) {
            @strongify(self)
            if (!self.remainingTime || self.remainingTime.integerValue == 0) {
                self.remainingTime = @(self.pomodoroDuration*60);
            }else{
                self.remainingTime = [NSNumber numberWithInteger:self.remainingTime.integerValue - 1 ];
            }
            self.isStart = YES;
        } completed:^{
            self.isStart = NO;
            self.remainingTime = nil;
        }];
    }
    
}

-(void)setPomodoroDuration:(int)pomodoroDuration{
    if (pomodoroDuration>0) {
        _pomodoroDuration = pomodoroDuration;
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:pomodoroDuration]  forKey:kPomodoroKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
