//
//  RGSForumThreadDataModel.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/13/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class RGSForumThreadDataModel: RGSDataModelDelegate {
    
    /// MARK: - Properties.
    var id, title, body, author, authorID, imagePath: String?
    var date: Date?
    var comments: [RGSForumCommentDataModel]?
    var image: UIImage?
    
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
        "image"         : "image"
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
        if let body = self.body {
            managedObject.setValue(body, forKey: entityKey["body"]!)
        }
        if let imagePath = self.imagePath {
            managedObject.setValue(imagePath, forKey: entityKey["imagePath"]!)
        }
        if let image = self.image {
            let imageData: Data = UIImagePNGRepresentation(image)! as Data
            managedObject.setValue(imageData, forKey: entityKey["image"]!)
        }
    }
    
    /// Conveniently initializes the class with given fields.
    required init(id: String, title: String, author: String, authorID: String, body: String, imagePath: String?, date: Date, comments: [RGSForumCommentDataModel]) {
        self.id = id
        self.title = title
        self.author = author
        self.authorID = authorID
        self.body = body
        self.imagePath = imagePath
        self.date = date
        self.comments = comments
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
        if let imageData: Data = managedObject.value(forKey: entityKey["image"]!) as? Data {
            self.image = UIImage(data: imageData)
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
        var models: [RGSForumThreadDataModel] = []
        
        // Extract the JSON array.
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonArray = json as? [Any]
        else { return nil }
        
        // Map JSON representations to data model instances. Signal error and return on bad parse.
        for item in jsonArray {
            let model: RGSForumThreadDataModel? = RGSForumThreadDataModel(from: item as! [String: Any])
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
