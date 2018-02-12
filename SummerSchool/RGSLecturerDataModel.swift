//
//  RGSLecturerDataModel.swift
//  SummerSchool
//
//  Created by Charles Randolph on 2/7/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class RGSLecturerDataModel: RGSDataModelDelegate {
    
    /// MARK: - Properties.
    var id, name, body, website, imagePath: String?
    var image: UIImage?
    
    /// MARK: - Protocol Methods.
    
    /// The model entity key.
    static var entityKey: [String : String] = [
        "entityName"    : "LecturerEntity",
        "id"            : "id",
        "name"          : "name",
        "body"          : "body",
        "website"       : "website",
        "imagePath"     : "imagePath",
        "imageData"     : "imageData"
    ]
    
    /// Saves all fields to the given NSManagedObject.
    /// - managedObject: The NSManagedObject representation.
    func saveTo (managedObject: NSManagedObject) {
        let entityKey = RGSLecturerDataModel.entityKey
        
        // Mandatory fields.
        managedObject.setValue(id, forKey: entityKey["id"]!)
        managedObject.setValue(name, forKey: entityKey["name"]!)
        managedObject.setValue(body, forKey: entityKey["body"]!)
        
        // Optional fields.
        if let website = self.website {
            managedObject.setValue(website, forKey: entityKey["website"]!)
        }
        if let imagePath = self.imagePath {
            managedObject.setValue(imagePath, forKey: entityKey["imagePath"]!)
        }
        if let image = self.image, let imageData: Data = UIImagePNGRepresentation(image) {
            managedObject.setValue(imageData, forKey: entityKey["imageData"]!)
        }
    }
    
    /// Initializes the data model from JSON.
    /// - json: Data in JSON format.
    required init? (from json: [String: Any], with keys: [String: String]) {
        
        // Mandatory fields.
        guard
            let id                  = json[keys["id"]!] as? String,
            let name                = json[keys["name"]!] as? String,
            let body                = json[keys["body"]!] as? String
        else { return nil }
        
        self.id                     = id
        self.name                   = name
        self.body                   = body
        
        // Optional fields.
        if let website = json["website"] as? String {
            self.website = website
        }
        if let imagePath = json["imagepath"] as? String {
            self.imagePath = imagePath
        }
    }
    
    /// Initializes the data model from NSManagedObject.
    /// - managedObject: NSManagedObject instance.
    required init? (from managedObject: NSManagedObject) {
        let entityKey = RGSLecturerDataModel.entityKey
        
        // Mandatory fields.
        guard
            let id                  = managedObject.value(forKey: entityKey["id"]!) as? String,
            let name                = managedObject.value(forKey: entityKey["name"]!) as? String,
            let body                = managedObject.value(forKey: entityKey["body"]!) as? String
        else { return nil }
        
        self.id                     = id
        self.name                   = name
        self.body                   = body
        
        // Optional fields.
        if let website = managedObject.value(forKey: entityKey["website"]!) as? String {
            self.website = website
        }
        if let imagePath = managedObject.value(forKey: entityKey["imagePath"]!) as? String {
            self.imagePath = imagePath
        }
        if let imageData: Data = managedObject.value(forKey: entityKey["imageData"]!) as? Data {
            self.image = UIImage(data: imageData)
        }
    }
    
}

extension RGSLecturerDataModel {
    
    /// Sorting method for an array of class instances.
    static func sort (a: RGSLecturerDataModel, b: RGSLecturerDataModel) -> Bool {
        return (a.name! > b.name!)
    }
    
    /// Parses a array of JSON objects into an array of data model instances.
    /// - data: Data to be parsed as JSON.
    /// - sort: Sorting method.
    static func parseDataModel (from data: Data, with keys: [String: String], sort: (RGSLecturerDataModel, RGSLecturerDataModel) -> Bool) -> [RGSLecturerDataModel]? {
        var models: [RGSLecturerDataModel] = []
        
        // Extract the JSON array.
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonArray = json as? [Any]
        else { return nil }
        
        // Map JSON representations to data model instances. Signal error and return on bad parse.
        for item in jsonArray {
            let model: RGSLecturerDataModel? = RGSLecturerDataModel(from: item as! [String: Any], with: keys)
            if (model == nil) {
                debugPrint("Failed to parse JSON: ", item, " in class ", String(describing: type(of: self)))
                return nil
            }
            models.append(model!)
        }
        
        // Return sorted models.
        return (models.sorted(by: sort))
    }
    
    /// Retrieves all model entities from Core Data, and returns them in an array
    /// sorted using the provided sort method.
    /// - context:  The managed object context.
    /// - sort:     The mandatory sorting method.
    static func loadDataModel (context: NSManagedObjectContext, sort: (RGSLecturerDataModel, RGSLecturerDataModel) -> Bool) -> [RGSLecturerDataModel]? {
        let entityKey = RGSLecturerDataModel.entityKey
        var entities: [NSManagedObject]
        
        // Construct request, extract entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: loadDataModel: Couldn't extract lecturer data!")
            return nil
        }
        
        // Convert entities to models.
        let models = entities.map({(object: NSManagedObject) -> RGSLecturerDataModel in
            return RGSLecturerDataModel(from: object)!
        })
        
        // Return sorted models.
        return models.sorted(by: sort)
    }
    
    /// Saves all given model representations in Core Data. All existing entries are
    /// removed prior.
    /// - model:    The array of data models to be archived.
    /// - context:  The managed object context.
    static func saveDataModel (_ model: [RGSLecturerDataModel], context: NSManagedObjectContext) {
        let entityKey = RGSLecturerDataModel.entityKey
        var entities: [NSManagedObject]
        
        // Extract all existing entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: saveDataModel: Couldn't extract lecturer data!")
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
