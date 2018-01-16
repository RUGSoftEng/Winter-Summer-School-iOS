//
//  RGSForumInputTableViewCellDelegate.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/15/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import Foundation
import CoreData

protocol RGSForumInputTableViewCellProtocol {
    
    /// Method for when user invokes authentication button.
    func userDidRequestAuthentication (sender: RGSForumInputTableViewCell) -> Void
    
    /// Method for when the user submits a comment.
    /// comment: - A string composing of the comment body.
    func userDidSubmitComment (comment: String, sender: RGSForumInputTableViewCell) -> Void
    
}
