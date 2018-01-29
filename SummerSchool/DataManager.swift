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
        
        guard
            let json = try? JSONSerialization.jsonObject(with: data!, options: []),
            let jsonArray = json as? [String: Any],
            let schoolName = jsonArray["name"] as? String,
            let schoolStartDateString = jsonArray["startDate"] as? String,
            let schoolEndDateString = jsonArray["endDate"] as? String
        else { return nil }
        
        return (schoolName, schoolStartDateString, schoolEndDateString)
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
