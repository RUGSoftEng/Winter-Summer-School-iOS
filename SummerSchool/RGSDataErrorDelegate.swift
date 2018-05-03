//
//  RGSDataErrorDelegate.swift
//  SummerSchool
//
//  Created by Charles Randolph on 03/05/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import Foundation
import UIKit

protocol RGSDataErrorDelegate: LocalizedError {
    var title: String { get }
    var className: String { get }
    var data: String? { get }
}
