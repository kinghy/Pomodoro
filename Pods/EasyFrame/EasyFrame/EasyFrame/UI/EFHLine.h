//
//  QUHLine.h
//  A50
//
//  Created by  rjt on 15/10/11.
//  Copyright © 2015年 JYZD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EFHLine : UIView
+(instancetype)lineWithFrame:(CGRect)frame andColor:(UIColor*)color;
-(void)trans;
@property (nonatomic,strong) CAShapeLayer* lineLayer;
@end
