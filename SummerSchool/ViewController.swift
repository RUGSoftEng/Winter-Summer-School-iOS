//
//  ViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 5/19/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var numberField: UITextField!
    
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var rightSwitch: UISwitch!
    @IBOutlet weak var leftSwitch: UISwitch!
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction func textFieldDoneEditing (sender: UITextField) -> Void {
        sender.resignFirstResponder()
    }
    
    @IBAction func backgroundTap (sender: UIControl) -> Void {
        nameField.resignFirstResponder()
        numberField.resignFirstResponder()
    }
    
    @IBAction func sliderChanged(_ sender: UISlider) -> Void {
        let value = lroundf(sender.value)
        sliderLabel.text = "\(value)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sliderLabel.text = "50"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        let setting = sender.isOn
        leftSwitch.setOn(setting, animated: true)
        rightSwitch.setOn(setting, animated: false)
    }

    @IBAction func toggleControls(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0) {
            leftSwitch.isHidden = false
            rightSwitch.isHidden = false
            button.isHidden = true
        } else {
            leftSwitch.isHidden = true
            rightSwitch.isHidden = true
            button.isHidden = false
        }

        
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        let controller = UIAlertController(title: "Delete comment?", message: "This action can't be undone", preferredStyle: .actionSheet)
        
        let confirmAction = UIAlertAction(title: "Yes, delete it", style: .destructive, handler:
        { action in
            let msg = (self.nameField.text?.isEmpty)! ? "Removed" : "Removed \(self.nameField.text!)"
            
            let responseController = UIAlertController(title: "Done", message: msg, preferredStyle: .alert)
            
            let dismissAction = UIAlertAction(title: "Close", style: .cancel, handler: nil)
            
            responseController.addAction(dismissAction)
            
            self.present(responseController, animated: true, completion: nil)
        })
        
        let abortAction = UIAlertAction(title: "Abort", style: .cancel, handler: nil)
        
        controller.addAction(confirmAction)
        controller.addAction(abortAction)
        
        if let ppc = controller.popoverPresentationController {
            ppc.sourceView = sender
            ppc.sourceRect = sender.bounds
        }
        
        present(controller, animated: true, completion: nil)
    }
}

