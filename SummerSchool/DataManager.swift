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

// MARK: - Structures: Event, EventPacket

/// Structure representing an event.
struct Event {
    var id: String?
    var title: String?
    var address: String?
    var description: String?
    var ssid: String?
    var startDate: Date?
    var endDate: Date?
}

/// Extension with initializer for Event.
extension Event {
    
    // Initializer for JSON objects.
    init?(json: [String: Any]) {
        
        // Mandatory fields: Return nil if missing.
        guard
            let id: String = json["id"] as? String,
            let title: String = json["summary"] as? String,
            let address: String = json["location"] as? String,
            let description: String = json["description"] as? String,
            let start: [String: String] = json["start"] as? [String: String],
            let end: [String: String] = json["end"] as? [String: String]
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.address = address
        self.description = description
        self.startDate = DateManager.sharedInstance.ISOStringToDate(start["dateTime"], format: DateFormat.JSONScheduleEventDateFormat)
        self.endDate = DateManager.sharedInstance.ISOStringToDate(end["dateTime"], format: DateFormat.JSONScheduleEventDateFormat)
        self.ssid = "Unavailable"
        
        // Initialize custom field. Return placeholder if unavailable.
        guard
            let extendedProperties: [String: Any] = json["extendedProperties"] as? [String: Any],
            let shared: [String: String] = extendedProperties["shared"] as? [String: String]
            else {
                return
        }
        
        self.ssid = shared["ssid"]
    }
    
    // Initializer for NSManagedObject objects
    init?(managedObject: NSManagedObject) {
        
        // Mandatory fields: Return nil if missing.
        guard
            let title: String = managedObject.value(forKey: EventEntityKey.title.rawValue) as? String,
            let address: String = managedObject.value(forKey: EventEntityKey.address.rawValue) as? String,
            let description: String = managedObject.value(forKey: EventEntityKey.description.rawValue) as? String,
            let startDateString: String = managedObject.value(forKey: EventEntityKey.startDateString.rawValue) as? String,
            let endDateString: String = managedObject.value(forKey: EventEntityKey.endDateString.rawValue) as? String,
            let ssid: String = managedObject.value(forKey: EventEntityKey.ssid.rawValue) as? String
        else {
            return nil
        }
        
        self.title = title
        self.address = address
        self.description = description
        self.startDate = DateManager.sharedInstance.ISOStringToDate(startDateString, format: DateFormat.JSONScheduleEventDateFormat)
        self.endDate = DateManager.sharedInstance.ISOStringToDate(endDateString, format: DateFormat.JSONScheduleEventDateFormat)
        self.ssid = ssid
        
        // Optional fields:
    }
}

/// Structure representing an event packet received from the server.
struct EventPacket {
    var events: [(Date, [Event])]?
}

/// Extension with initializer for EventPacket.
extension EventPacket {
    
    // Initializer for JSON objects.
    init?(json: [[Any]]) {
        
        var events: [(Date, [Event])] = [(Date, [Event])]()
        
        for item in json {
            var parsedEvents: [Event] = [Event]()
            guard
                let dateString: String = item[0] as? String,
                let dateEvents: [Any] = item[1] as? [Any]
                else {
                    return nil
            }
            
            for serializedEvent in dateEvents {
                if let event = Event.init(json: serializedEvent as! [String : Any]) {
                    parsedEvents.append(event)
                } else {
                    return nil
                }
            }
            let date: Date? = DateManager.sharedInstance.ISOStringToDate(dateString, format: DateFormat.JSONGeneralDateFormat)
            events.append((date!, parsedEvents))
        }
        
        self.events = events
    }
    
