//
//  RGSGeneralInfoDataModel.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/13/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import Foundation
import CoreData

/// Category: Each value determines what icon is set in the view.
enum InfoCategory: Int {
    case Food = 0, Location, Internet, Accomodation, Information
}

class RGSGeneralInfoDataModel: RGSDataModelDelegate {
    
    /// MARK: - Properties
    var id, title, description: String?
    var category: InfoCategory?
    var date: Date?
    
    /// MARK: - Protocol Methods.
    
    /// The model entity keys.
    static var entityKey: [String: String] = [
        "entityName"    : "GeneralInfoEntity",
        "id"            : "id",
        "title"         : "title",
        "description"   : "generalInfoDescription",
        "category"      : "category",
        "dateString"    : "dateString"
    ]
    
    /// Saves all fields to the given NSManagedObject.
    /// - managedObject: The NSManagedObject representation.
    func saveTo (managedObject: NSManagedObject) {
        let entityKey = RGSGeneralInfoDataModel.entityKey
        managedObject.setValue(id, forKey: entityKey["id"]!)
        managedObject.setValue(title, forKey: entityKey["title"]!)
        managedObject.setValue(description, forKey: entityKey["description"]!)
        managedObject.setValue(NSNumber.init(integerLiteral: (category?.rawValue)!), forKey: entityKey["category"]!)
        let dateString = DateManager.sharedInstance.dateToISOString(date, format: .JSONGeneralDateFormat)
        managedObject.setValue(dateString, forKey: entityKey["dateString"]!)
    }
    
    /// Initializes the data model from JSON.
    /// - json: Data in JSON format.
    required init? (from json: [String: Any]) {
        
        // Mandatory fields.
        guard
            let id              = json["_id"] as? String,
            let title           = json["title"] as? String,
            let description     = json["description"] as? String,
            let categoryString  = json["category"] as? String,
            let dateString      = json["date"] as? String
        else { return nil }
        
        self.id                 = id
        self.title              = title
        self.description        = description
        self.category           = InfoCategory.init(rawValue: Int(categoryString)!)
        self.date               = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
    }
    
    /// Initializes the data model from NSManagedObject.
    /// - managedObject: NSManagedObject instance.
    required init? (from managedObject: NSManagedObject) {
        let entityKey = RGSGeneralInfoDataModel.entityKey

        // Mandatory fields.
        guard
            let id              = managedObject.value(forKey: entityKey["id"]!) as? String,
            let title           = managedObject.value(forKey: entityKey["title"]!) as? String,
            let description     = managedObject.value(forKey: entityKey["description"]!) as? String,
            let category        = managedObject.value(forKey: entityKey["category"]!) as? Int,
            let dateString      = managedObject.value(forKey: entityKey["dateString"]!) as? String
        else { return nil }
        
        self.id                 = id
        self.title              = title
        self.description        = description
        self.category           = InfoCategory.init(rawValue: category)
        self.date               = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
    }
}

extension RGSGeneralInfoDataModel {
    
    /// Sorting method for an array of class instances.
    static func sort (a: RGSGeneralInfoDataModel, b: RGSGeneralInfoDataModel) -> Bool {
        return (a.date! > b.date!)
    }
    
    /// Parses a array of JSON objects into an array of data model instances.
    /// - data: Data to be parsed as JSON.
    /// - sort: Sorting method.
    static func parseDataModel (from data: Data, sort: (RGSGeneralInfoDataModel, RGSGeneralInfoDataModel) -> Bool) -> [RGSGeneralInfoDataModel]? {
    
        // Extract the JSON array.
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonArray = json as? [Any]
        else { return nil }
        
        // Map JSON representations to data model instances.
        let models = jsonArray.map({(object: Any) -> RGSGeneralInfoDataModel in
            return RGSGeneralInfoDataModel(from: object as! [String: Any])!;
        })
        
        // Return sorted models.
        return models.sorted(by: sort)
    }
    
    /// Retrieves all model entities from Core Data, and returns them in an array
    /// sorted using the provided sort method.
    /// - context:  The managed object context.
    /// - sort:     The mandatory sorting method.
    static func loadDataModel (context: NSManagedObjectContext, sort: (RGSGeneralInfoDataModel, RGSGeneralInfoDataModel) -> Bool) -> [RGSGeneralInfoDataModel]? {
        let entityKey = RGSGeneralInfoDataModel.entityKey
        var entities: [NSManagedObject]
        
        // Construct request, extract entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: loadDataModel: Couldn't extract generalInfo data!")
            return nil
        }

        // Convert entities to models.
        let models = entities.map({(object: NSManagedObject) -> RGSGeneralInfoDataModel in
            return RGSGeneralInfoDataModel(from: object)!
        })
        
        // Return sorted models.
        return models.sorted(by: sort)
    }
    
    /// Saves all given model representations in Core Data. All existing entries are
    /// removed prior.
    /// - model:    The array of data models to be archived.
    /// - context:  The managed object context.
    static func saveDataModel (_ model: [RGSGeneralInfoDataModel], context: NSManagedObjectContext) {
        let entityKey = RGSGeneralInfoDataModel.entityKey
        let entities: [NSManagedObject]
        
        // Extract all existing entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: saveDataModel: Couldn't extract generalInfo data!")
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
