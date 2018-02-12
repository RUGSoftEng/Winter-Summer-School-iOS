//
//  RGSDataModelDelegate.swift
//  SummerSchool
//
//  Created by Charles Randolph on 12/17/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import Foundation
import CoreData

protocol RGSDataModelDelegate {
    
    /// The model entity keys.
    static var entityKey: [String: String] {get}
    
    /// Saves all fields to the given NSManagedObject.
    /// - managedObject: The NSManagedObject representation.
    func saveTo (managedObject: NSManagedObject)
    
    /// Initializes the data model from JSON.
    /// - json: Data in JSON format.
    /// - keys: The JSON keys map.
    init? (from json: [String: Any], with keys: [String: String])
    
    /// Initializes the data model from NSManagedObject.
    /// - managedObject: NSManagedObject instance.
    init? (from managedObject: NSManagedObject)
    
}
