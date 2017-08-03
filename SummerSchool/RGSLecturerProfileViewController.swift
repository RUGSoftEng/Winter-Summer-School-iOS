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

class RGSLecturerProfileViewController: RGSBaseViewController, UITextViewDelegate {
    
    // MARK: - Variables & Constants
    
    /// The lecturer
    var lecturer: Lecturer!
    
    /// The height of the header when extended.
    let maximumHeaderOffset: CGFloat = 8
    
    /// The height of the header when collapsed.
    let minimumHeaderOffset: CGFloat = -180
    
    /// The toogle heights for the header.
    let headerToggleHeights: Toggle = Toggle(show: -10, hide: 10)
    
    /// Header state
    var isHeaderExtended = true
    
    /// The height of the footer when extended.
    let maximumFooterOffset: CGFloat = 8
    
    /// The height of the footer when collapsed.
    let minimumFooterOffset: CGFloat = -56
    
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
                try descriptionTextView.attributedText = NSAttributedString(HTMLString: lecturer.description!, font: descriptionTextView.font)
            } catch {
                print("Couldn't set the lecturer description: \(error)")
            }
            
            // If the website exists, show the footer.
            if lecturer.website != nil && lecturer.website!.isEmpty == false {
                let nameComponents = name.components(separatedBy: " ")
                websiteButton.setTitle("Visit " + nameComponents[0] + "'s Website!", for: .normal)
                footerOffsetConstraint.constant = maximumFooterOffset
            } else {
                websiteButton.isHidden = true
                footerOffsetConstraint.constant = minimumFooterOffset
            }
        }
    }
    
    // MARK: - UIScrollView Delegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        print("ContentOffset = \(offset)")
        if (isHeaderExtended && offset.y > headerToggleHeights.hide) {
            print("Toggled header!")
            toggleHeader(animated: true)
        }
        
        if (isHeaderExtended == false && offset.y < headerToggleHeights.show) {
            toggleHeader(animated: true)
        }
        
    }
    
    // MARK: - Class Method Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Reset the ContentOffset to zero.
        self.descriptionTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Enable the scrollView at this point. If enabled earlier, undesired
        // calls will be made to the scrollViewDidScroll function, making it
        // believe it is below toggle height and the header will collaps.
        
        self.descriptionTextView.isScrollEnabled = true
    }

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
