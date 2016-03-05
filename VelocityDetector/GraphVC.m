//
//  GraphVC.m
//  VelocityDetector
//
//  Created by 明瑞 on 16/3/4.
//  Copyright © 2016年 明瑞. All rights reserved.
//

#import "GraphVC.h"

@interface GraphVC (){
    BOOL paused;
}
@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;

@end

@implementation GraphVC
- (IBAction)typeChanged:(UISegmentedControl *)sender {
    if (self.delegate)
        [self.delegate valueChanged:(int)[sender selectedSegmentIndex]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    paused = false;
}

- (IBAction)paused:(UIButton *)sender {
    paused = !paused;
    if (paused)
        [_pauseBtn setTitle:@"RESUME" forState:UIControlStateNormal];
    else
        [_pauseBtn setTitle:@"PAUSE" forState:UIControlStateNormal];
    if (self.delegate)
        [self.delegate paused:paused];
}

- (IBAction)goBack:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
