//
//  RGSLecturerProfileViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/1/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSLecturerProfileViewController: RGSBaseViewController {
    
    // MARK: - Variables & Constants
    
    /// The lecturer
    var lecturer: Lecturer!
    
    // MARK: - Outlets
    
    /// View for the lecturer profile image.
    @IBOutlet weak var imageView: UIImageView!
    
    /// Label for the lecturer name.
    @IBOutlet weak var nameLabel: UILabel!
    
    /// PaddedLabel for the lecturer description.
    @IBOutlet weak var descriptionPaddedLabel: RGSPaddedLabel!
    
    /// PaddedLabel for the lecturer website.
    @IBOutlet weak var websitePaddedLabel: RGSPaddedLabel!
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowReturnButton() -> Bool {
        return true
    }
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (false, nil)
    }
    
    // MARK: - Private Class Methods
    
    func configureViews() -> Void {
        
        // Round the profile image view
        self.imageView.layer.cornerRadius = self.imageView.bounds.size.width / 2
        self.imageView.layer.masksToBounds = true
        self.imageView.clipsToBounds = true
        
        // Configure titles
        self.descriptionPaddedLabel.title = "Description"
        self.websitePaddedLabel.title = "Website"
        
        // Configure contents
        if (lecturer != nil) {
            
            // Set the profile image
            if let image = lecturer.image {
                imageView.image = image
            }
            
            // Set the name.
            self.nameLabel.text = lecturer.name
            
            // Set the description
            self.descriptionPaddedLabel.content = lecturer.description
            
            // Set the website
            if let website = lecturer.website {
                self.websitePaddedLabel.content = website
            }
        }
    }
    
    // MARK: - Class Method Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Navigation Bar Theme (Mandatory)
        setNavigationBarTheme()

        // Configure views
        self.configureViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
