//
//  SecurityManager.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/21/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation

enum AuthState: Int {
    case authenticated
    case badLoginCode
    case badNetworkConnection
}

final class SecurityManager {
    
    // MARK: - Variables & Constants
    
    /// Singleton instance
    static let sharedInstance = SecurityManager()
    
    /// Boolean state for whether the user should be asked to authenticate.
    var shouldShowLockScreen: Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: UserDefaultKey.LockScreen.rawValue)
    }
    
    /// Login Code URL
    private var loginCodeURL: String! {
        return NetworkManager.sharedInstance.URLForLoginCodes()
    }
    
    /// Login Codes
    private var loginCodes: [LoginCode]! = nil
    
    // MARK: - Private Methods
    
    /// Returns True if the given loginCode string is in the given loginCodes collection.
    private func containsLoginCode(_ loginCodes: [LoginCode]?, _ loginCode: String) -> Bool {
        if (loginCodes == nil) {
            return false
        }
        
        let matches: [Bool] = loginCodes!.map({(code: LoginCode) -> Bool in
            return code.code == loginCode
        })
        
        return matches.reduce(false, {a, b in a || b})
    }
    
    
    // MARK: - Public Methods
    
    func authenticateLoginCode(_ loginCode: String, callback: @escaping (AuthState) -> Void) -> Void {
        if (loginCodes == nil) {
            NetworkManager.sharedInstance.makeGetRequest(url: loginCodeURL, onCompletion: {(data: Data?) -> Void in
                var isAuthenticated: Bool = false
                
                if let fetched: [LoginCode] = DataManager.sharedInstance.parseDataToLoginCodes(data: data) {
                    isAuthenticated = self.containsLoginCode(fetched, loginCode)
                    self.loginCodes = fetched
                    callback((isAuthenticated == true) ? AuthState.authenticated : AuthState.badLoginCode)
                } else {
                    callback(AuthState.badNetworkConnection)
                }
            })
        } else {
            callback(containsLoginCode(self.loginCodes, loginCode) ? .authenticated : .badLoginCode)
        }
    }
    
    // MARK: - Class Initializer
    
    required init () {
        
    }
}

