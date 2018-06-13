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
    
    // MARK: - Outlets
    
    /// The UIView container for the entire card and button assembly.
    @IBOutlet weak var containerView: UIView!
    
    /// The UIView container for the other contents.
    @IBOutlet weak var contentView: UIView!
    
    /// The UIView container for the confirm button.
    @IBOutlet weak var confirmButtonViewContainer: UIView!
    
    /// The UIView container for the help button.
    @IBOutlet weak var helpButtonViewContainer: UIView!
    
    /// ImageView contains a screenshot of the previous ViewController to which the blur is applied.
    @IBOutlet weak var imageView: UIImageView!
    
    /// The label containing the school name.
    @IBOutlet weak var schoolNameLabel: UILabel!
    
    /// The label containing the school duration string.
    @IBOutlet weak var schoolDurationLabel: UILabel!
    
    /// The help button.
    @IBOutlet weak var helpButton: UIButton!
    
    /// The confirm button.
    @IBOutlet weak var confirmButton: UIButton!
    
    // MARK: - Actions
    
    /// Handler for taps on the confirm button (used for dismissal of the ViewController).
    @IBAction func didTapConfirmButton (sender: UIButton) {
        self.showMainViewController()
    }
    
    /// Handler for a tap on the help button.
    @IBAction func didTapHelpButton (_ sender: UIButton) {
        
        let actionSheet =  UIAlertController(title: "Not your school?", message: "If the problem persists, contact your school coordinator. You will now be returned to the login screen.", preferredStyle: UIAlertControllerStyle.actionSheet)
        
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
        
        // Round the corners of the ContentView, redraw it
        self.contentView.layer.cornerRadius = 15.0
        self.contentView.setNeedsDisplay()
        
        // Round the confirm button view container, redraw it.
        self.confirmButtonViewContainer.layer.cornerRadius = 15.0
        self.confirmButtonViewContainer.setNeedsDisplay()
        
        // Round the help button view container, redraw it.
        self.helpButtonViewContainer.layer.cornerRadius = 15.0
        self.helpButtonViewContainer.setNeedsDisplay()
        
        // Set the school name.
        schoolNameLabel.text = SpecificationManager.sharedInstance.schoolName
        
        // Set the school range.
        schoolDurationLabel.text =
            schoolDurationFrom(startDate: SpecificationManager.sharedInstance.schoolStartDate, to: SpecificationManager.sharedInstance.schoolEndDate)

    }

}
