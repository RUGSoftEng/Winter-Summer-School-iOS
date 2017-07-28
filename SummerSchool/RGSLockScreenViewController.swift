//
//  RGSLockScreenViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSLockScreenViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    
    // MARK: - Variables & Constants
    
    /// The background over which a blurred effect will be placed.
    var screenShot: UIImage?
    
    // MARK: - Outlets
    
    /// The UIView container for the other contents.
    @IBOutlet weak var contentView: UIView!
    
    /// ImageView contains a screenshot of the previous ViewController to which the blur is applied.
    @IBOutlet weak var imageView: UIImageView!
    
    /// The title displayed under the ImageView
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The TextField for the code to be entered into
    @IBOutlet weak var authorizationCodeTextField: UITextField!
    
    /// The help button.
    @IBOutlet weak var helpButton: UIButton!

    
    // MARK: - Actions
    
    /// Handler for miscellanous taps outside of the keyboard when the authorization text field is being edited.
    @IBAction func backgroundTap(sender: UIControl) {
        authorizationCodeTextField.resignFirstResponder()
    }
    
    /// Handler for deliberate completion of entry in the authorization text field.
    @IBAction func didFinishEditingAuthorizationCodeTextField(_ sender: UITextField) {
        sender.resignFirstResponder()
        
        let loginCode: String? = authorizationCodeTextField.text
        
        if (loginCode != nil && isValidCodeFormat(loginCode!)) {
            authorizationCodeTextField.isEnabled = false
            SecurityManager.sharedInstance.authenticateLoginCode(loginCode!, callback: authenticationCallback(_:))
        } else {
            let alertController = ActionManager.sharedInstance.getActionSheet(title: "Invalid Entry", message: "Provide an 8 character alphanumeric code.", dismissMessage: "Got it")
            present(alertController, animated: false, completion: nil)
        }
        
    }
    
    /// Handler for a tap on the help button
    @IBAction func didTapHelpButton(_ sender: UIButton) {

    }
    
    // MARK: - Private Methods
    
    /// Returns True if the code entered is in the correct format.
    private func isValidCodeFormat(_ loginCode: String) -> Bool {
        let validSymbols: [Bool] = loginCode.characters.map({(c: Character) -> Bool in return ActionManager.sharedInstance.isAlnum(c)})
        return validSymbols.count == SpecificationManager.sharedInstance.loginCodeLength && validSymbols.reduce(true, {a,b in a && b})
    }
    
    // MARK: - Public Methods
    
    /// Callback function for when the authentication result is obtained
    func authenticationCallback(_ authenticated: Bool) -> Void {
        
        if (authenticated) {
            DispatchQueue.main.async() {
                let defaults = UserDefaults.standard
                defaults.set(false, forKey: UserDefaultKey.LockScreen.rawValue)
                self.authorizationCodeTextField.isEnabled = true
                self.showMainViewController()
            }
        } else {
            DispatchQueue.main.async() {
                let alertController = ActionManager.sharedInstance.getActionSheet(title: "Invalid Entry", message: "Your code was invalid!", dismissMessage: "Okay")
                self.present(alertController, animated: false, completion: nil)
                self.authorizationCodeTextField.isEnabled = true
            }
        }
    }
    
    /// Handles action for when the user reopens this ViewController
    func applicationWillEnterForeground(notification: NSNotification) {
        if (SecurityManager.sharedInstance.shouldShowLockScreen == false) {
            showMainViewController()
        }
    }
    
    /// Returns the user to the main view controller
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
            let destination = segue.destination
            if let popover = destination.popoverPresentationController {
                popover.delegate = self
                popover.sourceView = self.helpButton
                popover.sourceRect = self.helpButton.bounds
                popover.permittedArrowDirections = .up
            }
        }
    }

    // MARK: - Class Method Overrides
    
    // Overridden to support Settings lockscreen behaviour
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: app)
    }
    
    // Overridden to support Settings lockscreen behaviour
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let app = UIApplication.shared
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: app)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set screenshot
        self.imageView.image = screenShot;
        
        // Apply a blur effect
        let blurEffect = UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = self.imageView.bounds
        self.imageView.addSubview(blurView)
        
        // Round the corners of the ContentView, redraw it
        self.contentView.layer.cornerRadius = 15.0
        self.contentView.setNeedsDisplay()
    }

}
