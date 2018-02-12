//
//  RGSAnnouncementDataModel.swift
//  SummerSchool
//
//  Created by Charles Randolph on 12/15/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import CoreData

class RGSAnnouncementDataModel: RGSDataModelDelegate {
    
    /// MARK: - Properties.
    
    var id, schoolId, title, description: String?
    var date: Date?
    
    /// MARK: - Protocol Methods.
    
    /// The model entity key.
    static var entityKey: [String : String] = [
        "entityName"    : "AnnouncementEntity",
        "title"         : "title",
        "description"   : "announcementDescription",
        "dateString"    : "dateString",
        "schoolId"      : "schoolId",
        "id"            : "id"
    ]
    
    /// Saves all fields to the given NSManagedObject.
    /// - managedObject: The NSManagedObject representation.
    func saveTo (managedObject: NSManagedObject) {
        let entityKey = RGSAnnouncementDataModel.entityKey
        managedObject.setValue(title, forKey: entityKey["title"]!)
        managedObject.setValue(description, forKey: entityKey["description"]!)
        managedObject.setValue(schoolId, forKey: entityKey["schoolId"]!)
        managedObject.setValue(id, forKey: entityKey["id"]!)
        let dateString = DateManager.sharedInstance.dateToISOString(date, format: .JSONGeneralDateFormat)
        managedObject.setValue(dateString, forKey: entityKey["dateString"]!)
    }

    /// Initializes the data model from JSON.
    /// - json: Data in JSON format.
    required init? (from json: [String: Any], with keys: [String: String]) {
        
        // Mandatory fields.
        guard
            let id          = json[keys["id"]!] as? String,
            let title       = json[keys["title"]!] as? String,
            let description = json[keys["body"]!] as? String,
            let schoolId    = json[keys["schoolId"]!] as? String,
            let dateString  = json[keys["dateString"]!] as? String
        else { return nil }
        
        self.id             = id
        self.schoolId       = schoolId
        self.title          = title
        self.description    = description
        self.date           = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
    
    }
    
    /// Initializes the data model from NSManagedObject.
    /// - managedObject: NSManagedObject instance.
    required init? (from managedObject: NSManagedObject) {
        let entityKey = RGSAnnouncementDataModel.entityKey
        
        // Mandatory fields.
        guard
            let id          = managedObject.value(forKey: entityKey["id"]!) as? String,
            let title       = managedObject.value(forKey: entityKey["title"]!) as? String,
            let description = managedObject.value(forKey: entityKey["description"]!) as? String,
            let schoolId    = managedObject.value(forKey: entityKey["schoolId"]!) as? String,
            let dateString  = managedObject.value(forKey: entityKey["dateString"]!) as? String
        else { return nil }
        
        self.id             = id
        self.title          = title
        self.description    = description
        self.schoolId       = schoolId
        self.date           = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
    }

}

extension RGSAnnouncementDataModel {
    
    /// Sorting method for an array of class instances.
    static func sort (a: RGSAnnouncementDataModel, b: RGSAnnouncementDataModel) -> Bool {
        return (a.date! > b.date!)
    }
    
    /// Filtering method for an array of class instances.
    static func filter (model: RGSAnnouncementDataModel) -> Bool {
        if (SpecificationManager.sharedInstance.schoolId != nil) {
            return (model.schoolId == SpecificationManager.sharedInstance.schoolId!)
        }
        return true
    }
    
    /// Parses a array of JSON objects into an array of data model instances.
    /// - data: Data to be parsed as JSON.
    /// - sort: Sorting method.
    static func parseDataModel (from data: Data, with keys: [String: String], sort: (RGSAnnouncementDataModel, RGSAnnouncementDataModel) -> Bool) -> [RGSAnnouncementDataModel]? {
        var models: [RGSAnnouncementDataModel] = []
        
        // Extract the JSON array.
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonArray = json as? [Any]
        else { return nil }
        
        // Map JSON representations to data model instances. Signal error and return on bad parse.
        for item in jsonArray {
            let model: RGSAnnouncementDataModel? = RGSAnnouncementDataModel(from: item as! [String: Any], with: keys)
            if (model == nil) {
                debugPrint("Failed to parse JSON: ", item, " in class ", String(describing: type(of: self)))
                return nil
            }
            models.append(model!)
        }
        
        // Return filtered and sorted models.
        return (models.filter(filter)).sorted(by: sort)
    }
    
    /// Retrieves all model entities from Core Data, and returns them in an array
    /// sorted using the provided sort method.
    /// - context:  The managed object context.
    /// - sort:     The mandatory sorting method.
    static func loadDataModel (context: NSManagedObjectContext, sort: (RGSAnnouncementDataModel, RGSAnnouncementDataModel) -> Bool) -> [RGSAnnouncementDataModel]? {
        let entityKey = RGSAnnouncementDataModel.entityKey
        var entities: [NSManagedObject]
        
        // Construct request, extract entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: loadDataModel: Couldn't extract announcement data!")
            return nil
        }
        
        // Convert entities to models.
        let models = entities.map({(object: NSManagedObject) -> RGSAnnouncementDataModel in
            return RGSAnnouncementDataModel(from: object)!
        })
        
        // Return sorted models.
        return models.sorted(by: sort)
    }
    
    /// Saves all given model representations in Core Data. All existing entries are
    /// removed prior.
    /// - model:    The array of data models to be archived.
    /// - context:  The managed object context.
    static func saveDataModel (_ model: [RGSAnnouncementDataModel], context: NSManagedObjectContext) {
        let entityKey = RGSAnnouncementDataModel.entityKey
        var entities: [NSManagedObject]
        
        // Extract all existing entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: saveDataModel: Couldn't extract announcement data!")
            return
        }
        
        // Delete all existing entities.
        for entity in entities {
            let objectContext = entity.managedObjectContext!
            objectContext.delete(entity)
        }
        
        // Insert new entities.
        for object in model {
            let entity = NSEntityDescription.insertNewObject(forEntityName: entityKey["entityName"]!, into: context) as NSManagedObject
            object.saveTo(managedObject: entity)
        }
        
        // Save context.
        DataManager.sharedInstance.saveContext()
    }
}
