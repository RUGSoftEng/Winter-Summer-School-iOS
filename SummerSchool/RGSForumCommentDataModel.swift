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
        "forumThread"   : "forumThread",
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
        if (self.date == nil) { print("Got a nil date for \(dateString)") }
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
    /// - json: JSON object.
    /// - sort: Sorting method.
    static func parseDataModel (from jsonArray: [Any], sort: (RGSForumCommentDataModel, RGSForumCommentDataModel) -> Bool) -> [RGSForumCommentDataModel]? {
        var models: [RGSForumCommentDataModel] = []
        
        // Map JSON representations to data model instances. Signal error and return on bad parse.
        for item in jsonArray {
            let model: RGSForumCommentDataModel? = RGSForumCommentDataModel(from: item as! [String: Any])
            if (model == nil) {
                debugPrint("Failed to parse JSON: ", item, " in class ", String(describing: type(of: self)))
                return nil
            }
            models.append(model!)
        }
        
        // Return sorted models.
        return models.sorted(by: sort)
    }
    
    /// Retrieves all model entities from Core Data, and returns them in an array
    /// sorted using the provided sort method.
    /// - set:      The NSMutableSet of objects.
    /// - sort:     The mandatory sorting method.
    static func loadDataModel (with set: NSMutableSet, sort: (RGSForumCommentDataModel, RGSForumCommentDataModel) -> Bool) -> [RGSForumCommentDataModel]? {
        
        if set.count == 0 {
            return nil
        }
        
        // Convert entities to models
        let models = set.map({(object) -> RGSForumCommentDataModel in
            return RGSForumCommentDataModel(from: object as! NSManagedObject)!
        })
        
        // Sort comments
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
    
    /// Removes all given models from Core Data.
    /// - set:  The NSMutableSet of objects.
    static func removeDataModel (_ model: NSMutableSet) {
        for element in model {
            let objectContext: NSManagedObjectContext = (element as AnyObject).managedObjectContext
            objectContext.delete(element as! NSManagedObject)
        }
    }
}
