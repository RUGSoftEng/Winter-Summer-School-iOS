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
            SecurityManager.sharedInstance.authenticateLoginCode(loginCode!, callback: authenticationCallback)
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
    
    /// Presents an error message to the user.
    /// - authState: The authentication state to be reported.
    func displayAuthenticationAlert (_ authState: AuthState) {
        let message: String = (authState == .badLoginCode) ? "Your code was invalid!" : "Couldn't reach authentication server!"
        let alertController = ActionManager.sharedInstance.getActionSheet(title: "Login Failed", message: message, dismissMessage: "Okay")
        self.present(alertController, animated: false, completion: nil)
        self.authorizationCodeTextField.isEnabled = true
    }
    
    /// Callback function for when the authentication result is obtained
    func authenticationCallback(_ authState: AuthState, _ schoolId: String?) -> Void {

        if (authState == .authenticated) {
            
            /// Fetch School Information.
            SecurityManager.sharedInstance.requestSchoolInfo(schoolId!, callback: {(statusCode: Int?, name: String?, start: String?, end: String?) -> Void in
                DispatchQueue.main.async() {
                    
                    // If any fields are nil, fail with a network error (ignoring status code here).
                    if (name == nil || start == nil || end == nil) {
                        self.displayAuthenticationAlert(.badNetworkConnection)
                        return
                    }
                    
                    // Otherwise, update user settings.
                    SpecificationManager.sharedInstance.setUserSettings(false, name!, schoolId!, start!, end!)
                    
                    self.authorizationCodeTextField.isEnabled = true
                    self.showParentViewController()
                }
            })
            
        } else {
            DispatchQueue.main.async() {
                self.displayAuthenticationAlert(authState)
            }
        }
    }
    
    /// Handles action for when the user reopens this ViewController
    func applicationWillEnterForeground(notification: NSNotification) {
        if (SecurityManager.sharedInstance.shouldShowLockScreen == false) {
            showParentViewController()
        }
    }
    
    /// Returns the user to the main view controller
    func showParentViewController() {
        performSegue(withIdentifier: "unwindToParent", sender: self)
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
