//
//  RGSSchoolInfoViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 2/11/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import UIKit

class RGSSchoolInfoViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Variables & Constants
    
    /// Default placeholder string for the date range.
    let defaultDuration: String = "<Unknown Range>"
    
    /// The background over which a blurred effect will be placed.
    var screenShot: UIImage?
    
    // MARK: - Outlets
    
    /// The UIView container for the other contents.
    @IBOutlet weak var contentView: UIView!
    
    /// ImageView contains a screenshot of the previous ViewController to which the blur is applied.
    @IBOutlet weak var imageView: UIImageView!
    
    /// The label containing the school name.
    @IBOutlet weak var schoolNameLabel: UILabel!
    
    /// The label containing the school duration string.
    @IBOutlet weak var schoolDurationLabel: UILabel!
    
    /// The help button.
    @IBOutlet weak var helpButton: UIButton!
    
    // MARK: - Actions
    
    /// Handler for taps to the background (used for dismissal of the ViewController).
    @IBAction func backgroundTap (sender: UIControl) {
        self.showMainViewController() 
    }
    
    /// Handler for a tap on the help button.
    @IBAction func didTapHelpButton (_ sender: UIButton) {
        
        let actionSheet =  UIAlertController(title: "Wrong School?", message: "If the problem persists, contact your school coordinator. You will now be returned to the login screen.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction!) in
            self.showLockscreenViewController()
        }))
        
        self.present(actionSheet, animated: true, completion: nil)

    }
    
    // MARK: - Public Methods
    
    /// Returns a string describing the duration of the school.
    func schoolDurationFrom (startDate: Date?, to endDate: Date?) -> String {
        
        // Abort if dates incomplete.
        if (startDate == nil || endDate == nil) {
            return defaultDuration
        }
        
        // Abort if cannot translate dates to strings.
        guard
            let startDateString = DateManager.sharedInstance.dateToISOString(startDate!, format: .generalPresentationDateFormat),
            let endDateString = DateManager.sharedInstance.dateToISOString(endDate!, format: .generalPresentationDateFormat)
        else {
            return defaultDuration
        }
        
        return startDateString + " - " + endDateString
    }
    
    /// Returns the user to the lockscreen.
    func showLockscreenViewController() {
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }
    
    /// Dismisses the login apparatus entirely.
    func showMainViewController() {
        performSegue(withIdentifier: "unwindToMain", sender: self)
    }
    
    // MARK: - Protocol Methods: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "DisplayHelpPopover") {
            
        }
    }
    
    // MARK: - Class Method Overrides
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set screenshot
        self.imageView.image = screenShot
        
        // Apply a blur effect
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.imageView.bounds
        self.imageView.addSubview(blurView)
        
        // Round the corners of the ContentView, redraw it
        self.contentView.layer.cornerRadius = 15.0
        self.contentView.setNeedsDisplay()
        
        // Set the school name.
        schoolNameLabel.text = SpecificationManager.sharedInstance.schoolName
        
        // Set the school range.
        schoolDurationLabel.text =
            schoolDurationFrom(startDate: SpecificationManager.sharedInstance.schoolStartDate, to: SpecificationManager.sharedInstance.schoolEndDate)

    }

}