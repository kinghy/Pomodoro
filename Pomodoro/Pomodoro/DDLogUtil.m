//
//  DDLogUtil.m
//  Pomodoro
//
//  Created by  rjt on 16/6/29.
//  Copyright © 2016年 JYZD. All rights reserved.
//

#import "DDLogUtil.h"

@implementation DDLogUtil
+(void)openDDLog{
    // Enable XcodeColors
    setenv("XcodeColors", "YES", 0);
    
    // Standard lumberjack initialization
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // And then enable colors
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    // Check out default colors:
    // Error : Red
    // Warn  : Orange
    
    DDLogError(@"Paper jam");                              // Red
    DDLogWarn(@"Toner is low");                            // Orange
    DDLogInfo(@"Warming up printer (pre-customization)");  // Default (black)
    DDLogVerbose(@"Intializing protcol x26");              // Default (black)
    
    // Now let's do some customization:
    // Info  : Pink
    
#if TARGET_OS_IPHONE
    UIColor *pink = [UIColor colorWithRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
#else
    NSColor *pink = [NSColor colorWithCalibratedRed:(255/255.0) green:(58/255.0) blue:(159/255.0) alpha:1.0];
#endif
    
    [[DDTTYLogger sharedInstance] setForegroundColor:pink backgroundColor:nil forFlag:DDLogFlagInfo];
    
    DDLogInfo(@"Warming up printer (post-customization)"); // Pink !
}
@end
