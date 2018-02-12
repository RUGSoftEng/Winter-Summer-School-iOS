//
//  RGSEventDataModel.swift
//  SummerSchool
//
//  Created by Charles Randolph on 2/1/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import Foundation
import CoreData

class RGSEventDataModel: RGSDataModelDelegate {
    
    /// MARK: - Properties.
    
    var id, schoolId, title, body, location: String?
    var startDate, endDate: Date?
    
    /// MARK: - Protocol Methods.
    
    /// The model entity key.
    static var entityKey: [String : String] = [
        "entityName"    : "EventEntity",
        "id"            : "id",
        "schoolId"      : "schoolId",
        "title"         : "title",
        "body"          : "body",
        "location"      : "location",
        "startDate"     : "startDate",
        "endDate"       : "endDate"
    ]
    
    /// Saves all fields to the given NSManagedObject.
    /// - managedObject: The NSManagedObject representation.
    func saveTo (managedObject: NSManagedObject) {
        let entityKey = RGSEventDataModel.entityKey
        
        // Mandatory fields.
        managedObject.setValue(id, forKey: entityKey["id"]!)
        managedObject.setValue(schoolId, forKey: entityKey["schoolId"]!)
        managedObject.setValue(title, forKey: entityKey["title"]!)
        managedObject.setValue(body, forKey: entityKey["body"]!)
        
        let startDateString = DateManager.sharedInstance.dateToISOString(startDate, format: .JSONGeneralDateFormat)
        let endDateString = DateManager.sharedInstance.dateToISOString(endDate, format: .JSONGeneralDateFormat)
        
        managedObject.setValue(startDateString, forKey: entityKey["startDate"]!)
        managedObject.setValue(endDateString, forKey: entityKey["endDate"]!)
        
        // Optional fields.
        if let location = self.location {
            managedObject.setValue(location, forKey: entityKey["location"]!)
        }
    }
    
    /// Initializes the data model from JSON.
    /// - json: Data in JSON format.
    required init? (from json: [String: Any], with keys: [String: String]) {
        
        // Mandatory fields.
        guard
            let id                  = json[keys["id"]!] as? String,
            let schoolId            = json[keys["schoolId"]!] as? String,
            let title               = json[keys["title"]!] as? String,
            let body                = json[keys["body"]!] as? String,
            let startDateString     = json[keys["startDateString"]!] as? String,
            let endDateString       = json[keys["endDateString"]!] as? String
        else { return nil }
        
        self.id                     = id
        self.schoolId               = schoolId
        self.title                  = title
        self.body                   = body
        self.startDate              = DateManager.sharedInstance.ISOStringToDate(startDateString, format: .JSONGeneralDateFormat)
        self.endDate                = DateManager.sharedInstance.ISOStringToDate(endDateString, format: .JSONGeneralDateFormat)
        
        // Optional fields.
        if let location = json["location"] as? String {
            self.location = location
        }
        
    }
    
    /// Initializes the data model from NSManagedObject.
    /// - managedObject: NSManagedObject instance.
    required init? (from managedObject: NSManagedObject) {
        let entityKey = RGSEventDataModel.entityKey
        
        // Mandatory fields.
        guard
            let id                  = managedObject.value(forKey: entityKey["id"]!) as? String,
            let schoolId            = managedObject.value(forKey: entityKey["schoolId"]!) as? String,
            let title               = managedObject.value(forKey: entityKey["title"]!) as? String,
            let body                = managedObject.value(forKey: entityKey["body"]!) as? String,
            let startDateString     = managedObject.value(forKey: entityKey["startDate"]!) as? String,
            let endDateString       = managedObject.value(forKey: entityKey["endDate"]!) as? String
        else { return nil }
        
        self.id                     = id
        self.schoolId               = schoolId
        self.title                  = title
        self.body                   = body
        self.startDate              = DateManager.sharedInstance.ISOStringToDate(startDateString, format: .JSONGeneralDateFormat)
        self.endDate                = DateManager.sharedInstance.ISOStringToDate(endDateString, format: .JSONGeneralDateFormat)
        
        // Optional fields.
        if let location = managedObject.value(forKey: entityKey["location"]!) as? String {
            self.location = location
        }
    }
    
}

extension RGSEventDataModel {
    
    /// Sorting method for an array of class instances.
    static func sort (a: RGSEventDataModel, b: RGSEventDataModel) -> Bool {
        return (a.startDate! > b.startDate!)
    }
    
    /// Filtering method for an array of class instances.
    static func filter (model: RGSEventDataModel) -> Bool {
        
        if let schoolId = SpecificationManager.sharedInstance.schoolId {
            return (schoolId == model.schoolId)
        }
        return true
    }
    
    /// Parses a array of JSON objects into an array of data model instances.
    /// - data: Data to be parsed as JSON.
    /// - sort: Sorting method.
    static func parseDataModel (from data: Data, with keys: [String: String], sort: (RGSEventDataModel, RGSEventDataModel) -> Bool) -> [RGSEventDataModel]? {
        var models: [RGSEventDataModel] = []
        
        // Extract the JSON array.
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonArray = json as? [Any]
            else { return nil }
        
        // Map JSON representations to data model instances. Signal error and return on bad parse.
        for item in jsonArray {
            let model: RGSEventDataModel? = RGSEventDataModel(from: item as! [String: Any], with: keys)
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
    static func loadDataModel (context: NSManagedObjectContext, sort: (RGSEventDataModel, RGSEventDataModel) -> Bool) -> [RGSEventDataModel]? {
        let entityKey = RGSEventDataModel.entityKey
        var entities: [NSManagedObject]
        
        // Construct request, extract entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: loadDataModel: Couldn't extract event data!")
            return nil
        }
        
        // Convert entities to models.
        let models = entities.map({(object: NSManagedObject) -> RGSEventDataModel in
            return RGSEventDataModel(from: object)!
        })
        
        // Return sorted models.
        return models.sorted(by: sort)
    }
    
    /// Saves all given model representations in Core Data. All existing entries are
    /// removed prior.
    /// - model:    The array of data models to be archived.
    /// - context:  The managed object context.
    static func saveDataModel (_ model: [RGSEventDataModel], context: NSManagedObjectContext) {
        let entityKey = RGSEventDataModel.entityKey
        var entities: [NSManagedObject]
        
        // Extract all existing entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: saveDataModel: Couldn't extract event data!")
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
