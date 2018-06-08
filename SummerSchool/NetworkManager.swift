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
    case generalInfoPath = "/API/generalinfo"
    case announcementPath = "/API/announcement"
    case eventPath = "/API/event"
    case loginCodePath = "/API/loginCode"
    case schoolInfoPath = "/API/school"
    case lecturerPath = "/API/lecturer"
    case forumPath = "/API/forum/thread"
    case forumComment = "/API/forum/comment"
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
                serverPath += option + (i + 1 >= options.count ? "" : "&")
            }
        }
        return serverPath
    }
    
    // MARK: - Public Methods
    
    /// Returns a URL appended with the given parameters.
    /// - options: The optional parameters to include.
    func URLWithOptions(url: String, options: String...) -> String {
        var newURL = url
        
        if (options.count > 0) {
            newURL += "?"
            for (i, option) in options.enumerated() {
                newURL += option + (i + 1 >= options.count ? "" : "&")
            }
        }
        
        return newURL;
    }
    
    /// Constructs a query string with the given dictionary.
    func queryStringFromHashMap (map: [String: String]) -> String {
        var queryString = ""
        
        for (i, key) in map.keys.enumerated() {
            queryString += key + "=" + map[key]!
            if (i < map.keys.count - 1) {
                queryString += "&"
            }
        }
        
        return queryString.replacingOccurrences(of: " ", with: "+")
    }
    
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
    
    /// Returns the address needed to verify a login code
    /// from the server.
    func URLForLoginCode(_ loginCode: String) -> String {
        return serverAddress + serverPathWithOptions(path: .loginCodePath, options: "code=\(loginCode)")
    }
    
    /// Returns the address needed to extract school information
    /// from the server.
    func URLForSchoolInfo (_ schoolId: String) -> String {
        return serverAddress + serverPathWithOptions(path: .schoolInfoPath, options: "_id=\(schoolId)")
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
    
    /// Returns the address needed to extract comment postings
    /// from the server.
    func URLForForumComments() -> String {
        return serverAddress + ServerPath.forumComment.rawValue
    }
    
    /// Returns a concatenated address needed to extract the
    /// resource from the server.
    func URLForResourceWithPath (_ path: String) -> String {
        return serverAddress + path
    }
    
    /// Returns the address needed to extract events for the specified week
    /// from the server.
    ///
    /// - Parameters:
    ///     - offset: The offset from the current week from which to
    ///               extract events. -1 = last week, 2 = next next week.
    func URLForEventsByWeek (offset: Int) -> String {
        return serverAddress + serverPathWithOptions(path: .eventPath, options: "week=\(offset)")
    }
    
    /// Performs a GET request to the given URL, executes a callback with the retrieved
    /// data. The results may be nil.
    ///
    /// - Parameters:
    ///     - url: A String describing the resource to aim the request at.
    ///     - onCompletion: A closure to execute upon completion.
    func makeGetRequest (url: String, onCompletion: @escaping (_: Data?, _: URLResponse?) -> Void) -> Void {
        
        // Construct Request
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let session: URLSession = URLSession.shared
        
        // Start Network Activity Indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        
        
        let task = session.dataTask(with: request) {data, response, err in
            
            // Stop Network Activity Indicator
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            // Update network status. Assumes all requests require a data response.
            self.hasNetworkConnection = (data != nil)
            
            // Execute callback
            onCompletion(data, response)
        }
        
        task.resume()
    }
    
    /// Performs a synchronous GET request to the given URL. Executes a callback with the
    /// retreived data. The results may be nil.
    ///
    /// - Parameters:
    ///     - url: A string describing the resource to aim the request at.
    ///     - onCompletion: A closure to execute upon completion.
    func makeSynchronousGetRequest (url: String) -> (Data?, URLResponse?) {
        
        // Construct Request.
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        let session: URLSession = URLSession.shared
        
        // Start Network Activity Indicator.
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        // Perform sychronous request.
        let (data, response, _) = session.synchronousDataTask(with: URL(string:url)!)
        
        // Stop Network Activity Indicator
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        
        // Update network status. Assumes all requests require a data response.
        DispatchQueue.main.async {
            self.hasNetworkConnection = (data != nil)
        }
        
        // Return results of synchronous request.
        return (data, response)
    }
    
    /// Performs a POST request to the given URL, executes a callback with the response
    /// from the server.
    ///
    /// - Parameters:
    ///     - url: A String describing the resource to aim the request at.
    ///     - data: The request body.
    ///     - onCompletion: A closure to execute on completion.
    func makePostRequest (url: String, data: Data?, onCompletion: @escaping (_: Data?, _: URLResponse?) -> Void) -> Void {
        
        // Construct request.
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let session: URLSession = URLSession.shared
        
        // Start Network Activity Indicator.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let task = session.dataTask(with: request) {data, response, err in
            
            // Stop Network Activity Indicator
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            // Execute callback
            onCompletion(data, response)
        }
        
        task.resume()
    }
    
    /// Performs a DELETE request to the given URL, executes a callback with the response
    /// from the server.
    ///
    /// - Parameters:
    ///     - url: A String describing the resource to aim the request at.
    ///     - onCompletion: A closure to execute on completion.
    func makeDeleteRequest (url: String, onCompletion: @escaping (_: Data?, _: URLResponse?) -> Void) -> Void {
        
        // Construct request.
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = "DELETE"
        
        let session: URLSession = URLSession.shared
        
        // Start Network Activity Indicator.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let task = session.dataTask(with: request) {data, response, err in
            
            // Stop Network Activity Indicator
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
            // Execute callback
            onCompletion(data, response)
        }
        
        task.resume()
    }
    
}
