//
//  RGSForumCommentDataModel.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/13/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import Foundation
import CoreData


class RGSForumCommentDataModel: RGSDataModelDelegate {
    
    /// MARK: - Properties
    var id, author, authorID, body, imagePath: String?
    var date: Date?

    /// MARK: - Protocol Methods.
    
    /// The model entity keys.
    static var entityKey: [String: String] = [
        "entityName"    : "ForumCommentEntity",
        "id"            : "id",
        "author"        : "author",
        "authorID"      : "authorID",
        "body"          : "body",
        "imagePath"     : "imagePath",
        "dateString"    : "dateString"
    ]
    
    /// Saves all fields to the given NSManagedObject.
    /// - managedObject: The NSManagedObject representation.
    func saveTo (managedObject: NSManagedObject) {
        let entityKey = RGSForumCommentDataModel.entityKey
        
        // Mandatory fields.
        managedObject.setValue(id, forKey: entityKey["id"]!)
        managedObject.setValue(author, forKey: entityKey["author"]!)
        managedObject.setValue(authorID, forKey: entityKey["authorID"]!)
        managedObject.setValue(body, forKey: entityKey["body"]!)
        let dateString = DateManager.sharedInstance.dateToISOString(date, format: .JSONGeneralDateFormat)
        managedObject.setValue(dateString, forKey: entityKey["dateString"]!)
        
        // Optional fields.
        if (imagePath != nil) {
            managedObject.setValue(imagePath, forKey: entityKey["imagePath"]!)
        }
    }
    
    /// Initializes the data model from JSON.
    /// - json: Data in JSON format.
    required init? (from json: [String: Any]) {

        // Mandatory fields.
        guard
            let id          = json["commentID"] as? String,
            let author      = json["author"] as? String,
            let authorID    = json["posterID"] as? String,
            let body        = json["text"] as? String,
            let dateString  = json["date"] as? String
        else { return nil }
        self.id             = id
        self.author         = author
        self.authorID       = authorID
        self.body           = body
        self.date           = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields.
        if let imagePath = json["imgurl"] as? String {
            self.imagePath = imagePath
        }
    }
    
    /// Initializes the data model from NSManagedObject.
    /// - managedObject: NSManagedObject instance.
    required init? (from managedObject: NSManagedObject) {
        let entityKey = RGSForumCommentDataModel.entityKey
        
        // Mandatory fields.
        guard
            let id = managedObject.value(forKey: entityKey["id"]!) as? String,
            let author = managedObject.value(forKey: entityKey["author"]!) as? String,
            let authorID = managedObject.value(forKey: entityKey["authorID"]!) as? String,
            let body = managedObject.value(forKey: entityKey["body"]!) as? String,
            let dateString = managedObject.value(forKey: entityKey["dateString"]!) as? String
        else { return nil }
        
        self.id         = id
        self.author     = author
        self.authorID   = authorID
        self.body       = body
        self.date       = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields.
        if let imagePath = managedObject.value(forKey: entityKey["imagePath"]!) as? String {
            self.imagePath = imagePath
        }
    }
}

extension RGSForumCommentDataModel {
    
    /// Sorting method for an array of class instances.
    static func sort (a: RGSForumCommentDataModel, b: RGSForumCommentDataModel) -> Bool {
        return (a.date! > b.date!)
    }
    
    /// Parses a array of JSON objects into an array of data model instances.
    /// - data: Data to be parsed as JSON.
    /// - sort: Sorting method.
    static func parseDataModel (from data: Data, sort: (RGSForumCommentDataModel, RGSForumCommentDataModel) -> Bool) -> [RGSForumCommentDataModel]? {
        
        // Extract the JSON array.
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonArray = json as? [Any]
            else { return nil }
        
        // Map JSON representations to data model instances.
        let models = jsonArray.map({(object: Any) -> RGSForumCommentDataModel in
            return RGSForumCommentDataModel(from: object as! [String: Any])!;
        })
        
        // Return sorted models.
        return models.sorted(by: sort)
    }
    
    /// Retrieves all model entities from Core Data, and returns them in an array
    /// sorted using the provided sort method.
    /// - context:  The managed object context.
    /// - sort:     The mandatory sorting method.
    static func loadDataModel (context: NSManagedObjectContext, sort: (RGSForumCommentDataModel, RGSForumCommentDataModel) -> Bool) -> [RGSForumCommentDataModel]? {
        let entityKey = RGSForumCommentDataModel.entityKey
        var entities: [NSManagedObject]
        
        // Construct request, extract entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: loadDataModel: Couldn't extract forumComment data!")
            return nil
        }
        
        // Convert entities to models.
        let models = entities.map({(object: NSManagedObject) -> RGSForumCommentDataModel in
            return RGSForumCommentDataModel(from: object)!
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
            print("Error: saveDataModel: Couldn't extract forumComment data!")
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
