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
    
    /// The animation key.
    var animationKey: String = "pulseAnimation"
    
    /// The animation layer.
    var animationLayer: CAShapeLayer?
    
    /// The duration of the animation (seconds).
    var animationDuration: CFTimeInterval = 0.5
    
    /// The maximum scale of the animation.
    var animationMaxScale: CGFloat = 0.8
    
    /// The fill color of the animation
    var fillColor: UIColor = AppearanceManager.sharedInstance.rugRed
    
    /// The fractional progress for the loading indicator (0 <= progress <= 1).
    var progress: CGFloat = 0.0 {
        didSet (oldProgress) {
            progress = max(min(progress, 1.0), 0.0)
            setNeedsDisplay()
        }
    }
    
    // MARK: - Public Class Methods
    
    func startAnimation() {
        
        // Init animation layer if necessary.
        if animationLayer == nil {
            initAnimationLayer()
        }
        
        // Remove existing animations.
        stopAnimation()
        
        // Create a new animation to add to the animation layer.
        let animation: CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        animation.fromValue = 0.0
        animation.toValue = animationMaxScale
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animation.isAdditive = false
        animation.duration = animationDuration
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = true
        animation.repeatCount = .infinity
        animation.autoreverses = true
        
        // Add the animation to the animation layer.
        animationLayer?.add(animation, forKey: animationKey)
        
        // Add the animation layer as a sublayer.
        layer.addSublayer(animationLayer!)
    }
    
    func stopAnimation() {
        animationLayer?.removeAllAnimations()
        animationLayer?.removeFromSuperlayer()
    }
    
    // MARK: - Private Class Methods
    
    private func initAnimationLayer() {
        
        self.backgroundColor = UIColor.clear
        
        // Adjust layer corner radius to form a circle.
        layer.cornerRadius = bounds.height / 2
        
        // Create animation layer
        animationLayer = CAShapeLayer()
        animationLayer?.fillColor = fillColor.cgColor
        animationLayer?.path = UIBezierPath(roundedRect: bounds, cornerRadius: layer.cornerRadius).cgPath
        animationLayer?.frame = bounds
        animationLayer?.cornerRadius = bounds.height / 2
        animationLayer?.masksToBounds = true
        layer.addSublayer(animationLayer!)
    }
    
    // MARK: - Class Method Overrides
    
    override func draw(_ rect: CGRect) {
        SummerSchoolStyleKit.drawLoadingIndicator(indicatorProgress: progress)
    }
 
}
