//
//  RGSForumInputTableViewCell.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/15/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import UIKit

class RGSForumInputTableViewCell: UITableViewCell {
    
    // MARK: - Variables & Constants
    
    /// Delegate for RGSAuthenticatableObjectProtocol
    var delegate: RGSAuthenticatableObjectDelegate?
    
    /// Boolean indicator for whether or not user is signed in.
    var isAuthenticated: Bool = false {
        didSet (oldIsAuthenticated) {
            if (isAuthenticated != oldIsAuthenticated) {
                setAppearance(authenticated: isAuthenticated)
            }
        }
    }
    
    // MARK: - Outlets
    
    /// The authentication button. Also masquerades as a label when user is authenticated.
    @IBOutlet weak var authenticationButton: UIButton!
    
    /// The comment text-field.
    @IBOutlet weak var commentTextField: UITextField!
    
    // MARK: - Actions
    
    /// Action for when user pressed authentication button.
    @IBAction func didPressAuthenticateButton (control: UIControl) {
        if (delegate != nil) {
            if (isAuthenticated) {
                delegate?.userDidRequestDeauthentication(sender: self)
            } else {
                delegate?.userDidRequestAuthentication(sender: self)
            }
        }
    }
    
    /// Action for when user has decided to send a comment.
    @IBAction func didSendComment (control: UITextField) {
        commentTextField.resignFirstResponder()
        
        // Extract comment.
        let comment: String? = control.text
        
        if (delegate != nil && comment != nil) {
            delegate?.userDidSubmitContent(contentString: comment!, sender: self)
        }
        
        // Clear text field.
        commentTextField.text = ""
    }
    
    // MARK: - Private class methods
    
    /// Controls the appearance of the cell.
    func setAppearance (authenticated: Bool) {
        
        if (authenticated) {
            
            // Configure authenticationButton.
            authenticationButton.setTitle("Sign Out", for: .normal)
            authenticationButton.setTitleColor(AppearanceManager.sharedInstance.red, for: .normal)
            authenticationButton.isEnabled = true
            
            // Configure commentTextField.
            commentTextField.isEnabled = true
            commentTextField.placeholder = "Aa"
            
        } else {
            
            // Configure authenticationButton.
            authenticationButton.setTitle("Sign in to comment", for: .normal)
            authenticationButton.setTitleColor(AppearanceManager.sharedInstance.red, for: .normal)
            authenticationButton.isEnabled = true
            
            // Configure commentTextField.
            commentTextField.isEnabled = false
            commentTextField.placeholder = "You must be signed in to comment ..."
            
        }
    }
    
    // MARK - Class Method Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()

        setAppearance(authenticated: self.isAuthenticated)
    }
}