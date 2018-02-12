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
    
    /// Initializes the data model from JSON.
    /// - json: Data in JSON format.
    required init? (from json: [String: Any], with keys: [String: String]) {

        // Mandatory fields.
        guard
            let id          = json[keys["id"]!] as? String,
            let author      = json[keys["author"]!] as? String,
            let authorID    = json[keys["authorId"]!] as? String,
            let body        = json[keys["body"]!] as? String,
            let dateString  = json[keys["dateString"]!] as? String
        else { return nil }
        
        self.id             = id
        self.author         = author
        self.authorID       = authorID
        self.body           = body
        self.date           = DateManager.sharedInstance.ISOStringToDate(dateString, format: .JSONGeneralDateFormat)
        
        // Optional fields.
        if let imagePath = json[keys["imagePath"]!] as? String {
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
    static func parseDataModel (from data: Data, with keys: [String: String], sort: (RGSForumCommentDataModel, RGSForumCommentDataModel) -> Bool) -> [RGSForumCommentDataModel]? {
        var models: [RGSForumCommentDataModel] = []
        
        // Extract the JSON array.
        guard
            let json = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonArray = json as? [Any]
        else { return nil }
        
        // Map JSON representations to data model instances. Signal error and return on bad parse.
        for item in jsonArray {
            let model: RGSForumCommentDataModel? = RGSForumCommentDataModel(from: item as! [String: Any], with: keys)
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
