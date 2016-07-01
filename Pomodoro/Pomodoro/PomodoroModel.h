//
//  PomodoroModel.h
//  Pomodoro
//
//  Created by  rjt on 16/6/28.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "EFHeader.h"

typedef enum {
    ClockStatusInit,
    ClockStatusRunning,
    ClockStatusFinished,//时间耗尽
    ClockStatusStoped,//提早完成
    ClockStatusPaused
} ClockStatus;

@interface PomodoroModel : EFBaseViewModel
@property (nonatomic,strong) NSNumber* remainingTime;//剩余时间，秒

@property (nonatomic) int pomodoroDuration;//一个番茄是时间，单位分钟
/*!
 *  @brief 开始番茄时间信号
 */
@property (strong, nonatomic)  RACCommand* startCmd;

/*!
 *  @brief 关闭番茄时间信号
 */
@property (strong, nonatomic)  RACCommand* stopCmd;
/*!
 *  @brief 时钟状态
 */
@property (nonatomic,readonly) ClockStatus clockStatus;

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

@end
