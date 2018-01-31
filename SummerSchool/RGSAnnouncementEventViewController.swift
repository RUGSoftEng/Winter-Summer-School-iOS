//
//  RGSAnnouncementEventViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/27/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSAnnouncementEventViewController: RGSBaseViewController, NSLayoutManagerDelegate {
    
    // MARK: Variables & Constants
    
    /// The announcement.
    var announcement: RGSAnnouncementDataModel!
    
    // MARK: Outlets
    
    /// The UILabel for the announcement title.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The UILabel for the date of the announcement.
    @IBOutlet weak var dateLabel: UILabel!
    
    /// The UITextView for the description of the announcement.
    @IBOutlet weak var descriptionTextView: UITextView!
    
    /// The background UIView for the titleLabel.
    @IBOutlet weak var titleLabelBackgroundView: UIView!
    
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
        dateLabel.font = SpecificationManager.sharedInstance.subTitleLabelFont
        descriptionTextView.font = SpecificationManager.sharedInstance.textViewFont
        
        // Set titleLabel background color.
        titleLabelBackgroundView.backgroundColor = AppearanceManager.sharedInstance.lightBackgroundGrey
        
        // Configure Contents
        if (announcement != nil) {
            
            // Set title, adjust label height to best fit.
            if let title = announcement.title {
                titleLabel.text = title
                let heightThatFits: CGFloat = UILabel.heightForString(text: title, with: titleLabel.font, bounded: titleLabel.bounds.width)
                titleLabelHeight.constant = max(min(SpecificationManager.sharedInstance.titleLabelMaximumHeight, heightThatFits), SpecificationManager.sharedInstance.titleLabelMinimumHeight)
            }
            
            // Set Date.
            if let date = announcement.date {
                dateLabel.text = DateManager.sharedInstance.dateToISOString(date, format: .generalPresentationDateFormat)
            }
            
            // Set Description, Round the textView.
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
    
    // MARK: - NSLayoutManager Delegate Methods
    
    /// Handler for the UITextView line spacing.
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return SpecificationManager.sharedInstance.textViewLineSpacing
    }
    
    // MARK: - Class Method Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Never display Warning Popup Button.
        self.dismissWarningPopup(animated: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set Navigation Bar Theme
        self.setNavigationBarTheme()
        
        // Set DescriptionTextView LayoutManager delegate.
        descriptionTextView.layoutManager.delegate = self
        
        // Configure contents
        configureViews()
    }
    
}
