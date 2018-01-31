//
//  RGSForumInputTableViewCellDelegate.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/15/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import Foundation
import UIKit

protocol RGSAuthenticatableObjectDelegate {
    
    /// Method for when user invokes authentication button.
    func userDidRequestAuthentication (sender: UITableViewCell) -> Void
    
    /// Method for when user invokes deauthentication button.
    func userDidRequestDeauthentication (sender: UITableViewCell) -> Void
    
    /// Method for when the user submits content.
    /// contentString: - A string composing the body of the submitted content.
    func userDidSubmitContent (contentString: String?, sender: UITableViewCell) -> Void
    
}
