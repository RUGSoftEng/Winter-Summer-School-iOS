//
//  SpecificationManager.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/18/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import UIKit
import MapKit

/// Enumeration of all valid keys for use with UserDefaults
enum UserDefaultKey: String {
    
    // Application Setting specific keys.
    case SchoolName             =   "applicationSchoolName"
    case SchoolId               =   "applicationSchoolIdentifier"
    case VersionNumber          =   "applicationVersionNumber"
    case PushNotifications      =   "shouldDisplayUserNotifications"
    case LockScreen             =   "shouldDisplayLockScreen"
    
    // User Identity specific keys.
    case UserDisplayName        =   "userDisplayName"
    case UserImageURL           =   "userImageURL"
    case UserIdentity           =   "userIdentity"
}

final class SpecificationManager {
    
    // MARK: - Variables & Constants: Constraint Constants
    
    /// User Defaults.
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    /// ************************* School UserDefaults *****************************
    
    /// The school name: Only settable from within specificationManager.
    private(set) var schoolName: String!
    
    /// The school identifier: Only settable from within specificationManager.
    private(set) var schoolId: String!
    
    /// The school start date: Only settable from within specificationManager.
    /// This field is not persisted and may be nil!
    private(set) var schoolStartDate: Date!
    
    /// The school end date: Only settable from within specificationManager.
    /// This field is not persisted and may be nil!
    private(set) var schoolEndDate: Date!
    
    /// The lockScreen flag: Only settable from within specificationManager.
    private(set) var shouldShowLockScreen: Bool = true
    
    /// ***************************************************************************
    
    /// The drag offset at which a UITableView should refresh its contents
    let tableViewContentRefreshOffset: CGFloat = -100
    
    /// The offset at which a UITableView should rest when running a reload animation.
    let tableViewContentReloadOffset: CGFloat = -61
    
    /// The drag offset at which a UICollectionView should refresh its contents
    let collectionViewContentRefreshOffset: CGFloat = -60
    
    /// The offset at which a UICollectionView should rest when running a reload animation.
    let collectionViewContentReloadOffset: CGFloat = -45
    
    /// The minimum allowed height for a title label.
    let titleLabelMinimumHeight: CGFloat = 72
    
    /// The maxmimum allowed height for a title label.
    let titleLabelMaximumHeight: CGFloat = 128
    
    // MARK: - Variables & Constants: Fonts
    
    /// The standard font for all Title UILabels
    let titleLabelFont: UIFont = UIFont.systemFont(ofSize: 20.0, weight: UIFontWeightMedium)
    
    /// The standard font for all SubTitle UILabels
    let subTitleLabelFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightHeavy)
    
    /// The standard font for all UITextViews
    let textViewFont: UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightRegular)
    
    // MARK: - Variables & Constants: Maps
    
    /// Coordinates for the city of Groningen, the Netherlands.
    let defaultMapCoordinates: CLLocation = CLLocation(latitude: 53.2194, longitude: 6.5665)
    
    /// The default map radius (in meters).
    let defaultMapRadius: CLLocationDistance = 4000
    
    // MARK: - Variables & Constants: UserDefaults, Misc.
    
    /// The line spacing for all UITextViews.
    let textViewLineSpacing: CGFloat = 8
    
    /// The length of a login code
    let loginCodeLength: Int = 8
    
    // MARK: - Variables & Constants: Strings
    
    let networkLossMessageString: String = "Check network connection!"
    
    /// Singleton instance
    static let sharedInstance = SpecificationManager()
    
    // MARK: - Public Class Methods
    
    /// Updates the shouldShowLockScreen flag. Change is propagated to UserDefaults.
    /// - shouldShowLockScreen: The boolean flag.
    func setShouldShowLockScreen (_ shouldShowLockScreen: Bool) {
        self.shouldShowLockScreen = shouldShowLockScreen
        defaults.set(self.shouldShowLockScreen, forKey: UserDefaultKey.LockScreen.rawValue)
        defaults.synchronize()
    }
    
    /// Updates the school name. Change is propagated to UserDefaults.
    /// - schoolName: The name of the school.
    func setSchoolName (_ schoolName: String) {
        self.schoolName = schoolName
        defaults.set(self.schoolName, forKey: UserDefaultKey.SchoolName.rawValue)
        defaults.synchronize()
    }
    
    /// Updates the school identifier. Change is propagated to UserDefaults.
    /// - schoolId: The school identifier.
    func setSchoolId (_ schoolId: String) {
        self.schoolId = schoolId
        defaults.setValue(self.schoolId, forKey: UserDefaultKey.SchoolId.rawValue)
        defaults.synchronize()
    }
    
    /// Updates the full set of user-settings at once. Preferrable over individual use.
    /// - shouldShowLockScreen: Boolean flag.
    /// - schoolName: The name of the school.
    /// - schoolId: The school identifier.
    func setUserSettings (_ shouldShowLockScreen: Bool, _ schoolName: String, _ schoolId: String, _ startDate: String, _ endDate: String) {
        
        // Assign all variables.
        self.shouldShowLockScreen = shouldShowLockScreen
        self.schoolName = schoolName
        self.schoolId = schoolId
        
        // Assign to non-persistent variables.
        self.schoolStartDate = DateManager.sharedInstance.ISOStringToDate(startDate, format: .JSONGeneralDateFormat)
        self.schoolEndDate = DateManager.sharedInstance.ISOStringToDate(endDate, format: .JSONGeneralDateFormat)
        
        // Assign all UserDefaults.
        defaults.set(self.shouldShowLockScreen, forKey: UserDefaultKey.LockScreen.rawValue)
        defaults.set(self.schoolName, forKey: UserDefaultKey.SchoolName.rawValue)
        defaults.setValue(self.schoolId, forKey: UserDefaultKey.SchoolId.rawValue)
        
        print("SpecificationManager: Status Change!\n\tLockScreen Status: \(shouldShowLockScreen)\n\tSchool Name: \(schoolName)\n\tSchool Id: \(schoolId)")
        
        // Synchronize defaults.
        defaults.synchronize()
    }
    
    // MARK: - Class Method Overrides
    
    required init() {
        
        /// Initialize schoolName from UserDefaults: (Should always succeed. Is in defaults).
        self.schoolName = defaults.string(forKey: UserDefaultKey.SchoolName.rawValue)
        
        /// Initialize schoolId from UserDefaults: (Might succeed only. Not in defaults).
        if let schoolId = defaults.string(forKey: UserDefaultKey.SchoolId.rawValue) {
            self.schoolId = schoolId
        }
        
        /// Update shouldShowLockScreen from UserDefaults: (Should always succed. Is in defaults).
        self.shouldShowLockScreen = defaults.bool(forKey: UserDefaultKey.LockScreen.rawValue)
        
        print("SpecificationManager: Initialized!\n\tLockScreen Status: \(shouldShowLockScreen)\n\tSchool Name: \(schoolName)\n\tSchool Id: \(schoolId)")
    }
}
