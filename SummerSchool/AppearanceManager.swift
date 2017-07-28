//
//  AppearanceManager.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/18/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import UIKit

final class AppearanceManager {
    
    // MARK: - Variables & Constants: Colors
    
    /// Color: Standard grey for Navigation UI.
    let grey: UIColor = UIColor(displayP3Red: 160.0/255.0, green: 160.0/255.0, blue: 160.0/255.0, alpha: 1.0)
    
    /// Color: Standard red for Navigation UI.
    let red: UIColor = UIColor(displayP3Red: 235.0/255.0, green: 65.0/255.0, blue: 66.0/255.0, alpha: 1.0)
    
    /// Color: Standard red for Rijksuniversiteit Groningen
    let rugRed: UIColor = UIColor(displayP3Red: 204.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    
    // MARK: - Variables & Constants: Images
    
    /// Image: Return Arrow for UINavigationItem
    let returnArrowImage: UIImage = UIImage(named: "ReturnArrow")!
    
    /// Image: Settings Nut for UINavigationItem
    let settingsNutImage: UIImage = UIImage(named: "NutIcon")!
    
    /// Singleton instance
    static let sharedInstance = AppearanceManager()
    
    // MARK: - Public Methods
    
    func imageWithGuassianBlur(_ image: UIImage) -> UIImage {
        let source = CIImage(image: image)
        let filter = CIFilter(name: "CIGuassianBlur")
        filter?.setValue(source, forKey: "inputImage")
        let result = filter?.value(forKey: "outputImage") as! CIImage
        return UIImage(ciImage: result)
    }
    
    
}
