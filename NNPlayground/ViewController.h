//
//  ViewController.h
//  NNPlayground
//
//  Created by 杨培文 on 16/4/21.
//  Copyright © 2016年 杨培文. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifndef VIEW_CONTROLLER_H
#define VIEW_CONTROLLER_H
#include "NNPlayground-Swift.h"
#include "Network.h"
#import "MBProgressHUD.h"

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet HeatMapView *heatMap;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;
@property (weak, nonatomic) IBOutlet UISwitch *myswitch;
@property (weak, nonatomic) IBOutlet UISwitch *speedupswitch;
@property (weak, nonatomic) IBOutlet UIButton *circleButton;
@property (weak, nonatomic) IBOutlet UIButton *xorButton;
@property (weak, nonatomic) IBOutlet UIButton *twoGaussianButton;
@property (weak, nonatomic) IBOutlet UIButton *spiralButton;
@property (weak, nonatomic) IBOutlet UILabel *lossLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratioOfTrainingDataLabel;
@property (weak, nonatomic) IBOutlet UILabel *noiseLabel;

@end

#endif