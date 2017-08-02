//
//  RGSLecturerContentView.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/2/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSLecturerContentView: UIView {
    
    // MARK: - Variables & Constants
    
    /// The contentView 
    var contentView: UIView!
    
    /// The description for the lecturer.
    var lecturerDescription: String? {
        
        didSet (oldLecturerDescription) {
            if (lecturerDescription != nil && lecturerDescription != oldLecturerDescription) {
                self.descriptionTextView.text = lecturerDescription
                self.adjustUITextViewHeight(descriptionTextView)
                self.adjustViewToFitSubviews()
            }
        }
    }
    
    /// The address for the website of the lecturer.
    var website: String? {
        didSet (oldWebsite) {
            if (website != nil) {
                self.websiteButton.isEnabled = true
            } else {
                self.websiteButton.isEnabled = false
            }
        }
    }
    
    /// The height of the content not including that of the UITextView.
    var contentViewConstantHeight: CGFloat {
        if let a = websiteButtonHeightConstraint,
            let b = websiteButtonLowerOffsetConstraint,
            let c = descriptonTextViewLowerOffsetConstraint,
            let d = descriptionTextViewUpperOffsetConstraint {
            return a.constant + b.constant + c.constant + d.constant
        } else {
            return 0
        }
    }
    
    /// Computed Nib Name variable
    var nibName: String {
        return String(describing: type(of: self))
    }
    
    // MARK: - Outlets
    
    /// The UITextView for the description.
    @IBOutlet weak var descriptionTextView: UITextView!
    
    /// The UIButton for the website address.
    @IBOutlet weak var websiteButton: UIButton!
    
    /// LayoutConstraint for the height of the websiteButton.
    @IBOutlet weak var websiteButtonHeightConstraint: NSLayoutConstraint!
    
    /// LayoutConstraint for the lower offset of the websiteButton.
    @IBOutlet weak var websiteButtonLowerOffsetConstraint: NSLayoutConstraint!
    
    /// LayoutConstraint for the lower offset of the descriptionTextView.
    @IBOutlet weak var descriptonTextViewLowerOffsetConstraint: NSLayoutConstraint!
    
    /// LayoutConstraint for the upper offset of the descriptionTextView.
    @IBOutlet weak var descriptionTextViewUpperOffsetConstraint: NSLayoutConstraint!
    
    // MARK: - Actions
    
    @IBAction func didTapWebsiteButton(_ sender: UIButton) {
        print("Did tap the website button!")
    }
    
    // MARK: - Private Class Methods
    
    /// Adjusts the descriptionTextView height
    func adjustUITextViewHeight(_ textView: UITextView?) {
        if textView != nil {
            textView?.translatesAutoresizingMaskIntoConstraints = true
            textView?.sizeToFit()
            textView?.isScrollEnabled = false
        }
    }
    
    /// Calculates the required height to contain the given string given the width/
    func heightForString(string: String, bounded byWidth: CGFloat) -> CGSize {
        
        // Define maximum size allowed.
        let maxSize = CGSize(width: byWidth, height: 10000)
        
        // Define Options, Paragraph Style.
        let options = NSStringDrawingOptions.usesLineFragmentOrigin
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byCharWrapping
        let attributes = [NSParagraphStyleAttributeName: style]
        
        // Construct String and determine bounding rectangle.
        let s = string as NSString
        let rect = s.boundingRect(with: maxSize, options: options, attributes: attributes, context: nil)
        
        return rect.size
    }
    
    /// Adjusts the view to fit the subview
    func adjustViewToFitSubviews() -> Void {
        let size: CGSize = CGSize(width: contentView.frame.width, height: contentViewConstantHeight + descriptionTextView.bounds.height)
        self.contentView.bounds.size = size
        self.frame.size = size
    }
    
    /// Calculates the appropriate height for the View contents.
    func getContentSize(for description: String) -> CGSize {
        let width: CGFloat = self.frame.width
        let contentSize = heightForString(string: description, bounded: width)
        return CGSize(width: width, height: contentViewConstantHeight + contentSize.height)
    }


    // MARK: - Nib Initializer
    
    func loadViewFromNib() -> Void {
        
        // Load the ContentView
        contentView = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[0] as! UIView
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        
        addSubview(contentView)
    }
    
    // MARK: - Class Method Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }

}
