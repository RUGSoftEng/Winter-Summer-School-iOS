//
//  Extensions.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/3/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import UIKit
import MapKit

/// Extension to URLSession for allowing synchronous network requests
extension URLSession {
    
    /// What a let down, I thought it would actually perform a synchonous call.
    /// not just wait for a flag to be set. Pretty much what I was doing already.
    /// I guess it technically is synchronous now; just in an ugly manner.
    func synchronousDataTask(with url: URL) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let dataTask = self.dataTask(with: url) {
            data = $0
            response = $1
            error = $2
            
            semaphore.signal()
        }
        
        dataTask.resume()
        _ = semaphore.wait(timeout: .distantFuture)
        
        return (data, response, error)
    }
}

/// Extension allowing HTML to be parsed into a select UIFont
extension NSAttributedString {
    
    public convenience init?(HTMLString html: String, font: UIFont? = nil) throws {
        let options: [String: Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSNumber(value: String.Encoding.utf8.rawValue)
        ]
        
        guard let data = html.data(using: .utf8, allowLossyConversion: true) else {
            throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
        }
        
        if let font = font {
            guard let attr = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
                throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
            }
            var attrs = attr.attributes(at: 0, effectiveRange: nil)
            attrs[NSFontAttributeName] = font
            attr.setAttributes(attrs, range: NSRange(location: 0, length: attr.length))
            self.init(attributedString: attr)
        } else {
            try? self.init(data: data, options: options, documentAttributes: nil)
        }
    }
}

/// Extension allowing for the rotation of UIViews
extension UIView {
    
    func rotate(duration: CFTimeInterval = 1.0, degrees:Double, completionDelegate: CAAnimationDelegate? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        let radians = CGFloat(degrees * M_PI / degrees)
        rotateAnimation.toValue = CGFloat(radians)
        rotateAnimation.duration = duration
        
        if let delegate: CAAnimationDelegate = completionDelegate {
            rotateAnimation.delegate = delegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
        
        // Actually set the layer's property
        self.layer.transform = CATransform3DMakeRotation(radians, 0.0, 0.0, 1.0)
    }
}

/// Extension allowing UILabel to provide an appropriate frame size for a given string.
extension UILabel {
    
    class func heightForString(text: String, with font: UIFont, bounded byWidth: CGFloat) -> CGFloat {
        let label: UILabel = UILabel(frame: CGRect(origin: .zero, size: CGSize(width: byWidth, height: CGFloat.greatestFiniteMagnitude)))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
}

/// Extension to RGSBaseViewController with control routines for Warning Popup Button.
extension RGSBaseViewController {
    
    /// Returns true if the warning popup should be made visible, otherwise false.
    func displayWarningPopupIfNeeded (animated: Bool) {
        
        // Display if:
        // 1. There is NOT a network connection.
        // 2. The user has NOT acknowledged it.
        if !(NetworkManager.sharedInstance.hasNetworkConnection || NetworkManager.sharedInstance.userAcknowledgedNetworkError) {
            displayWarningPopup(animated: animated)
        } else {
            dismissWarningPopup(animated: animated)
        }
    }
    
    /// Displays the Warning Popup Button with optional animation.
    func displayWarningPopup (animated: Bool) {
        
        // Unhide function.
        func display () {
            self.warningPopupHeightConstraint.constant = self.maximumWarningPopupHeight
            self.warningPopupButton.alpha = 1.0
        }
        
        // Do nothing if already displayed.
        if (warningPopupButton.isHidden == false) {
            return
        }
        
        // Unhide the button.
        warningPopupButton.isHidden = false
        
        // Animate if required.
        if (animated) {
            UIView.animate(withDuration: 0.25, animations: {
                display()
            })
        } else {
            display()
        }
    }
    
    /// Dismisses the Warning Popup Button with optional animation.
    func dismissWarningPopup (animated: Bool) {
        
        // Hide function.
        func dismiss () {
            self.warningPopupHeightConstraint.constant = self.minimumWarningPopupHeight
            self.warningPopupButton.alpha = 0.0
        }
        
        // Do nothing if already hidden.
        if (warningPopupButton.isHidden) {
            return
        }
        
        // Hide the button.
        warningPopupButton.isHidden = true
        
        // Animate if required.
        if (animated) {
            UIView.animate(withDuration: 0.25, animations: {
                dismiss()
            })
        } else {
            dismiss()
        }
    }
    
    /// Initializes the Warning Popup Button.
    func initWarningPopupButton (hidden: Bool = true, message: String = "An error occured!") {
        
        // MessageButton: Initialize, Configure.
        warningPopupButton = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: self.view.bounds.width - 16, height: 48)))
        warningPopupButton.translatesAutoresizingMaskIntoConstraints = false
        warningPopupButton.backgroundColor = AppearanceManager.sharedInstance.red
        warningPopupButton.layer.cornerRadius = 10.0
        warningPopupButton.setTitle(message, for: .normal)
        warningPopupButton.titleLabel?.font = SpecificationManager.sharedInstance.subTitleLabelFont
        warningPopupButton.addTarget(self, action: #selector(didTapWarningPopupButton(_:)), for: UIControlEvents.touchUpInside)
        warningPopupButton.isUserInteractionEnabled = true
        warningPopupButton.isHidden = hidden
        
        // MessageButton: Add to ViewController's View.
        view.addSubview(warningPopupButton)
        view.bringSubview(toFront: warningPopupButton)
        
        // Constraints: Initialize collection.
        var warningPopupButtonConstraints: [NSLayoutConstraint] = []
        
        // Constraints: Add Leading & Trailing constraints.
        warningPopupButtonConstraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-16-[warningPopup]-16-|", options: [], metrics: nil, views: ["warningPopup": warningPopupButton])
        
        // Constraints: Assign message button height. Add constraint to collection.
        let initialHeight: CGFloat = (hidden ? minimumWarningPopupHeight : maximumWarningPopupHeight)
        warningPopupHeightConstraint = NSLayoutConstraint(item: self.view, attribute: .bottom, relatedBy: .equal, toItem: warningPopupButton, attribute: .bottom, multiplier: 1.0, constant: initialHeight)
        warningPopupButtonConstraints.append(warningPopupHeightConstraint)
        
        // Constraints: Add the horizontal alignment.
        warningPopupButtonConstraints.append(NSLayoutConstraint(item: warningPopupButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0))
        
        // Constraints: Add the height constraint.
        warningPopupButtonConstraints.append(NSLayoutConstraint(item: warningPopupButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 48))
        
        // Constraints: Apply.
        NSLayoutConstraint.activate(warningPopupButtonConstraints)
        
    }
}