    // Initializer for NSManagedObjects. Expects an array of WeekDayEntities represented as NSManagedObjects
    // Note: Do not call this method if isCoreDataAvailable is set to false.
    init?(managedObjects: [NSManagedObject]) {
        var events: [(Date, [Event])] = []
        
        if (managedObjects.count != 7) {
            return nil
        }
        
        for weekDayEntity in managedObjects {
            
            // Initialize the dateString, and events of that week day. Return nil if any corruption is present.
            guard
                let dateString: String = weekDayEntity.value(forKey: WeekDayEntityKey.dateString.rawValue) as? String,
                let date: Date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
            else {
                return nil
            }
            
            // Extract dateEvents, sort them by starting date
            let dateEventEntities: NSMutableSet = weekDayEntity.mutableSetValue(forKey: WeekDayEntityKey.events.rawValue)
            let dateEvents: [Event] = dateEventEntities.map({(eventEntity) -> Event in
                return Event(managedObject: eventEntity as! NSManagedObject)!
            }).sorted(by: {(a: Event, b: Event) -> Bool in
                return a.startDate! < b.startDate!
            })
            
            // Add tuple to events list.
            events.append((date, dateEvents))
        }
        
        // Sort events by ascending date (may not be in order)
        self.events = events.sorted(by: {$0.0 < $1.0})
    }
}


// MARK: - Structures: Announcement

struct Announcement {
    var id: String?
    var title: String?
    var description: String?
    var poster: String?
    var date: Date?
}

extension Announcement {
    
    // Initializer for JSON objects.
    init?(json: [String: Any]) {
        
        // Mandatory fields:
        guard
            let id: String = json["_id"] as? String,
            let title: String = json["title"] as? String,
            let description: String = json["description"] as? String,
            let poster: String = json["poster"] as? String,
            let dateString: String = json["date"] as? String
            else {
                return nil
        }
        
        self.id = id
        self.title = title
        self.description = description
        self.poster = poster
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields:
    }
    
    // Initializer for NSManagedObjects.
    init?(managedObject: NSManagedObject) {
        
        // Mandatory fields:
        guard
            let title: String = managedObject.value(forKey: AnnouncementEntityKey.title.rawValue) as? String,
            let description: String = managedObject.value(forKey: AnnouncementEntityKey.description.rawValue) as? String,
            let poster: String = managedObject.value(forKey: AnnouncementEntityKey.poster.rawValue) as? String,
            let dateString: String = managedObject.value(forKey: AnnouncementEntityKey.dateString.rawValue) as? String,
            let id: String = managedObject.value(forKey: AnnouncementEntityKey.id.rawValue) as? String
        else {
            return nil
        }
        
        self.title = title
        self.description = description
        self.poster = poster
        self.id = id
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields:
    }
}

// MARK: - Structures: GeneralInfo

enum InfoCategory: Int {
    case Food = 0, Location, Internet, Accomodation, Information
}

struct GeneralInfo {
    var id: String?
    var title: String?
    var description: String?
    var category: InfoCategory?
    var date: Date?
}

extension GeneralInfo {
    
    // Initializer for JSON objects.
    init?(json: [String: Any]) {
        guard
            let id: String = json["_id"] as? String,
            let title: String = json["title"] as? String,
            let description: String = json["description"] as? String,
            let categoryString: String = json["category"] as? String,
            let dateString: String = json["date"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.description = description
        self.category = InfoCategory(rawValue: Int(categoryString)!)
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
    }
    
    // Initializer for NSManagedObjects.
    init?(managedObject: NSManagedObject) {
        
        // Mandatory fields:
        guard
            let id: String = managedObject.value(forKey: GeneralInfoEntityKey.id.rawValue) as? String,
            let title: String = managedObject.value(forKey: GeneralInfoEntityKey.title.rawValue) as? String,
            let description: String = managedObject.value(forKey: GeneralInfoEntityKey.description.rawValue) as? String,
            let categoryInt: Int = managedObject.value(forKey: GeneralInfoEntityKey.category.rawValue) as? Int,
            let dateString: String = managedObject.value(forKey: GeneralInfoEntityKey.dateString.rawValue) as? String
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.description = description
        self.category = InfoCategory(rawValue: categoryInt)
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields:
    }
    
    // Todo: Update the enum for the keys, update the load and save data, update the entity in database.
}

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

// MARK: - Structures: ForumThread

struct ForumThread {
    var id: String?
    var title: String?
    var author: String?
    var authorID: String?
    var date: Date?
    var body: String?
    var imagePath: String?
    var comments: [ForumComment]?
}

extension ForumThread {
    
