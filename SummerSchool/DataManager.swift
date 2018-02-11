//
//  DataManager.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/11/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import CoreData
import UIKit

// MARK: - Structures: LoginCodes

struct LoginCode {
    var id: String?
    var code: String?
    var date: Date?
}

extension LoginCode {
    init?(json: [String: Any]) {
        guard
            let id: String = json["_id"] as? String,
            let code: String = json["code"] as? String,
            let dateString: String = json["date"] as? String
        else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        self.id = id
        self.code = code
        self.date = dateFormatter.date(from: dateString)
    }
}

// MARK: - Class DataManager

final class DataManager {
    
    // MARK: - Variables & Constants
    
    /// Singleton instance
    static let sharedInstance = DataManager()
    
    /// DataModel String Identifier
    let dataModelIdentifier: String = "SSDataModel"
    
    /// Boolean Flag indicating whether or not the CoreData PersistentStore is available.
    var isCoreDataAvailable: Bool = true
    
    /// The application NSManagedObjectContext
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    // MARK: - Public Methods: Data Parsing
    
    /// Attempts to retrieve a school identifier from a loginCode request response.
    func parseLoginCodeResponseData (data: Data?) -> String? {
        
        if (data == nil) {
            return nil
        }
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let jsonArray = json as? [String: Any],
            let schoolId = jsonArray["school"] as? String
        else { return nil }
        
        return schoolId
    }
    
    /// Attempts to retrieve a school name from a school info request response.
    func parseSchoolInfoResponseData (data: Data?) -> (String, String, String)? {
        
        if (data == nil) {
            return nil
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data!, options: [])  {
            print("JSON RAW = \(json)")
            if let jsonArray = json as? [String: Any] {
                print("JSON Array = \(jsonArray)")
            } else {
                print("Can't unwrap as array!")
            }
        }
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let jsonArray = json as? [Any],
            let jsonData = jsonArray[0] as? [String: Any],
            let schoolName = jsonData["name"] as? String,
            let schoolStartDateString = jsonData["startDate"] as? String,
            let schoolEndDateString = jsonData["endDate"] as? String
        else { return nil }
        
        return (schoolName, schoolStartDateString, schoolEndDateString)
    }
    
    /// Attempts to fetch and return Event data.
    func parseEventData (data: Data?) -> [RGSEventDataModel]? {
        var events: [RGSEventDataModel]? = nil
        
        if (data != nil) {
            events = RGSEventDataModel.parseDataModel(from: data!, sort: RGSEventDataModel.sort)
        }
        
        return events
    }
    
    /// Attempts to fetch and return General Information data.
    func parseGeneralInformationData (data: Data?) -> [RGSGeneralInfoDataModel]? {
        var generalInfo: [RGSGeneralInfoDataModel]? = nil
        
        if (data != nil) {
            generalInfo = RGSGeneralInfoDataModel.parseDataModel(from: data!, sort: RGSGeneralInfoDataModel.sort)
        }
        
        return generalInfo
    }
    
    /// Attempts to fetch and return Announcement data.
    func parseAnnouncementData (data: Data?) -> [RGSAnnouncementDataModel]? {
        var announcements: [RGSAnnouncementDataModel]? = nil
        
        if (data != nil) {
            announcements = RGSAnnouncementDataModel.parseDataModel(from: data!, sort: RGSAnnouncementDataModel.sort)
        }
        
        return announcements
    }
    
    /// Attempts to fetch and return Lecturer data.
    func parseLecturerData (data: Data?) -> [RGSLecturerDataModel]? {
        var lecturers: [RGSLecturerDataModel]? = nil
        
        if (data != nil) {
            lecturers = RGSLecturerDataModel.parseDataModel(from: data!, sort: RGSLecturerDataModel.sort)
        }
        
        return lecturers
    }
    
    /// Attempts to fetch and return Schedule data.
    
    /// Attempts to fetch and return ForumThread data.
    func parseForumThreadData (data: Data?) -> [RGSForumThreadDataModel]? {
        var forumThreads: [RGSForumThreadDataModel]? = nil
        
        if (data != nil) {
            forumThreads = RGSForumThreadDataModel.parseDataModel(from: data!, sort: RGSForumThreadDataModel.sort)
        }
        
        return forumThreads
    }
    
    /// Attempts to fetch and return ForumComment data.
    func parseForumCommentData (data: Data?) -> [RGSForumCommentDataModel]? {
        var forumComments: [RGSForumCommentDataModel]? = nil
        
        if (data != nil) {
            forumComments = RGSForumCommentDataModel.parseDataModel(from: data!, sort: RGSForumCommentDataModel.sort)
        }
        
        return forumComments
    }
    
    /// Attempts to deserialize and return a LoginCode array for JSON
    /// obtained from a server request.
    ///
    /// - Parameters:
    ///     - data: The JSON encoded data.
    func parseDataToLoginCodes(data: Data?) -> [LoginCode]? {
        if (data == nil) {
            return nil
        }
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let loginCodeJSONArray: [Any] = json as? [Any]
        else {
            return nil
        }
        
        return loginCodeJSONArray.map({(object: Any) -> LoginCode in
            return LoginCode(json: object as! [String: Any])!
        })
    }
    
    // MARK: - Public Methods: CoreData Interactions
    
    /// Saves the changes to the context
    func saveContext() -> Void {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
    }
}
