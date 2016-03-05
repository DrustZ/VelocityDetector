//
//  AccelerometerFilter.h
//  VelocityDetector
//
//  Created by 明瑞 on 16/3/3.
//  Copyright © 2016年 明瑞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>

// A filter class to represent a highpass filter.
@interface HighpassFilter : NSObject
{
    double x, y, z;
	double filterConstant;
	double lastX, lastY, lastZ;
}

@property (nonatomic, readonly) double x;
@property (nonatomic, readonly) double y;
@property (nonatomic, readonly) double z;

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq;

- (void)addAcceleration:(CMAcceleration)accel;

@end