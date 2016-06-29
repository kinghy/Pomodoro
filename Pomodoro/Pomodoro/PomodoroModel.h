//
//  PomodoroModel.h
//  Pomodoro
//
//  Created by  rjt on 16/6/28.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "EFHeader.h"

typedef enum{
    ClockTypePomodoro,
    ClockTypeLongReset,
    ClockTypeShortReset,
} PomodoroClockType;

@interface PomodoroModel : EFBaseViewModel
@property (nonatomic,strong) NSNumber* remainingTime;//剩余时间，秒
@property (nonatomic,readonly) PomodoroClockType clockType;//时钟类型

@property (nonatomic) int pomodoroDuration;//一个番茄是时间，单位分钟
@property (nonatomic) int resetShortDuration;//一个短休时间，单位分钟
@property (nonatomic) int resetLongDuration;//一个长休时间，单位分钟

/*!
 *  @brief 开始番茄时间
 */
-(void)startPomodoroTime;

/*!
 *  @brief 停止番茄时间
 */
-(void)stopPomodoroTime;

/*!
 *  @brief 暂停番茄时间
 */
-(void)pausePomodoroTime;

/*!
 *  @brief 开始长休息
 */
-(void)startLongResetTime;

/*!
 *  @brief 停止长休息
 */
-(void)stopLongResetTime;

/*!
 *  @brief 开始短休息
 */
-(void)startShortResetTime;

/*!
 *  @brief 结束短休息
 */
-(void)stopShortResetTime;

@end
