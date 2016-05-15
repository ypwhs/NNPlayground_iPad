//
//  AccelerateButton.swift
//  NNPlayground
//
//  Created by 陈禹志 on 16/5/13.
//  Copyright © 2016年 杨培文. All rights reserved.
//

import UIKit

@IBDesignable
class AccelerateButton: UIButton {
    
    let π:CGFloat = CGFloat(M_PI)
    
    @IBInspectable var fillColor: UIColor = UIColor(red: 0x18/0xFF, green: 0x3D/0xFF, blue: 0x4E/0xFF, alpha: 1)
    @IBInspectable var isEquilateralTriangle: Bool = true{
        didSet{
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var frontWidthRatio: CGFloat = 3/16
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect)
        
        let trianglePath_1 = UIBezierPath()
        trianglePath_1.moveToPoint(CGPoint(
            x:bounds.width*(0.5 - frontWidthRatio) - 0.5,
            y:bounds.height/2 + bounds.height*frontWidthRatio*4/3))
        trianglePath_1.addLineToPoint(CGPoint(
            x:bounds.width*(0.5 - frontWidthRatio) - 0.5,
            y:bounds.height/2 - bounds.height*frontWidthRatio*4/3))
        trianglePath_1.addLineToPoint(CGPoint(
            x:bounds.width*(0.5 + frontWidthRatio/3) - 0.5,
            y:bounds.height/2))
        let trianglePath_2 = UIBezierPath()
        trianglePath_2.moveToPoint(CGPoint(
            x:bounds.width*(0.5 + frontWidthRatio/3) + 0.5,
            y:bounds.height/2 + bounds.height*frontWidthRatio*4/3))
        trianglePath_2.addLineToPoint(CGPoint(
            x:bounds.width*(0.5 + frontWidthRatio/3) + 0.5,
            y:bounds.height/2 - bounds.height*frontWidthRatio*4/3))
        trianglePath_2.addLineToPoint(CGPoint(
            x:bounds.width*(0.5 + frontWidthRatio*5/3) + 0.5,
            y:bounds.height/2))
        
        if isEquilateralTriangle {
            UIColor.whiteColor().setFill()
            path.fill()
            fillColor.setFill()
            trianglePath_1.fill()
            trianglePath_2.fill()
        }
        else {
            fillColor.setFill()
            path.fill()
            UIColor.whiteColor().setFill()
            trianglePath_1.fill()
            trianglePath_2.fill()
        }
        
    }

}
