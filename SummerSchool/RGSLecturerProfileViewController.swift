//
//  RGSLecturerProfileViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/1/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSLecturerProfileViewController: RGSBaseViewController, UIScrollViewDelegate {
    
    // MARK: - Variables & Constants
    
    /// The lecturer
    var lecturer: Lecturer!
    
    /// The maximum height of the banner.
    let extendedBannerOffset: CGFloat = 8
    
    /// The minimum height of the banner.
    let collapsedBannerOffset: CGFloat = -180
    
    /// The contentView (description and website)
    var lecturerContentView: RGSLecturerContentView!
    
    // MARK: - Outlets
    
    /// View for the lecturer profile image.
    @IBOutlet weak var imageView: UIImageView!
    
    /// Label for the lecturer name.
    @IBOutlet weak var nameLabel: UILabel!
    
    /// The enclosing bannerView
    @IBOutlet weak var bannerView: UIView!
    
    /// Constraint for the slider
    @IBOutlet weak var bannerOffset: NSLayoutConstraint!
    
    /// Button to toggle animation
    @IBOutlet weak var button: UIButton!
    
    /// ScrollView containing description and website info.
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    /// Button to execute collapse animation
    @IBAction func didPressButton(_ sender: UIButton) {
        collapseBanner(with: true)
    }
    
    /// Executes an animation which collapses the banner.
    func collapseBanner(with animation: Bool) -> Void {
        let duration = 0.5 * (animation ? 1.0 : 0.0)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [], animations: {
            self.bannerOffset.constant = self.collapsedBannerOffset
            self.imageView.alpha = 0.0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
    }
    
    func configureViews() -> Void {
        
        // Round the profile image view
        self.imageView.layer.cornerRadius = self.imageView.bounds.size.width / 2
        self.imageView.layer.masksToBounds = true
        self.imageView.clipsToBounds = true
        
        // Load the ContentView
        self.lecturerContentView = RGSLecturerContentView(frame: scrollView.bounds)
        scrollView.contentSize = lecturerContentView.frame.size
        scrollView.addSubview(lecturerContentView)
        
        // Configure contents
        if (lecturer != nil) {
            
            // Set the profile image
            if let image = lecturer.image {
                imageView.image = image
            }
            
            // Set the name.
            self.nameLabel.text = lecturer.name
            
            // Set the description
            lecturerContentView.lecturerDescription = lecturer.description
            
            // Set the website
            if let website = lecturer.website {
                lecturerContentView.website = website
            }
            
            // Reset the content size
            scrollView.contentSize = lecturerContentView.frame.size
        }
    }
    
    // MARK: - UIScrollView Delegate Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        print("Offset = \(offset)")
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