    // Initializer for JSON objects.
    init?(json: [String: Any]) {
        
        // Mandatory fields:
        guard
            let id: String = json["_id"] as? String,
            let title: String = json["title"] as? String,
            let author: String = json["author"] as? String,
            let authorID: String = json["posterID"] as? String,
            let dateString: String = json["date"] as? String
        else {
            return nil
        }
        self.id = id
        self.title = title
        self.author = author
        self.authorID = authorID
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields:
        if let body: String = json["description"] as? String {
            self.body = body
        }
        
        if let imagePath: String = json["imgurl"] as? String {
            self.imagePath = imagePath
        }
        
        // Initialize Comments:
        if let commentArray = json["comments"] as? [Any] {
            self.comments = commentArray.map({(forumComment: Any) -> ForumComment in
                return ForumComment(json: forumComment as! [String: Any])!
            });
            
            // Sort them by descending date.
            self.comments = self.comments?.sorted(by: {(a: ForumComment, b: ForumComment) -> Bool in
                return (a.date! > b.date!)
            })
        }
    }
    
    // Initializer for NSManagedObjects.
    init?(managedObject: NSManagedObject) {
        
        // Mandatory fields:
        guard
            let id = managedObject.value(forKey: ForumThreadEntityKey.id.rawValue) as? String,
            let title = managedObject.value(forKey: ForumThreadEntityKey.title.rawValue) as? String,
            let author = managedObject.value(forKey: ForumThreadEntityKey.author.rawValue) as? String,
            let authorID = managedObject.value(forKey: ForumThreadEntityKey.authorID.rawValue) as? String,
            let dateString = managedObject.value(forKey: ForumThreadEntityKey.dateString.rawValue) as? String
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.author = author
        self.authorID = authorID
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields:
        if let imagePath = managedObject.value(forKey: ForumThreadEntityKey.imagePath.rawValue) as? String {
            self.imagePath = imagePath
        }
        
        if let body = managedObject.value(forKey: ForumThreadEntityKey.body.rawValue) as? String {
            self.body = body
        }
        
        // Initialize Comments.
        let forumCommentEntities: NSMutableSet = managedObject.mutableSetValue(forKey: ForumThreadEntityKey.comments.rawValue)
        let forumComments: [ForumComment] = forumCommentEntities.map({(forumCommentEntity) -> ForumComment in
            return ForumComment(managedObject: forumCommentEntity as! NSManagedObject)!
        }).sorted(by: {(a: ForumComment, b: ForumComment) -> Bool in
            return a.date! > b.date!
        })
        self.comments = forumComments;
    }
}

// MARK: - Structures: ForumComment

// Todo:
// 1: Implement the ForumComment hierarchy in CoreData.
// 2: Finish proper loading of comments for forumThread.
// 3: Refactor this huge fucking file.
// 4: Add a comment view for the forum.
// 5: Fix bug where refresh doesn't do anything on forum.

struct ForumComment {
    var id: String?
    var author: String?
    var authorID: String?
    var body: String?
    var date: Date?
    var imagePath: String?
}

extension ForumComment {
    
    // Initializer for JSON objects.
    init?(json: [String: Any]) {
        
        // Mandatory fields:
        guard
            let id: String = json["commentID"] as? String,
            let author: String = json["author"] as? String,
            let authorID: String = json["posterID"] as? String,
            let body: String = json["text"] as? String,
            let dateString: String = json["date"] as? String
            else {
                return nil
        }
        self.id = id
        self.author = author
        self.authorID = authorID
        self.body = body
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields:
        if let imagePath: String = json["imgurl"] as? String {
            self.imagePath = imagePath
        }
    }
    
