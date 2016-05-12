//
//  LossView.swift
//  NNPlayground
//
//  Created by 杨培文 on 16/5/12.
//  Copyright © 2016年 杨培文. All rights reserved.
//

import UIKit

class LossView: UIView {
    var data:[CGFloat] = []
    override func drawRect(rect: CGRect) {
        if data.count < 1{
            return
        }
        let context = UIGraphicsGetCurrentContext();
        var max:CGFloat = 0;
        for d in data{
            if d > max{
                max = d;
            }
        }
        let width = rect.width
        let height = rect.height
        let n = data.count
        UIColor.blackColor().setStroke()
        CGContextSetLineWidth(context , 1.0)
        
        var points = [CGPoint]()
        for i in 0..<n{
            points.append(CGPointMake(width*CGFloat(i)/CGFloat(n), (1 - data[i] / max) * height))
        }
        CGContextAddLines(context, points, points.count)
        CGContextDrawPath(context, .Stroke)
    }
    
    func addData(d:Double){
        data.append(CGFloat(d))
        setNeedsDisplay()
    }
    
    func clearData(){
        data = []
        setNeedsDisplay()
    }

}
