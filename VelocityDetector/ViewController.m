//
//  ViewController.m
//  VelocityDetector
//
//  Created by 明瑞 on 16/3/3.
//  Copyright © 2016年 明瑞. All rights reserved.
//

#import "ViewController.h"
#import "HighpassFilter.h"
#import "GraphVC.h"

#define kUpdateFrequency    60.0
static double timeInterval = 1.0/kUpdateFrequency;
@interface ViewController () <GraphVCDelegate>
{
    double lastAx[4],lastAy[4],lastAz[4];
    int countX, countY, countZ, accCount;
    double lastVx, lastVy, lastVz, maxV;
    
    int type;
    
    HighpassFilter * filter;
    CMMotionManager * manager;
    GraphVC * graphVC;
}

@property (weak, nonatomic) IBOutlet UILabel *speedLabel;
@property (weak, nonatomic) IBOutlet UILabel *xaccLabel;
@property (weak, nonatomic) IBOutlet UILabel *yaccLabel;
@property (weak, nonatomic) IBOutlet UILabel *zaccLabel;
@property (weak, nonatomic) IBOutlet UILabel *maxvLabel;
@property (nonatomic, assign) BOOL paused;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    lastVx = 0, lastVy = 0, lastVz = 0;
    accCount = maxV = type = 0;
    
    for (int i = 0; i < 4; ++i){
        lastAx[i] = lastAy[i] = lastAz[i] = 0;
    }
    
    manager = [[CMMotionManager alloc] init];
    manager.accelerometerUpdateInterval = timeInterval;
    manager.gyroUpdateInterval = timeInterval;
    
    filter = [[HighpassFilter alloc] initWithSampleRate:kUpdateFrequency cutoffFrequency:5.0];
    
    [manager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMDeviceMotion *data, NSError *error) {
                                                [self outputAccelertion:data];
                                            }];
}

- (void)viewDidAppear:(BOOL)animated{
    graphVC = nil;
}

- (void)outputAccelertion:(CMDeviceMotion*)data
{
    CMAcceleration acc = [data userAcceleration];
    CMAcceleration gacc = [data gravity];
    acc.x += gacc.x, acc.y += gacc.y, acc.z += gacc.z;
    CMRotationMatrix rot = [data attitude].rotationMatrix;
    CMAcceleration accRef;
    
    //first correct the direction
    accRef.x = acc.x*rot.m11 + acc.y*rot.m12 + acc.z*rot.m13;
    accRef.y = acc.x*rot.m21 + acc.y*rot.m22 + acc.z*rot.m23;
    accRef.z = acc.x*rot.m31 + acc.y*rot.m32 + acc.z*rot.m33;
    
    //filter the data
    [filter addAcceleration:accRef];
    
    if (!_paused && graphVC && type == 1){
        [graphVC.unfiltered addX:accRef.x y:accRef.y z:accRef.z];
        [graphVC.filtered addX:filter.x y:filter.y z:filter.z];
    }
    
    //add threshold
    accRef.x = (fabs(filter.x) < 0.03) ? 0 : filter.x;
    accRef.y = (fabs(filter.y) < 0.03) ? 0 : filter.y;
    accRef.z = (fabs(filter.z) < 0.03) ? 0 : filter.z;
    
    //we use simpson 3/8 integration method here
    accCount = (accCount+1)%4;
    
    lastAx[accCount] = accRef.x, lastAy[accCount] = accRef.y, lastAz[accCount] = accRef.z;
    
    if (!_paused && graphVC && type == 0)
        [graphVC.unfiltered addX:lastVx+accRef.x*timeInterval y:lastVy+accRef.y*timeInterval z:lastVz+accRef.z*timeInterval];
    
    if (accCount == 3){
        lastVx += (lastAx[0]+lastAx[1]*3+lastAx[2]*3+lastAx[3]) * 0.125 * timeInterval * 3;
        lastVy += (lastAy[0]+lastAy[1]*3+lastAy[2]*3+lastAy[3]) * 0.125 * timeInterval * 3;
        lastVz += (lastAz[0]+lastAz[1]*3+lastAz[2]*3+lastAz[3]) * 0.125 * timeInterval * 3;
    }
    
    //add a fake force
    //(when acc is zero for a continuous time, we should assume that velocity is zero)
    if (accRef.x == 0) countX++; else countX = 0;
    if (accRef.y == 0) countY++; else countY = 0;
    if (accRef.z == 0) countZ++; else countZ = 0;
    if (countX == 10){
        countX = 0;
        lastVx = 0;
    }
    if (countY == 10){
        countY = 0;
        lastVy = 0;
    }
    if (countZ == 10){
        countZ = 0;
        lastVz = 0;
    }
    
    if (!_paused && graphVC && type == 0)
        [graphVC.filtered addX:lastVx y:lastVy z:lastVz];
    
    //get total V
    double vx = lastVx * 9.8, vy = lastVy * 9.8, vz = lastVz * 9.8;
    double lastV = sqrt(vx * vx + vy * vy + vz * vz);
    
    [_speedLabel setText:[NSString stringWithFormat:@"%.2f",lastV]];
    [_xaccLabel setText:[NSString stringWithFormat:@"%.2f g",accRef.x]];
    [_yaccLabel setText:[NSString stringWithFormat:@"%.2f g",accRef.y]];
    [_zaccLabel setText:[NSString stringWithFormat:@"%.2f g",accRef.z]];
    
    if (fabs(maxV) < fabs(lastV)){
        maxV = lastV;
        [_maxvLabel setText:[NSString stringWithFormat:@"%.2f m/s", maxV]];
    }
}

- (void)valueChanged:(int)n{
    type = n;
}

- (void)paused:(BOOL)paused{
    _paused = paused;
}

- (IBAction)pushToGraph:(UIButton *)sender {
    graphVC = [[UIStoryboard storyboardWithName:@"Main"
                                         bundle:nil] instantiateViewControllerWithIdentifier:@"graphVC"];
    graphVC.delegate = self;
    [self.navigationController pushViewController:graphVC animated:YES];
}

- (IBAction)reset:(UIButton *)sender {
    lastVx = lastVy = lastVz = 0;
    countX = countY = countZ = 0;
    maxV = 0;
    [_speedLabel setText:nil];
    [_xaccLabel setText:nil];
    [_yaccLabel setText:nil];
    [_zaccLabel setText:nil];
    [_maxvLabel setText:nil];
}

@end
