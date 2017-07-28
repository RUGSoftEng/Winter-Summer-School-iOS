//
//  RGSInfoDetailViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/18/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSInfoDetailViewController: RGSBaseViewController {
    
    
    // MARK: - Variables & Constants
    
    var generalInfoItem: GeneralInfo!
    
    // MARK: - Outlets
    
    @IBOutlet weak var titlePaddedLabel: RGSPaddedLabel!
    
    @IBOutlet weak var descriptionPaddedLabel: RGSPaddedLabel!
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowReturnButton() -> Bool {
        return true
    }
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (false, nil)
    }
    
    // MARK: - Private Class Methods
    
    private func configureViews() -> Void {
        
        // Configure titles
        titlePaddedLabel.title = "Title"
        descriptionPaddedLabel.title = "Description"
        
        // Configure contents
        if (generalInfoItem != nil) {
            titlePaddedLabel.content = generalInfoItem.title
            descriptionPaddedLabel.content = generalInfoItem.description
        }
    }
    
    
    // MAR: - Class Method Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Navigation Bar Theme
        setNavigationBarTheme()
        
        // Configure Contents
        configureViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
