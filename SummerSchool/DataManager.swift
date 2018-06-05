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
    
    /// The application configuration dictionary.
    private var applicationConfiguration: [String: [String: String]]?
    
    // MARK: - Private Methods: Application Configuration.
    
    /// Attempts to read in the application configurations.
    private func initializeAppConfig () -> Bool {
        var fileURL: URL?
        
        // If the file cannot be located. Fail.
        if let url = Bundle.main.url(forResource: "applicationConfig", withExtension: "plist") {
            fileURL = url
        } else {
            print("DataManager: Fatal Error: Can't load the application configuration!")
            return false
        }
        
        // If the file cannot be opened. Fail.
        if let applicationConfiguration = NSDictionary(contentsOf: fileURL!) as? [String: [String: String]] {
            self.applicationConfiguration = applicationConfiguration
            return true
        }
        
        print("DataManager: Fatal error: Couldn't load from the plist, but the file exists!")
        return false
    }
    
    // MARK: - Public Methods: Application Configuration.
    
    /// Returns a hashmap/dictionary for the given masterkey.
    /// - masterKey: The key to the hashmap/dictionary. The applicationConfig must be initialized.
    ///              and an entry must exist.
    func getKeyMap (for masterKey: String) -> [String: String] {
        return applicationConfiguration![masterKey]!
    }
    
    // MARK: - Public Methods: Data Parsing
    
    /// Attempts to retrieve a school identifier from a loginCode request response.
    func parseLoginCodeResponseData (data: Data?) -> String? {
        
        if (data == nil) {
            return nil
        }
        
        let keys: [String: String] = getKeyMap(for: "loginKeys")
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let jsonArray = json as? [String: Any],
            let schoolId = jsonArray[keys["schoolId"]!] as? String
        else { return nil }
        
        return schoolId
    }
    
    /// Attempts to retrieve a school name from a school info request response.
    func parseSchoolInfoResponseData (data: Data?) -> (String, String, String)? {
        
        if (data == nil) {
            return nil
        }
        
        let keys: [String: String] = getKeyMap(for: "schoolKeys")
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let jsonArray = json as? [Any],
            jsonArray.count >= 1,
            let jsonData = jsonArray[0] as? [String: Any],
            let schoolName = jsonData[keys["schoolName"]!] as? String,
            let schoolStartDateString = jsonData[keys["startDateString"]!] as? String,
            let schoolEndDateString = jsonData[keys["endDateString"]!] as? String
        else { print("Failed to get schoolInfo!"); return nil }
        
        return (schoolName, schoolStartDateString, schoolEndDateString)
    }
    
    /// Attempts to fetch and return Event data.
    func parseEventData (data: Data?) -> [RGSEventDataModel]? {
        var events: [RGSEventDataModel]? = nil
        
        if (data != nil) {
            events = RGSEventDataModel.parseDataModel(from: data!, with: getKeyMap(for: "eventKeys"), sort: RGSEventDataModel.sort)
        }
        
        return events
    }
    
    /// Attempts to fetch and return General Information data.
    func parseGeneralInformationData (data: Data?) -> [RGSGeneralInfoDataModel]? {
        var generalInfo: [RGSGeneralInfoDataModel]? = nil
        
        if (data != nil) {
            generalInfo = RGSGeneralInfoDataModel.parseDataModel(from: data!, with: getKeyMap(for: "generalInfoKeys"), sort: RGSGeneralInfoDataModel.sort)
        }
        
        return generalInfo
    }
    
    /// Attempts to fetch and return Announcement data.
    func parseAnnouncementData (data: Data?) -> [RGSAnnouncementDataModel]? {
        var announcements: [RGSAnnouncementDataModel]? = nil
        
        if (data != nil) {
            announcements = RGSAnnouncementDataModel.parseDataModel(from: data!, with: getKeyMap(for: "announcementKeys"), sort: RGSAnnouncementDataModel.sort)
        }
        
        return announcements
    }
    
    /// Attempts to fetch and return Lecturer data.
    func parseLecturerData (data: Data?) -> [RGSLecturerDataModel]? {
        var lecturers: [RGSLecturerDataModel]? = nil
        
        if (data != nil) {
            lecturers = RGSLecturerDataModel.parseDataModel(from: data!, with: getKeyMap(for: "lecturerKeys"), sort: RGSLecturerDataModel.sort)
        }
        
        return lecturers
    }
    
    /// Attempts to fetch and return Schedule data.
    
    /// Attempts to fetch and return ForumThread data.
    func parseForumThreadData (data: Data?) -> [RGSForumThreadDataModel]? {
        var forumThreads: [RGSForumThreadDataModel]? = nil
        
        if (data != nil) {
            forumThreads = RGSForumThreadDataModel.parseDataModel(from: data!, with: getKeyMap(for: "forumThreadKeys"), sort: RGSForumThreadDataModel.sort)
        }
        
        return forumThreads
    }
    
    /// Attempts to fetch and return ForumComment data.
    func parseForumCommentData (data: Data?) -> [RGSForumCommentDataModel]? {
        var forumComments: [RGSForumCommentDataModel]? = nil
        
        if (data != nil) {
            forumComments = RGSForumCommentDataModel.parseDataModel(from: data!, with: getKeyMap(for: "forumCommentKeys"), sort: RGSForumCommentDataModel.sort)
        }
        
        return forumComments
    }
    
    // MARK: - Public Methods: CoreData Interactions
    
    /// Saves the changes to the context
    func saveContext() -> Void {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
    }
    
    // MARK: - Class Method Overrides
    
    required init() {
        
        
        // Load Application Configuration.
        if (!initializeAppConfig()) {
            print("DataManager: An error occurred when loading the application configuration!")
        }
    }
}
