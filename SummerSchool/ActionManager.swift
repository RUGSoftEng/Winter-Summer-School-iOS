//
//  ActionManager.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/13/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import UIKit

final class ActionManager {
    
    // MARK: - Variables & Constants
    
    /// Singleton instance
    static let sharedInstance = ActionManager()
    
    // MARK: - Public Methods
    
    /// Returns True if the given character is alphanumerical
    func isAlnum(_ char: Character) -> Bool {
        switch char {
        case "a"..."z":
            return true
        case "A"..."Z":
            return true
        case "0"..."9":
            return true
        default:
            return false
        }
    }
    
    /// Returns an Attributes Dictionary to produce a URL
    func getLinkAttributes(_ urlString: String) -> [String: Any] {
        return [NSLinkAttributeName: NSURL(string: urlString)!,
                NSForegroundColorAttributeName: AppearanceManager.sharedInstance.red
        ] as [String: Any]
    }
    
    /// Returns a string for a given address which may be opened in Maps 
    func getMapURLString(_ string: String?) -> String {
        var mapURL: String = "http://maps.apple.com/?q="
        
        // Return if no string given
        if (string == nil) {
            return mapURL
        }
        
        // Build URL
        for char in string!.characters {
            if isAlnum(char) {
                mapURL.append(char)
            } else {
                if (mapURL.characters.last != "+") {
                    mapURL.append("+")
                }
            }
        }
        
        return mapURL
    }
    
    /// Returns an AttributedString interpreted from string as a HTML text doument.
    func stringAsAttributedHTMLString(_ string: String) -> NSAttributedString {
        let HTMLData = NSString(string: string).data(using: String.Encoding.unicode.rawValue)
        let attributedString = try! NSAttributedString(data: HTMLData!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
        return attributedString
    }
    
    func getActionSheet(title: String, message: String, dismissMessage: String) -> UIAlertController {
        let controller: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction: UIAlertAction = UIAlertAction(title: dismissMessage, style: .cancel, handler: nil)
        controller.addAction(dismissAction)
        return controller
    }
    
}
