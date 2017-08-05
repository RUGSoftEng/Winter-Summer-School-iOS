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
    
    /// The label for the title of the General Info item.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The textView for the description of the General Info item.
    @IBOutlet weak var descriptionTextView: UITextView!
    
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
    
    private func sizeForString(string: String, with font: UIFont, bounded byWidth: CGFloat) -> CGSize {
        let maxSize: CGSize = CGSize(width: byWidth, height: 10000)
        
        // Define options and style to allow line drawing.
        let options: NSStringDrawingOptions = NSStringDrawingOptions.usesLineFragmentOrigin
        let style: NSMutableParagraphStyle = NSMutableParagraphStyle()
        style.lineBreakMode = NSLineBreakMode.byCharWrapping
        
        // Prepare attributes, defined style.
        let attributes = [NSFontAttributeName: font, NSParagraphStyleAttributeName: style]
        
        // Determine size, return.
        let s: NSString = string as NSString
        let rect = s.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        
        return rect.size
    }
    
    private func configureViews() -> Void {
        
        // Configure contents
        if (generalInfoItem != nil) {
            
            // Configure titleLabel frame to accomodate title, set title.
            if let title = generalInfoItem.title {
                titleLabelHeight.constant = sizeForString(string: title, with: titleLabel.font, bounded: titleLabel.bounds.width).height
                titleLabel.text = title
            }
        
            // Round the textView, set it to display rendered HTML. If that fails, it will display the raw HTML.
            descriptionTextView.layer.cornerRadius = 10.0
            do {
                descriptionTextView.attributedText = try NSAttributedString(HTMLString: generalInfoItem.description!, font: descriptionTextView.font)
            } catch {
                descriptionTextView.text = generalInfoItem.description
            }
        }
    }
    
    // MARK: - Class Method Overrides

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
