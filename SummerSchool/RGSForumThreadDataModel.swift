//
//  RGSForumThreadDataModel.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/13/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import Foundation
import CoreData

class RGSForumThreadDataModel: RGSDataModelDelegate {
    
    /// MARK: - Properties.
    var id, title, body, author, authorID, imagePath: String?
    var date: Date?
    var comments: [RGSForumCommentDataModel]?
    
    /// MARK: - Protocol Methods.
    
    /// The model entity key.
    static var entityKey: [String : String] = [
        "entityName"    : "ForumThreadEntity",
        "id"            : "id",
        "title"         : "title",
        "body"          : "body",
        "author"        : "author",
        "authorID"      : "authorID",
        "dateString"    : "dateString",
        "imagePath"     : "imagePath",
        "comments"      : "comments"
    ]
    
    /// Saves all fields to the given NSManagedObject.
    /// - managedObject: The NSManagedObject representation.
    func saveTo (managedObject: NSManagedObject) {
        let entityKey = RGSForumThreadDataModel.entityKey
        
        // Mandatory fields.
        managedObject.setValue(id, forKey: entityKey["id"]!)
        managedObject.setValue(title, forKey: entityKey["title"]!)
        managedObject.setValue(author, forKey: entityKey["author"]!)
        managedObject.setValue(authorID, forKey: entityKey["authorID"]!)
        let dateString = DateManager.sharedInstance.dateToISOString(date, format: .JSONGeneralDateFormat)
        managedObject.setValue(dateString, forKey: entityKey["dateString"]!)
        
        // Optional fields.
        if (body != nil) {
            managedObject.setValue(body, forKey: entityKey["body"]!)
        }
        if (imagePath != nil) {
            managedObject.setValue(imagePath, forKey: entityKey["imagePath"]!)
        }
        
        // External fields.
        if (comments != nil) {
            let entities = managedObject.mutableSetValue(forKey: entityKey["comments"]!)
            
            // (1). Remove entities from context.
            for e in entities {
                let objectContext: NSManagedObjectContext = (e as AnyObject).managedObjectContext
                objectContext.delete(e as! NSManagedObject)
            }

            // (2). Insert new entities into context. Link to comments object.
            for c in comments! {
                let commentManagedObject: NSManagedObject = NSEntityDescription.insertNewObject(forEntityName: RGSForumCommentDataModel.entityKey["entityName"]!, into: DataManager.sharedInstance.context)
                c.saveTo(managedObject: commentManagedObject)
                entities.add(commentManagedObject)
            }
        }
        
    }
    
    /// Initializes the data model from JSON.
    /// - json: Data in JSON format.
    required init? (from json: [String: Any]) {
        
        // Mandatory fields.
        guard
            let id          = json["_id"] as? String,
            let title       = json["title"] as? String,
            let author      = json["author"] as? String,
            let authorID    = json["posterID"] as? String,
            let dateString  = json["date"] as? String
        else { return nil }
        
        self.id = id
        self.title = title
        self.author = author
        self.authorID = authorID
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields.
        if let body = json["description"] as? String {
           self.body = body
        }
        if let imagePath = json["imgurl"] as? String {
            self.imagePath = imagePath
        }
        
        // External fields.
        if let comments = json["comments"] as? [Any] {

            // Initialize comments.
            self.comments = comments.map({(object: Any) -> RGSForumCommentDataModel in
                return RGSForumCommentDataModel(from: object as! [String: Any])!
            })
            
            // Sort comments.
            self.comments?.sort(by: RGSForumCommentDataModel.sort)
        }
    }
    
    /// Initializes the data model from NSManagedObject.
    /// - managedObject: NSManagedObject instance.
    required init? (from managedObject: NSManagedObject) {
        let entityKey = RGSForumThreadDataModel.entityKey
        
        // Mandatory fields.
        guard
            let id          = managedObject.value(forKey: entityKey["id"]!) as? String,
            let title       = managedObject.value(forKey: entityKey["title"]!) as? String,
            let author      = managedObject.value(forKey: entityKey["author"]!) as? String,
            let authorID    = managedObject.value(forKey: entityKey["authorID"]!) as? String,
            let dateString  = managedObject.value(forKey: entityKey["dateString"]!) as? String
        else { return nil }
        
        self.id = id
        self.title = title
        self.author = author
        self.authorID = authorID
        self.date = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields.
        if let body = managedObject.value(forKey: entityKey["body"]!) as? String {
            self.body = body
        }
        if let imagePath = managedObject.value(forKey: entityKey["imagePath"]!) as? String {
            self.imagePath = imagePath
        }
        
        // External fields.
        let comments: NSMutableSet = managedObject.mutableSetValue(forKey: entityKey["comments"]!)
        if (comments.count > 0) {
            
            // Initialize comments.
            self.comments = comments.map({(object) -> RGSForumCommentDataModel in
                return RGSForumCommentDataModel(from: object as! NSManagedObject)!
            })
            
            // Sort comments.
            self.comments?.sort(by: RGSForumCommentDataModel.sort)
        }
    }
    
}

extension RGSForumThreadDataModel {
    
    /// Sorting method for an array of class instances.
    static func sort (a: RGSForumThreadDataModel, b: RGSForumThreadDataModel) -> Bool {
        return (a.date! > b.date!)
    }
    
    /// Parses a array of JSON objects into an array of data model instances.
    /// - data: Data to be parsed as JSON.
    /// - sort: Sorting method.
    static func parseDataModel (from data: Data, sort: (RGSForumThreadDataModel, RGSForumThreadDataModel) -> Bool) -> [RGSForumThreadDataModel]? {
        
        // Extract the JSON array.
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonArray = json as? [Any]
        else { return nil }
        
        // Map JSON representations to data model instances.
        let models = jsonArray.map({(object: Any) -> RGSForumThreadDataModel in
            return RGSForumThreadDataModel(from: object as! [String: Any])!
        })
        
        // Return sorted models.
        return models.sorted(by: sort)
    }
    
    /// Retrieves all model entities from Core Data, and returns them in an array
    /// sorted using the provided sort method.
    /// - context:  The managed object context.
    /// - sort:     The mandatory sorting method.
    static func loadDataModel (context: NSManagedObjectContext, sort: (RGSForumThreadDataModel, RGSForumThreadDataModel) -> Bool) -> [RGSForumThreadDataModel]? {
        let entityKey = RGSForumThreadDataModel.entityKey
        var entities: [NSManagedObject]
        
        // Construct request, extract entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: loadDataModel: Couldn't extract forumThread data!")
            return nil
        }
        
        // Convert entities to models.
        let models = entities.map({(object: NSManagedObject) -> RGSForumThreadDataModel in
            return RGSForumThreadDataModel(from: object)!
        })
        
        // Return sorted models.
        return models.sorted(by: sort)
    }
    
    /// Saves all given model representations in Core Data. All existing entries are
    /// removed prior.
    /// - model:    The array of data models to be archived.
    /// - context:  The managed object context.
    static func saveDataModel (_ model: [RGSForumThreadDataModel], context: NSManagedObjectContext) {
        let entityKey = RGSForumThreadDataModel.entityKey
        var entities: [NSManagedObject]
        
        // Extract all existing entities.
        do {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityKey["entityName"]!)
            entities = try context.fetch(request) as! [NSManagedObject]
        } catch {
            print("Error: saveDataModel: Couldn't extract forumThread data!")
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
