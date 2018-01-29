//
//  SecurityManager.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/21/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import FirebaseFacebookAuthUI

enum AuthState: Int {
    case authenticated
    case badLoginCode
    case badNetworkConnection
}

final class SecurityManager: NSObject, FUIAuthDelegate {
    
    // MARK: - Variables & Constants
    
    /// User Defaults.
    private var defaults: UserDefaults {
        return UserDefaults.standard
    }
    
    /// Firebase Authentication UI instance.
    private(set) var authenticationUI: FUIAuth?
    
    /// Singleton instance
    static let sharedInstance = SecurityManager()
    
    /// Boolean state for whether the user should be asked to authenticate.
    var shouldShowLockScreen: Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: UserDefaultKey.LockScreen.rawValue)
    }
    
    /// *********************** Firebase UserDefaults *****************************
    
    // The user display name: Only publically gettable.
    private(set) var userDisplayName: String?
    
    // The user image URL: Only publically gettable.
    private(set) var userImageURL: String?
    
    // The user identitiy: Only publically gettable.
    private(set) var userIdentity: String?
    
    /// ***************************************************************************
    
    // MARK: - Private Methods

    // MARK: - Public Methods
    
    /// Firebase Function: Returns true if the user has authenticated with profile.
    func identityIsAuthenticated () -> Bool {
        return (self.userIdentity != nil && self.userImageURL != nil && self.userDisplayName != nil)
    }
    
    func requestSchoolInfo (_ schoolId: String, callback: @escaping (String?, String?, String?) -> Void) -> Void {
        
        // Construct schoolInfo verification URL.
        let requestURL: String = NetworkManager.sharedInstance.URLForSchoolInfo(schoolId)
        
        // Dispatch request. All fields are expected in return data as an indication of success.
        NetworkManager.sharedInstance.makeGetRequest(url: requestURL, onCompletion: {(data: Data?, response: URLResponse?) -> Void in
            let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
            let schoolInfo: (String, String, String)? = DataManager.sharedInstance.parseSchoolInfoResponseData(data: data)
            
            // Status Code isn't 200 or schoolInfo is nil -> Bad network connection.
            if (httpResponse.statusCode != 200 || schoolInfo == nil) {
                return callback(nil, nil, nil)
            }
            
            return callback(schoolInfo?.0, schoolInfo?.1, schoolInfo?.2)
        })
    }
    
    func authenticateLoginCode(_ loginCode: String, callback: @escaping (AuthState, String?) -> Void) -> Void {
        
        // Construct loginCode verification URL.
        let requestURL: String = NetworkManager.sharedInstance.URLForLoginCode(loginCode)
    
        // Dispatch request. A school Id is expected in the return data as an indication of success.
        NetworkManager.sharedInstance.makeGetRequest(url: requestURL, onCompletion: {(data: Data?, response: URLResponse?) -> Void in
            let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
            let schoolId: String? = DataManager.sharedInstance.parseLoginCodeResponseData(data: data)
            print("SecurityManager: Authentication Status\n\tRequest URL: \(requestURL)\n\tResponse Code: \(httpResponse.statusCode)\n\tSchool ID: \(schoolId)")
    
            // Status Code isn't 200 -> Incorrect login code.
            if (httpResponse.statusCode != 200) {
                return callback(.badLoginCode, nil)
            }
            
            // Status Code = 200, but schoolID is nil -> Bad network connection.
            if (schoolId == nil) {
                return callback(.badNetworkConnection, nil)
            }
            
            return callback(.authenticated, schoolId)
        })
    }
    
    // MARK: - Firebase FUIAuthDelegate Protocol Methods
    
    /// Delegate Method Handler.
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let userInstance = user {
            print("SecurityManager: FireBase Status\n\tDisplayName: \(userInstance.displayName)\n\tProfile Image URL: \(userInstance.photoURL)\n\tEmail: \(userInstance.email)")
            // Assign all local variables.
            self.userDisplayName = userInstance.displayName
            self.userImageURL = String(describing: userInstance.photoURL)
            self.userIdentity = userInstance.uid
            
            // Assign all UserDefaults.
            defaults.set(self.userDisplayName, forKey: UserDefaultKey.UserDisplayName.rawValue)
            defaults.set(self.userImageURL, forKey: UserDefaultKey.UserImageURL .rawValue)
            defaults.setValue(self.userIdentity, forKey: UserDefaultKey.UserIdentity.rawValue)
    
            // Synchronize defaults.
            defaults.synchronize();
        }
    }
    
    // MARK: - Class Initializer
    
    required override init () {
        super.init()
        
        // Initialize Firebase Authentication UI.
        self.authenticationUI = FUIAuth.defaultAuthUI()
        
        // Set Delegate.
        self.authenticationUI?.delegate = self
        
        // Set Firebase Authentication Providers.
        self.authenticationUI?.providers = [FUIGoogleAuth(), FUIFacebookAuth()] as [FUIAuthProvider]
        
        // Initialize UserDisplayName from UserDefaults: (Might succeed only. Not in defaults).
        if let userDisplayName = defaults.string(forKey: UserDefaultKey.UserDisplayName.rawValue) {
            self.userDisplayName = userDisplayName
        }
        
        // Initialize UserImageURL from UserDefaults: (Might succeed only. Not in defaults).
        if let userImageURL = defaults.string(forKey: UserDefaultKey.UserImageURL.rawValue) {
            self.userImageURL = userImageURL
        }
        
        // Initialize UserIdentity from UserDefaults: (Might succeed only. Not in defaults).
        if let userIdentity = defaults.string(forKey: UserDefaultKey.UserIdentity.rawValue) {
            self.userIdentity = userIdentity
        }
        print("SecurityManager initialized with: userDislayName: \(self.userDisplayName), userImageURL: \(self.userImageURL), userIdentity: \(self.userIdentity)")
    }
}

