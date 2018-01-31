//
//  RGSForumButtonTableViewCell.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/30/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import UIKit

class RGSForumButtonTableViewCell: UITableViewCell {
    
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
    
    // MARK: - IBOutlets
    
    /// Button for submitting a post.
    @IBOutlet weak var submitPostButton: UIButton!
    
    /// Button for toggling authentication state.
    @IBOutlet weak var authenticationButton: UIButton!
    
    // MARK: - IBActions
    
    /// Action for when user toggles authentication state.
    @IBAction func didPressAuthenticationButton (control: UIControl) {
        if (delegate != nil) {
            if (isAuthenticated) {
                delegate?.userDidRequestDeauthentication(sender: self)
            } else {
                delegate?.userDidRequestAuthentication(sender: self)
            }
        }
    }
    
    /// Action for when the user decides to submit a post.
    @IBAction func didPressSubmitPostButton (control: UIControl) {
        if (delegate != nil) {
            delegate?.userDidSubmitContent(contentString: nil, sender: self)
        }
    }
    
    // MARK: - Private class methods
    
    /// Controls the appearance of the cell.
    func setAppearance (authenticated: Bool) {
        
        if (authenticated) {
            
            // Configure authenticationButton.
            authenticationButton.setTitle("Sign Out", for: .normal)
            authenticationButton.setTitleColor(AppearanceManager.sharedInstance.red, for: .normal)
            
            // Configure submitPostButton.
            submitPostButton.setTitle("Submit Post", for: .normal)
            submitPostButton.setTitleColor(AppearanceManager.sharedInstance.red, for: .normal)
            submitPostButton.isEnabled = true
            
        } else {
            
            // Configure authenticationButton.
            authenticationButton.setTitle("Sign In", for: .normal)
            authenticationButton.setTitleColor(AppearanceManager.sharedInstance.red, for: .normal)
            
            // Configure submitPostButton.
            submitPostButton.setTitle("Submit Post", for: .normal)
            submitPostButton.setTitleColor(AppearanceManager.sharedInstance.lightTextGrey, for: .normal)
            submitPostButton.isEnabled = false
        }
    }
    
    
    // MARK: - Class Method Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        setAppearance(authenticated: self.isAuthenticated)
    }

    
}
