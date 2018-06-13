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
    
    // MARK: - Outlets
    
    /// The UIView container for the other contents.
    @IBOutlet weak var contentView: UIView!
    
    /// ImageView contains a screenshot of the previous ViewController to which the blur is applied.
    @IBOutlet weak var imageView: UIImageView!
    
    /// The title displayed under the ImageView
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The TextField for the username to be entered into.
    @IBOutlet weak var usernameTextField: UITextField!
    
    /// The TextField for the code to be entered into.
    @IBOutlet weak var authorizationCodeTextField: UITextField!
    
    /// The help button.
    @IBOutlet weak var helpButton: UIButton!
    
    // The contentView height constraint.
    @IBOutlet weak var contentViewHeight: NSLayoutConstraint!
    
    // The leading offset of the contentView from the top of the screen.
    @IBOutlet weak var contentViewOffset: NSLayoutConstraint!

    // MARK: - Actions
    
    /// Unwind Segue Handle
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
        
    }
    
    /// Handler for miscellanous taps outside of the keyboard when the authorization text field is being edited.
    @IBAction func backgroundTap(sender: UIControl) {
        usernameTextField.resignFirstResponder()
        authorizationCodeTextField.resignFirstResponder()
        self.adjustContentViewOffset(to: recalculateContentViewOffset(), animated: true)
    }
    
    /// Handler for deliberate completion of entry in the username text field.
    @IBAction func didFinishEditingUsernameTextField(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
    
    /// Handler for deliberate completion of entry in the authorization text field.
    @IBAction func didFinishEditingAuthorizationCodeTextField(_ sender: UITextField) {
        sender.resignFirstResponder()
        self.adjustContentViewOffset(to: recalculateContentViewOffset(), animated: true)
        
        let loginCode: String? = authorizationCodeTextField.text

        if (loginCode != nil && isValidCodeFormat(loginCode!)) {
            usernameTextField.isEnabled = false
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
        let validSymbols: [Bool] = loginCode.map({(c: Character) -> Bool in return ActionManager.sharedInstance.isAlnum(c)})
        return validSymbols.count == SpecificationManager.sharedInstance.loginCodeLength && validSymbols.reduce(true, {a,b in a && b})
    }
    
    /// Returns an offset at which to place the popup. Accounts for keyboard if active.
    private func recalculateContentViewOffset (with keyboardHeight: CGFloat = 0.0) -> CGFloat {
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.height
        let contentHeight: CGFloat = contentViewHeight.constant
        let screenHeight: CGFloat = UIScreen.main.bounds.height
        return (screenHeight - statusBarHeight - keyboardHeight - contentHeight) / 2.0
    }
    
    /// Animates the repositioning of the popup.
    func adjustContentViewOffset(to offset: CGFloat, animated: Bool) -> Void {
        let duration: TimeInterval = animated ? 0.25 : 0
        
        UIView.animate(withDuration: duration, animations: {
            self.contentViewOffset.constant = offset
            self.view.layoutIfNeeded()
        }, completion: nil)
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
                    
                    self.usernameTextField.isEnabled = true
                    self.authorizationCodeTextField.isEnabled = true
                    self.showSchoolInfoViewController()
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
        performSegue(withIdentifier: "unwindToMain", sender: self)
    }
    
    /// Presents the SchoolInfo view controller.
    func showSchoolInfoViewController() {
        performSegue(withIdentifier: "showSchoolInfoViewController", sender: self)
    }
    
    // MARK: - Protocol Methods: UIPopoverPresentationControllerDelegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Notifications
    
    func keyboardWillAppear (_ notification: Notification) {
        if let frame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let rect = frame.cgRectValue
            self.adjustContentViewOffset(to: recalculateContentViewOffset(with: rect.height), animated: true)
        }
    }
    
    func keyboardWillDisappear (_ notification: Notification) {
        self.adjustContentViewOffset(to: recalculateContentViewOffset(), animated: true)
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
        
        if (segue.identifier == "showSchoolInfoViewController") {
            
            // Clear logincode and username field.
            self.usernameTextField.text = ""
            self.authorizationCodeTextField.text = ""
            
        }
    }

    // MARK: - Class Method Overrides
    
    // Overridden to support Settings lockscreen behaviour
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Subscribe to notifications about the application entering the foreground.
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: app)
        
        // Subscribe to notification about keyboard invocation.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Subscribe to notification about keyboard disappearing.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Determine the proper offset at which to place the popup. It should be centered onscreen.
        contentViewOffset.constant = recalculateContentViewOffset()
    }
    
    // Overridden to support Settings lockscreen behaviour
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Unsubscribe from notifications about the application entering the foreground.
        let app = UIApplication.shared
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: app)
        
        // Unsubscribe from notification about keyboard invocation.
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        // Unsubscribe from notification about keyboard disappearing.
        //NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round the corners of the ContentView, redraw it
        self.contentView.layer.cornerRadius = 15.0
        self.contentView.setNeedsDisplay()
    }

}
