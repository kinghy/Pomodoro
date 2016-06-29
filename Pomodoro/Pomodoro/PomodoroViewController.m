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

@end

@implementation PomodoroViewController

//-(Class)typeOfModel{
//    return [PomodoroModel class];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
//    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//    SystemSoundID soundID;
//    NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"msg" ofType:@"wav"];
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
//    AudioServicesPlaySystemSound(soundID);
    
    // Do any additional setup after loading the view from its nib.
    self.viewModel = [PomodoroModel viewModel];

    __weak PomodoroModel* model = (PomodoroModel*)self.viewModel ;
    [model startPomodoroTime];
    [[RACObserve(model,remainingTime) map:^id(NSNumber* value) {
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"mm:ss"];
        return [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:value.integerValue]];
    }] subscribeNext:^(id x) {
        NSLog(@"%f,%f",self.timeLayer.strokeStart,self.timeLayer.strokeEnd);
        if (model.remainingTime.integerValue>0) {
            self.pomodoroImg.hidden = YES;
            self.timeLabel.hidden = NO;
        }else{
            self.pomodoroImg.hidden = NO;
            self.timeLabel.hidden = YES;
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        self.timeLabel.text = (model.remainingTime.intValue>0)?x:@"番茄时间";
        self.timeLayer.strokeStart += 1.f/(model.pomodoroDuration*60);
        if (model.remainingTime.integerValue%2) {
            self.timeLayer.strokeColor = [UIColor blueColor].CGColor;
        }else{
            self.timeLayer.strokeColor = [UIColor redColor].CGColor;
        }
    }];
    
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

- (RACSignal *)createSignal{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"signal created");
        return nil;
    }];
}

@end
