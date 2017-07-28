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
        
        // Initialize mandatory fields. Return nil if missing.
        guard
            let title: String = json["summary"] as? String,
            let address: String = json["location"] as? String,
            let description: String = json["description"] as? String,
            let start: [String: String] = json["start"] as? [String: String],
            let end: [String: String] = json["end"] as? [String: String]
        else {
            return nil
        }
        
        self.title = title
        self.address = address
        self.description = description
        self.startDate = DateManager.sharedInstance.ISOStringToDate(start["dateTime"], format: DateFormat.eventDateFormat)
        self.endDate = DateManager.sharedInstance.ISOStringToDate(end["dateTime"], format: DateFormat.eventDateFormat)
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
        
        // Initialize mandatory fields. Return nil if missing.
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
        self.startDate = DateManager.sharedInstance.ISOStringToDate(startDateString, format: DateFormat.eventDateFormat)
        self.endDate = DateManager.sharedInstance.ISOStringToDate(endDateString, format: DateFormat.eventDateFormat)
        self.ssid = ssid
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
            let date: Date? = DateManager.sharedInstance.ISOStringToDate(dateString, format: DateFormat.eventPacketDateFormat)
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
                let date: Date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .eventPacketDateFormat)
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
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .eventPacketDateFormat)
    }
    
    // Initializer for NSManagedObjects.
    init?(managedObject: NSManagedObject) {
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
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .eventPacketDateFormat)
    }
}

// MARK: - Structures: GeneralInfo

struct GeneralInfo {
    var id: String?
    var title: String?
    var description: String?
}

extension GeneralInfo {
    
    // Initializer for JSON objects.
    init?(json: [String: Any]) {
        guard
            let id: String = json["_id"] as? String,
            let title: String = json["title"] as? String,
            let description: String = json["description"] as? String
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.description = description
    }
    
    // Initializer for NSManagedObjects.
    init?(managedObject: NSManagedObject) {
        guard
            let id: String = managedObject.value(forKey: GeneralInfoEntityKey.id.rawValue) as? String,
            let title: String = managedObject.value(forKey: GeneralInfoEntityKey.title.rawValue) as? String,
            let description: String = managedObject.value(forKey: GeneralInfoEntityKey.description.rawValue) as? String
        else {
            return nil
        }
        
        self.id = id
        self.title = title
        self.description = description
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
    /// Nil is returned on error, or if the query returns empty.
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
    /// error or if nothing could be found in the database.
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
    /// Nil is returned on error, or if the query returns empty.
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
                let dateString: String = DateManager.sharedInstance.dateToISOString(announcement.date, format: .eventPacketDateFormat)!
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
                let dateString: String = DateManager.sharedInstance.dateToISOString(date, format: DateFormat.eventPacketDateFormat)!
                weekDayEntity.setValue(dateString, forKey: WeekDayEntityKey.dateString.rawValue)
                
                // Get WeekDayEntity Events Set (should be empty)
                let weekDayEntityEvents: NSMutableSet = weekDayEntity.mutableSetValue(forKey: WeekDayEntityKey.events.rawValue)
                
                for event in events {
                    let eventEntity: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: EventEntityKey.entityName.rawValue, into: self.context)
                    eventEntity.setValue(event.title, forKey: EventEntityKey.title.rawValue)
                    eventEntity.setValue(event.address, forKey: EventEntityKey.address.rawValue)
                    eventEntity.setValue(event.description, forKey: EventEntityKey.description.rawValue)
                    eventEntity.setValue(event.ssid, forKey: EventEntityKey.ssid.rawValue)
                    eventEntity.setValue(DateManager.sharedInstance.dateToISOString(event.startDate!, format: .eventDateFormat), forKey: EventEntityKey.startDateString.rawValue)
                    eventEntity.setValue(DateManager.sharedInstance.dateToISOString(event.endDate!, format: .eventDateFormat), forKey: EventEntityKey.endDateString.rawValue)
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
            }
        } catch {
            print("saveGeneralInfoData: There was a problem when updating generalInfo!")
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
