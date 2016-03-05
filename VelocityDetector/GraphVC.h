//
//  GraphVC.h
//  VelocityDetector
//
//  Created by 明瑞 on 16/3/4.
//  Copyright © 2016年 明瑞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GraphView.h"

@protocol GraphVCDelegate <NSObject>
- (void)valueChanged:(int)n;
- (void)paused:(BOOL)paused;
@end

@interface GraphVC : UIViewController
@property (weak, nonatomic) IBOutlet GraphView *unfiltered;
@property (weak, nonatomic) IBOutlet GraphView *filtered;
@property (weak, nonatomic) id<GraphVCDelegate> delegate;
@end
