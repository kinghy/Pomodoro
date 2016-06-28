//
//  PromodoroModel.h
//  Pomodoro
//
//  Created by  rjt on 16/6/28.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "EFHeader.h"

typedef enum{
    ClockTypePromodoro,
    ClockTypeLongReset,
    ClockTypeShortReset,
} PromodoroClockType;

@interface PromodoroModel : EFBaseViewModel

@property (nonatomic,readonly) NSInteger remainingTime;//剩余时间，毫秒
@property (nonatomic,readonly) PromodoroClockType clockType;//时钟类型

@property (nonatomic) int promodoroDuration;//一个番茄是时间，单位分钟
@property (nonatomic) int resetShortDuration;//一个短休时间，单位分钟
@property (nonatomic) int resetLongDuration;//一个长休时间，单位分钟

/*!
 *  @brief 开始番茄时间
 */
-(void)startPromodoroTime;

/*!
 *  @brief 停止番茄时间
 */
-(void)stopPromodoroTime;

/*!
 *  @brief 暂停番茄时间
 */
-(void)pausePromodoroTime;

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
