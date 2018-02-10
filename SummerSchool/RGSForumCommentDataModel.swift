//
//  RGSForumCommentDataModel.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/13/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class RGSForumCommentDataModel {
    
    /// MARK: - Properties
    var id, author, authorID, body, imagePath: String?
    var date: Date?
    var image: UIImage?
    
    /// MARK: - Protocol Methods.
    
    /// Conveniently initializes the class with given fields.
    required init(id: String, author: String, authorID: String, body: String, imagePath: String?, date: Date) {
        self.id = id
        self.author = author
        self.authorID = authorID
        self.body = body
        self.imagePath = imagePath
        self.date = date
    }
    
    /// Initializes the data model from JSON.
    /// - json: Data in JSON format.
    required init? (from json: [String: Any]) {

        // Mandatory fields.
        guard
            let id          = json["_id"] as? String,
            let author      = json["author"] as? String,
            let authorID    = json["posterID"] as? String,
            let body        = json["text"] as? String,
            let dateString  = json["created"] as? String
        else { return nil }
        self.id             = id
        self.author         = author
        self.authorID       = authorID
        self.body           = body
        self.date           = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields.
        if let imagePath = json["imgURL"] as? String {
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
    static func parseDataModel (from data: Data, sort: (RGSForumCommentDataModel, RGSForumCommentDataModel) -> Bool) -> [RGSForumCommentDataModel]? {
        var models: [RGSForumCommentDataModel] = []
        
        // Extract the JSON array.
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonArray = json as? [Any]
        else { return nil }
        
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
}
