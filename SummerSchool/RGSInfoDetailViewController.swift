//
//  RGSInfoDetailViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/18/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSInfoDetailViewController: RGSBaseViewController, NSLayoutManagerDelegate {
    
    
    // MARK: - Variables & Constants
    
    var generalInfoItem: GeneralInfo!
    
    // MARK: - Outlets
    
    /// The label for the title of the General Info item.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The textView for the description of the General Info item.
    @IBOutlet weak var descriptionTextView: UITextView!
    
    /// the background view for the title label.
    @IBOutlet weak var titleLabelBackgroundView: UIView!
    
    // MARK: - Outlets: Constraints
    
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
        descriptionTextView.font = SpecificationManager.sharedInstance.textViewFont
        
        // Set titleLabel background color.
        titleLabelBackgroundView.backgroundColor = AppearanceManager.sharedInstance.lightBackgroundGrey
        
        // Configure contents
        if (generalInfoItem != nil) {
            
            // Set title, adjust height to best fit.
            if let title = generalInfoItem.title {
                titleLabel.text = title
                let heightThatFits: CGFloat = UILabel.heightForString(text: title, with: titleLabel.font, bounded: titleLabel.bounds.width)
                titleLabelHeight.constant = max(min(SpecificationManager.sharedInstance.titleLabelMaximumHeight, heightThatFits), SpecificationManager.sharedInstance.titleLabelMinimumHeight)
            }
        
            // Set the description, round the textView.
            descriptionTextView.layer.cornerRadius = 10.0
            do {
                descriptionTextView.attributedText = try NSAttributedString(HTMLString: generalInfoItem.description!, font: descriptionTextView.font)
            } catch {
                descriptionTextView.text = generalInfoItem.description
            }
        }
    }
    
    // MARK: - NSLayoutManager Delegate Methods
    
    /// Handler for the UITextView line spacing.
    func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        return SpecificationManager.sharedInstance.textViewLineSpacing
    }
    
    // MARK: - Class Method Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Navigation Bar Theme
        setNavigationBarTheme()
        
        // Set DescriptionTextView LayoutManager Delegate
        descriptionTextView.layoutManager.delegate = self
        
        // Configure Contents
        configureViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
