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
    
    func authenticateLoginCode(_ loginCode: String, callback: @escaping (AuthState, String?, String?) -> Void) -> Void {
        
        // Construct loginCode verification URL.
        let requestURL: String = NetworkManager.sharedInstance.URLForLoginCode(loginCode)
    
        // Dispatch request. A school ID is expected in the return data as an indication of success.
        NetworkManager.sharedInstance.makeGetRequest(url: requestURL, onCompletion: {(data: Data?, response: URLResponse?) -> Void in
            let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
            let schoolInfo: (String, String)? = DataManager.sharedInstance.parseLoginCodeResponseData(data: data)
            
            // Status Code isn't 200 -> Incorrect login code.
            if (httpResponse.statusCode != 200) {
                return callback(.badLoginCode, nil, nil)
            }
            
            // Status Code = 200, but schoolInfo is nil -> Bad network connection.
            if (schoolInfo == nil) {
                return callback(.badNetworkConnection, nil, nil)
            }

            // Response, code == 200, data != nil -> Authenticated.
            return callback(.authenticated, schoolInfo!.0, schoolInfo!.1)
        })
    }
    
    // MARK: - Class Initializer
    
    required init () {
        
    }
}

