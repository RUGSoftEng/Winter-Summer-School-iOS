//
//  RGSControlBarDelegate.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/5/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import UIKit

protocol RGSControlBarDelegate {
    
    /// Determines whether or not to display the return button
    /// - Returns: Bool.
    func shouldShowReturnButton() -> Bool
    
    /// Determines whether or not to display the title label
    /// - Returns: (Bool, String).
    func shouldShowTitleLabel() -> (Bool, String?)
    
    /// Handler for a touch-up-inside on the return button
    /// - Returns: Void.
    func didSelectSettingsButton(_  sender: UIButton) -> Void
    
    /// Handler for a touch-up-inside on the settings button
    /// - Returns: Void.
    func didSelectReturnButton(_ sender: UIButton) -> Void
    
}
