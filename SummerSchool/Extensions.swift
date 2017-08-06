//
//  Extensions.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/3/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import UIKit

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

