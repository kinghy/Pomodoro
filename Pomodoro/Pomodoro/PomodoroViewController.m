//
//  PomodoroViewController.m
//  Pomodoro
//
//  Created by  rjt on 16/6/28.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "PomodoroViewController.h"
#import "ReactiveCocoa.h"
#import <AudioToolbox/AudioToolbox.h>

@interface PomodoroViewController ()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIView *timeView;

@property (nonatomic,strong) CAShapeLayer *timeLayer;
@property (weak, nonatomic) IBOutlet UIImageView *pomodoroImg;
@property (weak, nonatomic) IBOutlet UIButton *startBtn;
@property (weak, nonatomic) IBOutlet UIButton *stopBtn;

@end

@implementation PomodoroViewController

//-(Class)typeOfModel{
//    return [PomodoroModel class];
//}

- (void)viewDidLoad {
    self.viewModel = [PomodoroModel viewModel];
    [super viewDidLoad];
//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);

    
    // Do any additional setup after loading the view from its nib.

    
//    [self alarm];
    //创建出CAShapeLayer
    self.timeLayer = [CAShapeLayer layer];
    self.timeLayer.frame = self.timeView.bounds;//设置shapeLayer的尺寸和位置
//    self.timeLayer.position = self.timeView.layer.position;
    self.timeLayer.fillColor = [UIColor clearColor].CGColor;//填充颜色为ClearColor
    
    //设置线条的宽度和颜色
    self.timeLayer.lineWidth = 1.0f;
    self.timeLayer.strokeColor = [UIColor redColor].CGColor;
    //创建出圆形贝塞尔曲线
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.timeLayer.frame.size.width/2, self.timeLayer.frame.size.height/2) radius:self.timeLayer.frame.size.height/2 startAngle:-M_PI_2 endAngle:M_PI*2-M_PI_2 clockwise:YES];
    
    //让贝塞尔曲线与CAShapeLayer产生联系
    self.timeLayer.path = circlePath.CGPath;
    [self.timeView.layer addSublayer:self.timeLayer];
    
    


}

-(void)bindViewModel{
    if (self.viewModel) {
        __weak PomodoroModel* model = (PomodoroModel*)self.viewModel ;
        @weakify(self)
        [RACObserve(model,remainingTime) subscribeNext:^(NSNumber* time) {
            @strongify(self)
            [self tickTackWithTime:time andDuration:model.pomodoroDuration];
        }];
        self.startBtn.rac_command = model.startCmd;
        [self.startBtn.rac_command.executionSignals subscribeNext:^(id x) {
            [self setLocalNotification:[NSDate dateWithTimeIntervalSinceNow:model.pomodoroDuration*60]];
        }];
        self.stopBtn.rac_command = model.stopCmd;
        [self.stopBtn.rac_command.executionSignals subscribeNext:^(id x) {
            [self clearLocalNotification];
        }];

    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

/*!
 *  @brief 闹钟倒计时
 *
 *  @param time 剩余秒数
 *  @param time 一个周期（分钟）
 */
-(void)tickTackWithTime:(NSNumber*)time andDuration:(int)pomodoroDuration{
    NSString *strTime = @"番茄时间";
    if(time && time.integerValue<=0){
        @weakify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self)
            self.pomodoroImg.hidden = NO;
            self.timeLabel.hidden = YES;
            self.timeLayer.strokeStart = 0;
            self.timeLabel.text = @"番茄时间";
            [self alarm];
        });
    }
    
    if (!time) {
        self.pomodoroImg.hidden = NO;
        self.timeLabel.hidden = YES;
    }else{
        self.pomodoroImg.hidden = YES;
        self.timeLabel.hidden = NO;
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    strTime = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:time.integerValue]];
    self.timeLabel.text = strTime;
    self.timeLayer.strokeStart = 1 - time.floatValue/(pomodoroDuration*60);
    if (time.integerValue%2) {
        self.timeLayer.strokeColor = [UIColor blueColor].CGColor;
    }else{
        self.timeLayer.strokeColor = [UIColor redColor].CGColor;
    }
}

-(void)alarm{
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    //循环调用
    AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL,systemAudioCallback, NULL);
//    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    SystemSoundID soundID;
    NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"dream" ofType:@"caf"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    NSDate *alarmDate = [NSDate date];
    AudioServicesPlaySystemSoundWithCompletion(soundID, ^{
        NSDate *date = [NSDate date];
        NSTimeInterval secondsInterval= [date timeIntervalSinceDate:alarmDate];
        //根据时间间隔判断是否静音
        if (secondsInterval>0.5f) {
            AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
        }else{
            //十秒后自动关闭震动
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
            });
        }
    });
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
        AudioServicesRemoveSystemSoundCompletion(soundID);
        AudioServicesDisposeSystemSoundID(soundID);
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        AudioServicesRemoveSystemSoundCompletion(kSystemSoundID_Vibrate);
        AudioServicesRemoveSystemSoundCompletion(soundID);
        AudioServicesDisposeSystemSoundID(soundID);
    }];
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:@"不要着急，不要着急，休息，休息一下~" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:continueAction];
    [alertVC addAction:cancelAction];
    [self  presentViewController:alertVC animated:YES completion:^{
    }];
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}

-(void)setLocalNotification:(NSDate *)assginDate{
    
    UILocalNotification *notification       = [[UILocalNotification alloc] init];
    notification.fireDate                   = assginDate;
    //设置推送时间，这里使用相对时间，如果fireDate采用GTM标准时间，timeZone可以至nil
    notification.timeZone                   = [NSTimeZone defaultTimeZone];
    notification.repeatInterval             = 0;
    //    NSMinuteCalendarUnit
    notification.timeZone                   = [NSTimeZone localTimeZone];
    notification.alertBody                  = @"不要着急，不要着急，休息，休息一下~";
//    notification.soundName = [[NSBundle mainBundle] pathForResource:@"梦幻" ofType:@"caf"];
    notification.soundName                  = @"dream.caf";//UILocalNotificationDefaultSoundName;
    notification.alertAction                = @"再不疯狂我们就老了";
    notification.applicationIconBadgeNumber = 1;
    notification.userInfo=@{@"isAlarm":@"is"};
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}


-(void)clearLocalNotification{
    
    //取消某一个通知
    NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
    //获取当前所有的本地通知
    if (!notificaitons || notificaitons.count <= 0) {
        return;
    }
    
    for (UILocalNotification *notify in notificaitons) {
        NSArray *arr=[notify.userInfo allKeys];
        
        if ([arr containsObject:@"isAlarm"])
        {
            //取消一个特定的通知
            [[UIApplication sharedApplication] cancelLocalNotification:notify];
            break;
        }
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


//c语言 循环调用
static void systemAudioCallback(){
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end
