//
//  RGSLoadingIndicatorView.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/8/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSLoadingIndicatorView: UIView {

    // MARK: - Variables & Constants
    
    /// The fractional progress for the loading indicator (0 <= progress <= 1).
    var progress: CGFloat = 0.0 {
        didSet (oldProgress) {
            progress = max(min(progress, 1.0), 0.0)
            setNeedsDisplay()
        }
    }
    
    // MARK: - Class Method Overrides
    
    override func draw(_ rect: CGRect) {
        SummerSchoolStyleKit.drawLoadingIndicator(indicatorProgress: progress)
    }
 
}
