//
//  LossView.h
//  NNPlayground
//
//  Created by 杨培文 on 16/5/18.
//  Copyright © 2016年 杨培文. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iostream>
#import <vector>

using namespace std;

@interface LossView : UIView

-(void)clearData;
-(void)addLoss:(double)a
          test:(double)b;

@end
