//
//  AccelerometerFilter.m
//  VelocityDetector
//
//  Created by 明瑞 on 16/3/3.
//  Copyright © 2016年 明瑞. All rights reserved.
//

#import "HighpassFilter.h"

#define kAccelerometerMinStep				0.02
#define kAccelerometerNoiseAttenuation		3.0

double Norm(double x, double y, double z)
{
	return sqrt(x * x + y * y + z * z);
}

double Clamp(double v, double min, double max)
{
	if(v > max)
		return max;
	else if(v < min)
		return min;
	else
		return v;
}


#pragma mark -

@implementation HighpassFilter
@synthesize x,y,z;

- (id)initWithSampleRate:(double)rate cutoffFrequency:(double)freq
{
	self = [super init];
	if (self != nil)
	{
		double dt = 1.0 / rate;
		double RC = 1.0 / freq;
		filterConstant = RC / (dt + RC);
	}
	return self;
}

- (void)addAcceleration:(CMAcceleration)accel
{
	double alpha = filterConstant;
	
	x = alpha * (x + accel.x - lastX);
	y = alpha * (y + accel.y - lastY);
	z = alpha * (z + accel.z - lastZ);
	
	lastX = accel.x;
	lastY = accel.y;
	lastZ = accel.z;
}
@end