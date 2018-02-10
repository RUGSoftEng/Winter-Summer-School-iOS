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

// MARK: - Structures: Lecturers

struct Lecturer {
    var id: String?
    var name: String?
    var description: String?
    var website: String?
    var imagePath: String?
    var image: UIImage?
}

extension Lecturer {
    
    // Initializer for JSON objects.
    init?(json: [String: Any]) {
        
        // Mandatory fields:
        guard
            let id: String = json["_id"] as? String,
            let name: String = json["name"] as? String,
            let description: String = json["description"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.description = description
        self.website = nil
        self.imagePath = nil
        self.image = nil
        
        // Optional fields:
        if let website: String = json["website"] as? String {
            self.website = website
        }
        
        if let imagePath: String = json["imagepath"] as? String {
            self.imagePath = imagePath
        }
    }
    
    // Initializer for NSManagedObjects.
    init?(managedObject: NSManagedObject) {
        
        // Mandatory fields:
        guard
            let id: String = managedObject.value(forKey: LecturerEntityKey.id.rawValue) as? String,
            let name: String = managedObject.value(forKey: LecturerEntityKey.name.rawValue) as? String,
            let description: String = managedObject.value(forKey: LecturerEntityKey.description.rawValue) as? String
        else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.description = description
        self.website = nil
        self.imagePath = nil
        self.image = nil
        
        // Optional fields:
        if let website: String = managedObject.value(forKey: LecturerEntityKey.website.rawValue) as? String {
            self.website = website
        }
        
        if let imagePath: String = managedObject.value(forKey: LecturerEntityKey.imagePath.rawValue) as? String {
            self.imagePath = imagePath
        }
        
        if let imageData: Data = managedObject.value(forKey: LecturerEntityKey.image.rawValue) as? Data {
            self.image = UIImage(data: imageData)
        }
    }
}

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

// MARK: - Enumerations: NSManagedObject Entity Keys

/// Entity keys for the LecturerEntity object
enum LecturerEntityKey: String {
    case entityName         = "LecturerEntity"
    case id                 = "id"
    case name               = "name"
    case description        = "lecturerDescription"
    case website            = "website"
    case imagePath          = "imagePath"
    case image              = "image"
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
    

    
    /// Attempts to deserialize and return a Lecturer array for JSON
    /// obtained from a server request.
    ///
    /// - Parameters:
    ///     - data: The JSON encoded data.
    func parseDataToLecturers(data: Data?) -> [Lecturer]? {
        if (data == nil) {
            return nil
        }
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let lecturerJSONArray: [Any] = json as? [Any]
        else {
            return nil
        }
        
        return lecturerJSONArray.map({(object: Any) -> Lecturer in
            return Lecturer(json: object as! [String: Any])!
        })
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
    
    // MARK: - Public Methods: Data Loading
    
    
    /// Attempts to load in Lecturer data using CoreData
    /// returns an array of Lecturer objects if they exist.
    /// Nil is returned on error, or if the query returns
    /// an empty set.
    func loadLecturerData() -> [Lecturer]? {
        
        if (isCoreDataAvailable == false) {
            return nil
        }
        
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: LecturerEntityKey.entityName.rawValue)
            let lecturerEntities: [NSManagedObject] = try self.context.fetch(request) as! [NSManagedObject]
            
            if (lecturerEntities.count == 0) {
                return nil
            } else {
                let lecturers: [Lecturer] = lecturerEntities.map({(object: NSManagedObject) -> Lecturer in
                    return Lecturer(managedObject: object)!
                })
                return lecturers
            }
        } catch {
            return nil
        }
    }
    
    // MARK: - Public Methods: Data Saving
    
    /// Attempts to overwrite the existing Lecturer data stored with Coredata.
    /// If no objects exist, they are created.
    ///
    /// - Parameters:
    ///     - lecturers: An array of Lecturer instances. I.E: [Lecturer]
    func saveLecturerData(lecturers: [Lecturer]) -> Void {
        
        if (isCoreDataAvailable == false) {
            return
        }
        
        do {
            
            // Extract all LecturerEntities
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: LecturerEntityKey.entityName.rawValue)
            let lecturerEntities: [NSManagedObject] = try self.context.fetch(request) as! [NSManagedObject]
            
            // Delete all LecturerEntities
            for lecturerEntity in lecturerEntities {
                let objectContext: NSManagedObjectContext = lecturerEntity.managedObjectContext!
                objectContext.delete(lecturerEntity)
            }
            
            // Create new LecturerEntities
            for lecturer in lecturers {
                let lecturerEntity: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: LecturerEntityKey.entityName.rawValue, into: self.context)
                lecturerEntity.setValue(lecturer.id, forKey: LecturerEntityKey.id.rawValue)
                lecturerEntity.setValue(lecturer.name, forKey: LecturerEntityKey.name.rawValue)
                lecturerEntity.setValue(lecturer.description, forKey: LecturerEntityKey.description.rawValue)
                
                if let website = lecturer.website {
                    lecturerEntity.setValue(website, forKey: LecturerEntityKey.website.rawValue)
                }
                
                if let imagePath = lecturer.imagePath {
                    lecturerEntity.setValue(imagePath, forKey: LecturerEntityKey.imagePath.rawValue)
                }
                
                if let image = lecturer.image {
                    let imageData: Data = UIImagePNGRepresentation(image)! as Data
                    lecturerEntity.setValue(imageData, forKey: LecturerEntityKey.image.rawValue)
                }
            }
        } catch {
            print("saveLecturerData: There was a problem when updating lecturers!")
        }
        
        saveContext()
    }
    
    // MARK: - Public Methods: CoreData Interactions
    
    /// Saves the changes to the context
    func saveContext() -> Void {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext()
    }
}