    // Initializer for NSManagedObjects.
    init?(managedObject: NSManagedObject) {
        
        // Mandatory fields:
        guard
            let id = managedObject.value(forKey: ForumCommentEntityKey.id.rawValue) as? String,
            let author = managedObject.value(forKey: ForumCommentEntityKey.author.rawValue) as? String,
            let authorID = managedObject.value(forKey: ForumCommentEntityKey.authorID.rawValue) as? String,
            let body = managedObject.value(forKey: ForumCommentEntityKey.body.rawValue) as? String,
            let dateString = managedObject.value(forKey: ForumCommentEntityKey.dateString.rawValue) as? String
            else {
                return nil
        }
        
        self.id = id
        self.author = author
        self.authorID = authorID
        self.body = body
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields:
        if let imagePath = managedObject.value(forKey: ForumCommentEntityKey.imagePath.rawValue) as? String {
            self.imagePath = imagePath
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

/// Entity Keys for the EventEntity object
enum EventEntityKey: String {
    case entityName         = "EventEntity"
    case title              = "title"
    case address            = "address"
    case description        = "eventDescription"
    case startDateString    = "startDateString"
    case endDateString      = "endDateString"
    case ssid               = "ssid"
    case weekDay            = "weekDay"
}

/// Entity keys for the WeekDayEntity object
enum WeekDayEntityKey: String {
    case entityName         = "WeekDayEntity"
    case dateString         = "dateString"
    case events             = "events"
}

/// Entity keys for the AnnouncementEntity object
enum AnnouncementEntityKey: String {
    case entityName         = "AnnouncementEntity"
    case title              = "title"
    case description        = "announcementDescription"
    case poster             = "poster"
    case dateString         = "dateString"
    case id                 = "id"
}

/// Entity keys for the GeneralInfoEntity object
enum GeneralInfoEntityKey: String {
    case entityName         = "GeneralInfoEntity"
    case id                 = "id"
    case title              = "title"
    case description        = "generalInfoDescription"
    case category           = "category"
    case dateString         = "dateString"
}

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

/// Entity keys for the ForumThreadEntity object
enum ForumThreadEntityKey: String {
    case entityName         = "ForumThreadEntity"
    case id                 = "id"
    case title              = "title"
    case body               = "body"
    case author             = "author"
    case authorID           = "authorID"
    case dateString         = "dateString"
    case imagePath          = "imagePath"
    case comments           = "comments"
}

/// Entity keys for the ForumCommentEntity object
enum ForumCommentEntityKey: String {
    case entityName         = "ForumCommentEntity"
    case id                 = "id"
    case body               = "body"
    case author             = "author"
    case authorID           = "authorID"
    case dateString         = "dateString"
    case imagePath          = "imagePath"
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
    
    /// Attempts to deserialize and return an EventPacket object for JSON
    /// obtained from a server request.
    ///
    /// - Parameters:
    ///     - data: The JSON encoded data.
    func parseDataToEventPacket(data: Data?) -> EventPacket? {
        if (data == nil) {
            return nil
        }
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let dictionary: [String: Any] = json as? [String: Any],
            let eventString: String = dictionary["data"] as? String,
            let eventData: Data = eventString.data(using: String.Encoding.utf8),
            let eventjson = try? JSONSerialization.jsonObject(with: eventData, options: []),
            let eventPacket: EventPacket = EventPacket.init(json: eventjson as! [[Any]])
            else {
                return nil
        }
        
        return eventPacket
    }
    
    /// Attempts to deserialize and return an Announcements array for JSON
    /// obtained from a server request.
    ///
    /// - Parameters:
    ///     - data: The JSON encoded data.
    func parseDataToAnnouncements(data: Data?) -> [Announcement]? {
        if (data == nil) {
            return nil
        }
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let announcementJSONArray: [Any] = json as? [Any]
        else {
            return nil
        }
        
        return announcementJSONArray.map({(object: Any) -> Announcement in
            return Announcement(json: object as! [String: Any])!
        })
    }
    
    /// Attempts to deserialize and return a GeneralInfo array for JSON
    /// obtained from a server request.
    ///
    /// - Parameters:
    ///     - data: The JSON encoded data.
    func parseDataToGeneralInfo(data: Data?) -> [GeneralInfo]? {
        if (data == nil) {
            return nil
        }
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let generalInfoJSONArray: [Any] = json as? [Any]
        else {
            return nil
        }
        
        return generalInfoJSONArray.map({(object: Any) -> GeneralInfo in
            return GeneralInfo(json: object as! [String: Any])!
        })
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
    
    /// Attempts to deserialize and return a ForumThread array for JSON
    /// obtained from a server request.
    ///
    /// - Parameters:
    ///     - data: The JSON encoded data.
    func parseDataToForumThreads(data: Data?) -> [ForumThread]? {
        if (data == nil) {
            return nil
        }
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let forumThreadJSONArray: [Any] = json as? [Any]
        else {
            return nil
        }
        
        return forumThreadJSONArray.map({(object: Any) -> ForumThread in
            return ForumThread(json: object as! [String: Any])!
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
    
    /// Attempts to load in the Announcement data using CoreData
    /// returns an array of Announcement objects if they exist. 
    /// Nil is returned on error, or if the query returns an
    /// empty set.
    func loadAnnouncementData() -> [Announcement]? {
        
        if (isCoreDataAvailable == false) {
            return nil
        }
        
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: AnnouncementEntityKey.entityName.rawValue)
            let announcementEntities: [NSManagedObject] = try self.context.fetch(request) as! [NSManagedObject]
            
            if (announcementEntities.count == 0) {
                return nil
            } else {
                let announcements: [Announcement] = announcementEntities.map({(announcementEntity: NSManagedObject) -> Announcement in
                    return Announcement(managedObject: announcementEntity)!
                })
                return announcements
            }
        } catch {
            return nil
        }
    }
    
    /// Attempts to load in Schedule data using CoreData
    /// returns an EventPacket if one exists. Returns nil on
    /// error or if the query returns an empty set.
    func loadScheduleData() -> EventPacket? {
        
        if (isCoreDataAvailable == false) {
            return nil
        }

        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: WeekDayEntityKey.entityName.rawValue)
            let weekDayEntities: [NSManagedObject] = try self.context.fetch(request) as! [NSManagedObject]
            return EventPacket(managedObjects: weekDayEntities)
        } catch {
            return nil
        }
    }
    
    /// Attempts to load in GeneralInfo data using CoreData
    /// returns an array of GeneralInfo objects if they exist.
    /// Nil is returned on error, or if the query returns an
    /// empty set.
    func loadGeneralInfoData() -> [GeneralInfo]? {
        
        if (isCoreDataAvailable == false) {
            return nil
        }
        
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: GeneralInfoEntityKey.entityName.rawValue)
            let generalInfoEntities: [NSManagedObject] = try self.context.fetch(request) as! [NSManagedObject]
            
            if (generalInfoEntities.count == 0) {
                return nil
            } else {
                let generalInfo: [GeneralInfo] = generalInfoEntities.map({(object: NSManagedObject) -> GeneralInfo in
                    return GeneralInfo(managedObject: object)!
                })
                return generalInfo
            }
        } catch {
            return nil
        }
    }
    
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
    
    /// Attempts to load in ForumThread data using CoreData.
    /// Returns an array of ForumThread objects if they exist.
    /// Nil is returned on error, or if the query returns an
    /// empty set.
    func loadForumThreadData() -> [ForumThread]? {
        
        if (isCoreDataAvailable == false) {
            return nil
        }
        
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: ForumThreadEntityKey.entityName.rawValue)
            let forumThreadEntities: [NSManagedObject] = try self.context.fetch(request) as! [NSManagedObject]
            
            if (forumThreadEntities.count == 0) {
                return nil
            } else {
                let forumThreads: [ForumThread] = forumThreadEntities.map({(object: NSManagedObject) -> ForumThread in
                    return ForumThread(managedObject: object)!
                })
                return forumThreads
            }
        } catch {
            return nil
        }
    }
    
