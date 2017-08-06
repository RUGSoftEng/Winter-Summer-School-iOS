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
    
    /// The announcement.
    var announcement: Announcement!
    
    // MARK: Outlets
    
    /// The UILabel for the announcement title.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The UILabel for the author of the announcement.
    @IBOutlet weak var authorLabel: UILabel!
    
    /// The UILabel for the date of the announcement.
    @IBOutlet weak var dateLabel: UILabel!
    
    /// The UITextView for the description of the announcement.
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: Outlets: Constraints
    
    /// The height of the titleLabel.
    @IBOutlet weak var titleLabelHeight: NSLayoutConstraint!
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowReturnButton() -> Bool {
        return true
    }
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (false, nil)
    }
    
    // MARK: - Private Class Methods
    
    private func configureViews() -> Void {
        
        // Set fonts.
        titleLabel.font = SpecificationManager.sharedInstance.titleLabelFont
        authorLabel.font = SpecificationManager.sharedInstance.subTitleLabelFont
        dateLabel.font = SpecificationManager.sharedInstance.subTitleLabelFont
        descriptionTextView.font = SpecificationManager.sharedInstance.textViewFont
        
        // Configure Contents
        if (announcement != nil) {
            
            // Set the title, adjust label height to best fit.
            if let title = announcement.title {
                titleLabel.text = title
                let heightThatFits: CGFloat = UILabel.heightForString(text: title, with: titleLabel.font, bounded: titleLabel.bounds.width)
                titleLabelHeight.constant = min(SpecificationManager.sharedInstance.titleLabelMaximumHeight, heightThatFits)
            }
            
            // Set the Author and Date.
            if let author = announcement.poster, let date = announcement.date {
                authorLabel.text = "By " + author
                dateLabel.text = DateManager.sharedInstance.dateToISOString(date, format: .announcementDateFormat)
            }
            
            // Set the Description, Round the textView.
            if let description = announcement.description {
                do {
                    descriptionTextView.attributedText = try NSAttributedString(HTMLString: description, font: descriptionTextView.font)
                } catch {
                    descriptionTextView.text = description
                }
            }
            descriptionTextView.layer.cornerRadius = 10.0
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
