//
//  SpecificationManager.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/18/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import UIKit

/// Enumeration of all valid keys for use with UserDefaults
enum UserDefaultKey: String {
    case VersionNumber      =   "applicationVersionNumber"
    case PushNotifications  =   "shouldDisplayUserNotifications"
    case LockScreen         =   "shouldDisplayLockScreen"
}

final class SpecificationManager {
    
    // MARK: - Variables & Constants: Constraint Constants
    
    /// The drag offset at which a UITableView should refresh its contents
    let tableViewContentRefreshOffset: CGFloat = -100
    
    /// The drag offset at which a UICollectionView should refresh its contents
    let collectionViewContentRefreshOffset: CGFloat = -60
    
    /// The maxmimum allowed height for a title label.
    let titleLabelMaximumHeight: CGFloat = 128
    
    // MARK: - Variables & Constants: Fonts
    
    /// The standard font for all Title UILabels
    let titleLabelFont: UIFont = UIFont.systemFont(ofSize: 20.0, weight: UIFontWeightMedium)
    
    /// The standard font for all SubTitle UILabels
    let subTitleLabelFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightHeavy)
    
    /// The standard font for all UITextViews
    let textViewFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightRegular)
    
    // MARK: - Variables & Constants: UserDefaults, Misc.
    
    /// The length of a login code
    let loginCodeLength: Int = 8
    
    /// The UserDefaults to be set upon application launch
    let applicationLaunchDefaults: [String: Any] = [UserDefaultKey.VersionNumber.rawValue: "0.1", UserDefaultKey.LockScreen.rawValue: true] as [String: Any]
    
    /// Singleton instance
    static let sharedInstance = SpecificationManager()
}
