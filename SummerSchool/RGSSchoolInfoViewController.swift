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
    
    /// The background over which a blurred effect will be placed.
    var screenShot: UIImage?
    
    /// The school name to be presented.
    var schoolName: String?
    
    // MARK: - Outlets
    
    /// The UIView container for the other contents.
    @IBOutlet weak var contentView: UIView!
    
    /// ImageView contains a screenshot of the previous ViewController to which the blur is applied.
    @IBOutlet weak var imageView: UIImageView!
    
    /// The label containing the school name.
    @IBOutlet weak var schoolNameLabel: UILabel!
    
    /// The help button.
    @IBOutlet weak var helpButton: UIButton!
    
    
    // MARK: - Actions
    
    /// Handler for taps to the background (used for dismissal of the ViewController).
    @IBAction func backgroundTap (sender: UIControl) {
        self.showMainViewController() 
    }
    
    /// Handler for a tap on the help button.
    @IBAction func didTapHelpButton (_ sender: UIButton) {
        
    }
    
    // MARK: - Public Methods
    
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
        self.schoolNameLabel.text = schoolName
    }

}
