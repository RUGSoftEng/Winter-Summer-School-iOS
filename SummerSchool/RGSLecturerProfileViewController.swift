//
//  RGSLecturerProfileViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/1/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

struct Toggle {
    var show: CGFloat
    var hide: CGFloat
}

class RGSLecturerProfileViewController: RGSBaseViewController, UITextViewDelegate, NSLayoutManagerDelegate {
    
    // MARK: - Variables & Constants
    
    /// The lecturer
    var lecturer: RGSLecturerDataModel!
    
    /// The height of the header when extended.
    let maximumHeaderOffset: CGFloat = 8
    
    /// The height of the header when collapsed.
    let minimumHeaderOffset: CGFloat = -180
    
    /// The toggle heights for the header.
    var headerToggleHeights: Toggle = Toggle(show: -80, hide: 10)
    
    /// Header state
    var isHeaderExtended: Bool = true
    
    /// The height of the footer when extended.
    let maximumFooterOffset: CGFloat = 8
    
    /// The height of the footer when collapsed.
    let minimumFooterOffset: CGFloat = -56
    
    /// The toggle heights for the footer.
    var footerToggleHeights: Toggle = Toggle(show: -80, hide: 10)
    
    /// Footer state
    var isFooterExtended: Bool = false
    
    // MARK: - Outlets: Views
    
    /// View for the lecturer profile image.
    @IBOutlet weak var profileImageView: UIImageView!
    
    /// Label for the lecturer name.
    @IBOutlet weak var nameLabel: UILabel!
    
    /// The UITextView for the lecturer description.
    @IBOutlet weak var descriptionTextView: UITextView!
    
    /// The UIButton for the lecturer's website.
    @IBOutlet weak var websiteButton: UIButton!
    
    // MARK: - Outlets: Constraints
    
    /// Constraint for the offset between the top of the enclosing view and the header.
    @IBOutlet weak var headerOffsetConstraint: NSLayoutConstraint!
    
    /// Constraint for the offset between the bottom of the enclosing view and the footer.
    @IBOutlet weak var footerOffsetConstraint: NSLayoutConstraint!
    
    // MARK: - Actions
    
    @IBAction func didTapWebsiteButton(_ sender: UIButton) {
        if let website = lecturer.website {
            UIApplication.shared.open(URL(string: website)!, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowReturnButton() -> Bool {
        return true
    }
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (false, nil)
    }
    
    // MARK: - Private Class Methods
    
    /// Returns boolean indicating whether or not the footer should be shown.
    func shouldShowWebsite(lecturer: RGSLecturerDataModel?) -> Bool {
        return (lecturer != nil && lecturer!.website != nil && lecturer!.website!.isEmpty == false)
    }
    
    /// Animates the collapse/extension of the header.
    func toggleHeader(animated: Bool) -> Void {
        var constant: CGFloat
        var alpha: CGFloat
        let duration: TimeInterval = animated ? 0.5 : 0
        
        if (isHeaderExtended) {
            constant = minimumHeaderOffset
            alpha = 0.0
        } else {
            constant = maximumHeaderOffset
            alpha = 1.0
        }
        
        isHeaderExtended = !isHeaderExtended
        
        UIView.animate(withDuration: duration, animations: {
            self.headerOffsetConstraint.constant = constant
            self.profileImageView.alpha = alpha
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    /// Animates the collapse/extension of the footer.
    func toggleFooter(animated: Bool) -> Void {
        var constant: CGFloat
        let duration: TimeInterval = animated ? 0.25 : 0
        
        if (isFooterExtended) {
            constant = minimumFooterOffset
        } else {
            constant = maximumFooterOffset
        }
        
        isFooterExtended = !isFooterExtended
        
        UIView.animate(withDuration: duration, animations: {
            self.footerOffsetConstraint.constant = constant
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    func configureViews() -> Void {
        
        // Round the profile UIImageView
        profileImageView.layer.cornerRadius = profileImageView.bounds.size.width / 2
        profileImageView.layer.masksToBounds = true
        profileImageView.clipsToBounds = true
        
        // Configure contents
        if (lecturer != nil) {
            
            // Set the profile image
            if let image = lecturer.image {
                profileImageView.image = image
            }
            
            // Set the name.
            let name: String = lecturer.name!
            nameLabel.text = name
            
            // Set the description
            do {
                try descriptionTextView.attributedText = NSAttributedString(HTMLString: lecturer.body!, font: descriptionTextView.font)
            } catch {
                print("Couldn't set the lecturer description: \(error)")
            }
            
            // If the website exists, setup the Footer.
            if shouldShowWebsite(lecturer: lecturer) {
                let nameComponents = name.components(separatedBy: " ")
                websiteButton.setTitle("Visit " + nameComponents[0] + "'s Website!", for: .normal)
            }
        }
    }
    
    // MARK: - UIScrollView Delegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        
        if ((isHeaderExtended && offset.y > headerToggleHeights.hide) || (isHeaderExtended == false && offset.y < headerToggleHeights.show)) {
            toggleHeader(animated: true)
        }
        
        if (shouldShowWebsite(lecturer: lecturer) && ((isFooterExtended && offset.y < footerToggleHeights.hide) || (isFooterExtended == false && offset.y > footerToggleHeights.show))) {
            toggleFooter(animated: true)
        }
        
    }
    
    // MARK: - Key Value Observing Methods
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "descriptionTextView.bounds" {
            if let textView = descriptionTextView {
                let visibleHeight: CGFloat = textView.bounds.height
                let contentHeight: CGFloat = textView.contentSize.height
                let base: CGFloat = max(0, contentHeight - visibleHeight)
                self.footerToggleHeights = Toggle(show: base + 40, hide: base - 10)
            }
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
        
        // Reset the ContentOffset to zero.
        self.descriptionTextView.setContentOffset(CGPoint.zero, animated: false)
        
        // Set this class to observe changes to descriptionTextView's frame (needed for footer toggle/collapse triggers)
        addObserver(self, forKeyPath: "descriptionTextView.bounds", options: .new, context: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Enable the scrollView at this point. If enabled earlier, undesired
        // calls will be made to the scrollViewDidScroll function, making it
        // believe it is below toggle height and the header will collapse.
        
        self.descriptionTextView.isScrollEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Remove KVO observing of the descriptionTextView's frame.
        removeObserver(self, forKeyPath: "descriptionTextView.bounds")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Navigation Bar Theme (Mandatory)
        setNavigationBarTheme()
        
        // Set the descriptionTextView LayoutManager delegate
        descriptionTextView.layoutManager.delegate = self
        
        // Initialize footer constant to collapsed value.
        footerOffsetConstraint.constant = minimumFooterOffset

        // Configure views
        self.configureViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
