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
    
    // MARK: - Private Methods

    // MARK: - Public Methods
    
    func authenticateLoginCode(_ loginCode: String, callback: @escaping (AuthState, String) -> Void) -> Void {
        
        // Construct loginCode verification URL.
        let requestURL: String = NetworkManager.sharedInstance.URLForLoginCode(loginCode)

        // Dispatch request. A school ID is expected in the return data as an indication of success.
        NetworkManager.sharedInstance.makeGetRequest(url: requestURL, onCompletion: {(data: Data?, response: URLResponse?) -> Void in
            var isAuthenticated: Bool = false
            
            // Current Temporary Scheme.
            if let httpResponse = response as? HTTPURLResponse {
                isAuthenticated = httpResponse.statusCode == 200
            }
            
            // Scheme to use when updated.
            //if let schoolId = DataManager.sharedInstance.parseLoginCodeResponseData(data: data) {
            //   callback(.authenticated, "Unknown")
            //}
            
            callback(isAuthenticated ? .authenticated : .badLoginCode, "Unknown")
        })
    }
    
    // MARK: - Class Initializer
    
    required init () {
        
    }
}

