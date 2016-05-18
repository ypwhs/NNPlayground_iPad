//
//  LossView.m
//  NNPlayground
//
//  Created by 杨培文 on 16/5/18.
//  Copyright © 2016年 杨培文. All rights reserved.
//

#import "LossView.h"

@implementation LossView

vector<CGFloat> train;
vector<CGFloat> test;

- (void)drawRect:(CGRect)rect {
    if(train.size() < 1)return;
    CGContext * context = UIGraphicsGetCurrentContext();
    CGFloat max = 0, min = train[0];
    int n = (int)train.size();
    for(int i = 0; i < n; i++){
        if(train[i] > max)max = train[i];
        if(train[i] < min)min = train[i];
    }
    for(int i = 0; i < n; i++){
        if(test[i] > max)max = test[i];
        if(test[i] < min)min = test[i];
    }
    min *= 0.9;
    CGFloat delta = (max - min) * 1.1;
    int width = rect.size.width;
    int height = rect.size.height;
    vector<CGPoint> trainpoints;
    vector<CGPoint> testpoints;
    
    int w2 = 1000;
    if(n < w2){
        for(int i = 0; i < n; i++){
            trainpoints.push_back(CGPointMake(width*CGFloat(i)/CGFloat(n-1), (1 - (train[i] - min) / delta) * height));
        }
    }else{
        for(int i = 0; i < w2; i++){
            trainpoints.push_back(CGPointMake(width*CGFloat(i)/CGFloat(w2), (1 - (train[i * n / w2] - min) / delta) * height));
        }
    }
    
    if(n < w2){
        for(int i = 0; i < n; i++){
            testpoints.push_back(CGPointMake(width*CGFloat(i)/CGFloat(n-1), (1 - (test[i] - min) / delta) * height));
        }
    }else{
        for(int i = 0; i < w2; i++){
            testpoints.push_back(CGPointMake(width*CGFloat(i)/CGFloat(w2), (1 - (test[i * n / w2] - min) / delta) * height));
        }
    }
    
    CGContextSetLineWidth(context , 1.0);
    [[UIColor colorWithWhite:0 alpha:0.2] setStroke];
    
    CGContextAddLines(context, trainpoints.data(), trainpoints.size());
    CGContextDrawPath(context, kCGPathStroke);
    
    [[UIColor blackColor] setStroke];
    CGContextAddLines(context, testpoints.data(), testpoints.size());
    CGContextDrawPath(context, kCGPathStroke);
    
}

-(void)clearData{
    train.clear();
    test.clear();
    [self setNeedsDisplay];
}

-(void)addLoss:(double)a
          test:(double)b{
    train.push_back(a);
    test.push_back(b);
    [self setNeedsDisplay];
}

@end
