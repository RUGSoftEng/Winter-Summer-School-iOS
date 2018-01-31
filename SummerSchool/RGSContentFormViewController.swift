//
//  RGSContentFormViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/31/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import UIKit

class RGSContentFormViewController: UIViewController, UITextViewDelegate {
    
    // MARK: - Variables & Constants
    
    /// The text of the title field.
    var titleText: String? {
        get {
            return titleTextField.text
        }
    }
    
    /// The text of the body field.
    var bodyText: String? {
        get {
            return bodyTextView.text
        }
    }
    
    // MARK: - Outlets
    
    /// The cancel button.
    @IBOutlet weak var cancelButton: UIButton!
    
    /// The submit button.
    @IBOutlet weak var submitButton: UIButton!
    
    /// The title textField.
    @IBOutlet weak var titleTextField: UITextField!
    
    /// The body textView.
    @IBOutlet weak var bodyTextView: UITextView!
    
    // MARK: - Actions
    
    /// Action for tap on the cancel button.
    @IBAction func userDidTapCancelButton (sender: UIControl) {
        print("User cancelled!")
    }
    
    /// Action for tap on the submit button.
    @IBAction func userDidTapSubmitButton (sender: UIControl) {
        print("User submits their post...")
    }
    
    /// Action for when the user has finished editing.
    @IBAction func userDidFinishEditing (sender: UIControl) {
        sender.resignFirstResponder()
        submitButton.isEnabled = requiredFieldsComplete()
    }
    
    /// Action for when the user taps outside the UITextView.
    @IBAction func backgroundTap (sender: UIControl) {
        bodyTextView.resignFirstResponder()
    }
    
    // MARK: UITextView Delegate Methods
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        submitButton.isEnabled = requiredFieldsComplete()
    }
    
    // MARK: - Private Class Methods.
    
    /// Returns true if the user meets submission requirements.
    func requiredFieldsComplete () -> Bool {
        if (titleText == nil || bodyText == nil) {
            return false
        }
        
        return (titleText != "" && bodyText != "")
    }
    
    
    // MARK: - Class Method Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the submission button colors.
        submitButton.setTitleColor(AppearanceManager.sharedInstance.red, for: .normal)
        submitButton.setTitleColor(AppearanceManager.sharedInstance.lightTextGrey, for: .disabled)
        
        // Round the UITextField frame.
        titleTextField.layer.cornerRadius = 10.0
        
        // Round the UITextView frame.
        bodyTextView.layer.cornerRadius = 10.0
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
