//
//  RGSAnnouncementEventViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/27/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSAnnouncementEventViewController: RGSBaseViewController {
    
    // MARK: Variables & Constants
    
    var announcement: Announcement!
    
    // MARK: Outlets
    
    @IBOutlet weak var dateLabel: UILabel!
    
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
        
        // Configure Titles
        titlePaddedLabel.title = "Title"
        descriptionPaddedLabel.title = "Description"
        
        // Configure Contents
        if (announcement != nil) {
            
            // Set description to render HTML
            descriptionPaddedLabel.isHTMLContent = true
            
            // Set content
            dateLabel.text = DateManager.sharedInstance.dateToISOString(announcement.date, format: .announcementDateFormat)! + " at " + DateManager.sharedInstance.hoursAndMinutesFromDate(announcement.date)!
            titlePaddedLabel.content = announcement.title
            descriptionPaddedLabel.content = announcement.description
        }

    }
    
    // MARK: - Class Method Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set Navigation Bar Theme
        self.setNavigationBarTheme()
        
        // Configure contents
        configureViews()
    }
    
}