    // MARK: - Public Methods: Data Saving
    
    /// Attempts to overwrite the existing Announcement data stored with CoreData.
    /// If no objects exist, they are created.
    ///
    /// - Parameters:
    ///     - announcements: An array of announcement instances. I.E: [Announcement]
    func saveAnnouncementData(announcements: [Announcement]) -> Void {
        
        if (isCoreDataAvailable == false) {
            return
        }
        
        do {
            
            // Extract all AnnouncementEntities
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: AnnouncementEntityKey.entityName.rawValue)
            let announcementEntities: [NSManagedObject] = try self.context.fetch(request) as! [NSManagedObject]
            
            // Delete all AnnouncementEntities
            for announcementEntity in announcementEntities {
                let objectContext: NSManagedObjectContext = announcementEntity.managedObjectContext!
                objectContext.delete(announcementEntity)
            }
            
            // Create new AnnouncementEntities
            for announcement in announcements {
                let announcementEntity: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: AnnouncementEntityKey.entityName.rawValue, into: self.context) as NSManagedObject
                announcementEntity.setValue(announcement.title, forKey: AnnouncementEntityKey.title.rawValue)
                announcementEntity.setValue(announcement.description, forKey: AnnouncementEntityKey.description.rawValue)
                announcementEntity.setValue(announcement.poster, forKey: AnnouncementEntityKey.poster.rawValue)
                let dateString: String = DateManager.sharedInstance.dateToISOString(announcement.date, format: .JSONGeneralDateFormat)!
                announcementEntity.setValue(dateString, forKey: AnnouncementEntityKey.dateString.rawValue)
                announcementEntity.setValue(announcement.id, forKey: AnnouncementEntityKey.id.rawValue)
            }
        } catch {
            print("saveAnnouncementData: There was a problem when updating announcements!")
            return
        }
        
        saveContext()
    }
    
    /// Attempts to overwrite the existing Schedule data stored with CoreData.
    /// If the objects do not exist, they are created.
    ///
    /// - Parameters:
    ///     - events: An array of (Date, [Event]) tuples.
    func saveScheduleData(events: [(Date,[Event])]) -> Void {
        
        if (isCoreDataAvailable == false) {
            return
        }
        
        do {
            
            // Extract all WeekDayEntities
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: WeekDayEntityKey.entityName.rawValue)
            var weekDayEntities: [NSManagedObject] = try self.context.fetch(request) as! [NSManagedObject]
            
            // For all WeekDayEntities...
            for weekDayEntity in weekDayEntities {
                let weekDayEntityEvents: NSMutableSet = weekDayEntity.mutableSetValue(forKey: WeekDayEntityKey.events.rawValue)
                
                // Remove all Events from the Context
                for eventEntity in weekDayEntityEvents {
                    let objectContext: NSManagedObjectContext = (eventEntity as AnyObject).managedObjectContext
                    objectContext.delete(eventEntity as! NSManagedObject)
                }
            }
            
            // If there were no WeekDayEntities, create them.
            if (weekDayEntities.count == 0) {
                for _ in 0 ..< 7 {
                    let weekDayEntity: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: WeekDayEntityKey.entityName.rawValue, into: self.context) as NSManagedObject
                    weekDayEntities.append(weekDayEntity)
                }
            }
            
            //  Update dates and set new EventEntities.
            for (index, weekDayEntity) in weekDayEntities.enumerated() {
                let (date, events) = events[index]
                
                // Update WeekDayEntity Date
                let dateString: String = DateManager.sharedInstance.dateToISOString(date, format: DateFormat.JSONGeneralDateFormat)!
                weekDayEntity.setValue(dateString, forKey: WeekDayEntityKey.dateString.rawValue)
                
                // Get WeekDayEntity Events Set (should be empty)
                let weekDayEntityEvents: NSMutableSet = weekDayEntity.mutableSetValue(forKey: WeekDayEntityKey.events.rawValue)
                
                for event in events {
                    let eventEntity: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: EventEntityKey.entityName.rawValue, into: self.context)
                    eventEntity.setValue(event.title, forKey: EventEntityKey.title.rawValue)
                    eventEntity.setValue(event.address, forKey: EventEntityKey.address.rawValue)
                    eventEntity.setValue(event.description, forKey: EventEntityKey.description.rawValue)
                    eventEntity.setValue(event.ssid, forKey: EventEntityKey.ssid.rawValue)
                    eventEntity.setValue(DateManager.sharedInstance.dateToISOString(event.startDate!, format: .JSONScheduleEventDateFormat), forKey: EventEntityKey.startDateString.rawValue)
                    eventEntity.setValue(DateManager.sharedInstance.dateToISOString(event.endDate!, format: .JSONScheduleEventDateFormat), forKey: EventEntityKey.endDateString.rawValue)
                    eventEntity.setValue(weekDayEntity, forKey: EventEntityKey.weekDay.rawValue)
                    
                    weekDayEntityEvents.add(eventEntity)
                }
            }
            
        } catch {
            print("saveScheduleData: There was a problem when updating events!")
            return
        }
        
        saveContext()
    }
    
    /// Attempts to overwrite the existing GeneralInfo data stored with CoreData.
    /// If no objects exist, they are created.
    ///
    /// - Parameters:
    ///     - generalInfo: An array of GeneralInfo instances. I.E: [GeneralInfo]
    func saveGeneralInfoData(generalInfo: [GeneralInfo]) -> Void {
        
        if (isCoreDataAvailable == false) {
            return
        }
        
        do {
            
            // Extract all GeneralInfoEntities
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: GeneralInfoEntityKey.entityName.rawValue)
            let generalInfoEntities: [NSManagedObject] = try self.context.fetch(request) as! [NSManagedObject]
            
            // Delete all GeneralInfoEntities
            for generalInfoEntity in generalInfoEntities {
                let objectContext: NSManagedObjectContext = generalInfoEntity.managedObjectContext!
                objectContext.delete(generalInfoEntity)
            }
            
            // Create new GeneralInfoEntities
            for generalInfoItem in generalInfo {
                let generalInfoEntity: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: GeneralInfoEntityKey.entityName.rawValue, into: self.context) as NSManagedObject
                generalInfoEntity.setValue(generalInfoItem.id, forKey: GeneralInfoEntityKey.id.rawValue)
                generalInfoEntity.setValue(generalInfoItem.title, forKey: GeneralInfoEntityKey.title.rawValue)
                generalInfoEntity.setValue(generalInfoItem.description, forKey: GeneralInfoEntityKey.description.rawValue)
                generalInfoEntity.setValue(generalInfoItem.category!.rawValue, forKey: GeneralInfoEntityKey.category.rawValue)
                generalInfoEntity.setValue(DateManager.sharedInstance.dateToISOString(generalInfoItem.date, format: .JSONGeneralDateFormat), forKey: GeneralInfoEntityKey.dateString.rawValue)
            }
        } catch {
            print("saveGeneralInfoData: There was a problem when updating generalInfo!")
        }
        
        saveContext()
    }
    
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
    
    /// Attempts to overwrite the existing ForumThread data stored with Coredata.
    /// If no objects exist, they are created.
    ///
    /// - Parameters:
    ///     - forumThreads: An array of ForumThread instances. I.E: [ForumThread]
    func saveForumThreadData(forumThreads: [ForumThread]) -> Void {
        
        if (isCoreDataAvailable == false) {
            return
        }
        
        do {
            
            // Extract all forumThreadEntities
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: ForumThreadEntityKey.entityName.rawValue)
            let forumThreadEntities: [NSManagedObject] = try self.context.fetch(request) as! [NSManagedObject]
            
            // Remove all forumCommentEntities.
            for forumThreadEntity in forumThreadEntities {
                let forumThreadCommentEntities: NSMutableSet = forumThreadEntity.mutableSetValue(forKey: ForumThreadEntityKey.comments.rawValue)
                
                for forumThreadCommentEntity in forumThreadCommentEntities {
                    let objectContext: NSManagedObjectContext = (forumThreadCommentEntity as AnyObject).managedObjectContext
                    objectContext.delete(forumThreadCommentEntity as! NSManagedObject)
                }
            }
            
            // Delete all forumThreadEntities
            for forumThreadEntity in forumThreadEntities {
                let objectContext: NSManagedObjectContext = forumThreadEntity.managedObjectContext!
                objectContext.delete(forumThreadEntity)
                
            }
            
            // Create new forumThreadEntities
            for forumThread in forumThreads {
                let forumThreadEntity: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: ForumThreadEntityKey.entityName.rawValue, into: self.context)
                
                // Mandatory fields:
                
                forumThreadEntity.setValue(forumThread.author, forKey: ForumThreadEntityKey.author.rawValue)
                forumThreadEntity.setValue(forumThread.authorID, forKey: ForumThreadEntityKey.authorID.rawValue)
                forumThreadEntity.setValue(DateManager.sharedInstance.dateToISOString(forumThread.date, format: .JSONGeneralDateFormat), forKey: ForumThreadEntityKey.dateString.rawValue)
                forumThreadEntity.setValue(forumThread.id, forKey: ForumThreadEntityKey.id.rawValue)
                forumThreadEntity.setValue(forumThread.title, forKey: ForumThreadEntityKey.title.rawValue)
                
                // Optional fields:
                
                if let imagePath = forumThread.imagePath {
                    forumThreadEntity.setValue(imagePath, forKey: ForumThreadEntityKey.imagePath.rawValue)
                }
                
                if let body = forumThread.body {
                    forumThreadEntity.setValue(body, forKey: ForumThreadEntityKey.body.rawValue)
                }
                
                // Set new comment entities.

                let forumThreadCommentEntities: NSMutableSet = forumThreadEntity.mutableSetValue(forKey: ForumThreadEntityKey.comments.rawValue)
                for forumComment in forumThread.comments! {
                    let forumCommentEntity: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: ForumCommentEntityKey.entityName.rawValue, into: self.context)
                    
                    forumCommentEntity.setValue(forumComment.author, forKey: ForumCommentEntityKey.author.rawValue)
                    forumCommentEntity.setValue(forumComment.authorID, forKey: ForumCommentEntityKey.authorID.rawValue)
                    forumCommentEntity.setValue(forumComment.body, forKey: ForumCommentEntityKey.body.rawValue)
                    forumCommentEntity.setValue(DateManager.sharedInstance.dateToISOString(forumComment.date, format: .JSONGeneralDateFormat), forKey: ForumCommentEntityKey.dateString.rawValue)
                    forumCommentEntity.setValue(forumComment.id, forKey: ForumCommentEntityKey.id.rawValue)
                    forumCommentEntity.setValue(forumComment.imagePath, forKey: ForumCommentEntityKey.imagePath.rawValue)
                    
                    forumThreadCommentEntities.add(forumCommentEntity)
                }
            }
            
        } catch {
            print("saveForumThreadData: There was a problem when updating forumThreads!")
            return
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
