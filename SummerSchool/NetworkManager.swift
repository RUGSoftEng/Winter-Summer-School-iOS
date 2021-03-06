//
//  NetworkManager.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/11/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import UIKit

enum ServerPath: String {
    case generalInfoPath = "/generalinfo/item"
    case announcementPath = "/announcement/item"
    case eventPath = "/calendar/event"
    case loginCodePath = "/loginCode"
    case lecturerPath = "/lecturer/item"
    case forumPath = "/forum/item"
}

final class NetworkManager {
    
    // MARK: - Variables & Constants
    
    /// Singleton instance
    static let sharedInstance = NetworkManager()
    
    /// Connection status (dependent on success of outgoing requests).
    var hasNetworkConnection: Bool = true {
        didSet {
            
            // If network connection exists, reset acknowledgment of warning.
            if (hasNetworkConnection) {
                userAcknowledgedNetworkError = false
            }
        }
    }
    
    /// Boolean state indicating whether or not the user has dismissed a warning of a network error.
    var userAcknowledgedNetworkError: Bool = false
    
    /// Server address 
    let serverAddress: String = "http://turing13.housing.rug.nl:8800"
    
    // MARK: - Private Methods
    
    /// Returns a concatenated String representing a request URL to a
    /// server.
    ///
    /// - Parameters:
    ///     - path: The internal path at the server address
    ///     - options: The optional parameters to include
    private func serverPathWithOptions(path: ServerPath, options: String...) -> String {
        var serverPath: String = path.rawValue
        if (options.count > 0) {
            serverPath += "?"
            for (i, option) in options.enumerated() {
                serverPath += option + (i + 1 >= options.count ? "": "&")
            }
        }
        return serverPath
    }
    
    // MARK: - Public Methods
    
    /// Returns the address needed to extract general information
    /// from the server.
    func URLForGeneralInformation() -> String {
        return serverAddress + ServerPath.generalInfoPath.rawValue
    }
    
    /// Returns the address needed to extract announcements
    /// from the server.
    func URLForAnnouncements() -> String {
        return serverAddress + ServerPath.announcementPath.rawValue
    }
    
    /// Returns the address needed to extract login codes
    /// from the server.
    func URLForLoginCodes() -> String {
        return serverAddress + ServerPath.loginCodePath.rawValue
    }
    
    /// Returns the address needed to extract lecturers 
    /// from the server
    func URLForLecturers() -> String {
        return serverAddress + ServerPath.lecturerPath.rawValue
    }
    
    /// Returns the address needed to extract forum postings
    /// from the server
    func URLForForumThreads() -> String {
        return serverAddress + ServerPath.forumPath.rawValue
    }
    
    /// Returns a concatenated address needed to extract the
    /// resource from the server.
    func URLForResourceWithPath(_ path: String) -> String {
        return serverAddress + path
    }
    
    /// Returns the address needed to extract events for the specified week
    /// from the server.
    ///
    /// - Parameters:
    ///     - offset: The offset from the current week from which to
    ///               extract events. -1 = last week, 2 = next next week.
    func URLForEventsByWeek(offset: Int) -> String {
        return serverAddress + serverPathWithOptions(path: .eventPath, options: "week=\(offset)")
    }
    
    /// Performs a GET request to the given URL, executes a callback with the retrieved
    /// data. The results may be nil.
    ///
    /// - Parameters:
    ///     - url: A String describing the resource to aim the request at.
    ///     - onCompletion: A closure to execute upon completion.
    func makeGetRequest(url: String, onCompletion: @escaping (_: Data?) -> Void) -> Void {
        
        // Construct Request
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let session: URLSession = URLSession.shared
        
        // Start Network Activity Indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let task = session.dataTask(with: request) {data, response, err in
            
            // Stop Network Activity Indicator
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            // Update network status. Assumes all requests require a data response.
            self.hasNetworkConnection = (data != nil)
            
            // Execute callback
            onCompletion(data)
        }
        
        task.resume()
    }
    
}
