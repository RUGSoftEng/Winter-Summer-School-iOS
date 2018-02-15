//
//  SummerSchoolStyleKit.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/8/17.
//  Copyright (c) 2017 RUG. All rights reserved.
//
//

import UIKit

public class SummerSchoolStyleKit : NSObject {

    //// Cache

    private struct Cache {
        static let rugRed: UIColor = UIColor(red: 204.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        static let lightGrey: UIColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1.000)
        static let darkGrey: UIColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.000)
    }

    //// Colors

    public class var rugRed: UIColor { return Cache.rugRed }
    public class var darkGrey: UIColor { return Cache.darkGrey }
    public class var lightGrey: UIColor { return Cache.lightGrey }
    
    //// Drawing Methods

    public class func drawLoadingIndicator(indicatorProgress: CGFloat = 0, fillColor: UIColor = rugRed) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()

        //// Variable Declarations
        let indicatorMaxDashCount: CGFloat = 110
        let indicatorDashCount: CGFloat = indicatorMaxDashCount * indicatorProgress

        //// IndicatorPath Drawing
        let indicatorPathPath = UIBezierPath()
        indicatorPathPath.move(to: CGPoint(x: 40, y: 22.5))
        indicatorPathPath.addCurve(to: CGPoint(x: 22.5, y: 40), controlPoint1: CGPoint(x: 40, y: 32.16), controlPoint2: CGPoint(x: 32.16, y: 40))
        indicatorPathPath.addCurve(to: CGPoint(x: 5, y: 22.5), controlPoint1: CGPoint(x: 12.84, y: 40), controlPoint2: CGPoint(x: 5, y: 32.16))
        indicatorPathPath.addCurve(to: CGPoint(x: 22.5, y: 5), controlPoint1: CGPoint(x: 5, y: 12.84), controlPoint2: CGPoint(x: 12.84, y: 5))
        indicatorPathPath.addCurve(to: CGPoint(x: 40, y: 22.5), controlPoint1: CGPoint(x: 32.16, y: 5), controlPoint2: CGPoint(x: 40, y: 12.84))
        indicatorPathPath.close()
        indicatorPathPath.lineCapStyle = .round;

        fillColor.setStroke()
        indicatorPathPath.lineWidth = 4
        context?.saveGState()
        context?.setLineDash(phase: 1, lengths: [indicatorDashCount, 550])
        indicatorPathPath.stroke()
        context?.restoreGState()
    }

}
