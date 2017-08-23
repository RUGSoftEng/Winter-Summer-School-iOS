//
//  RGSMessageViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/16/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSMessageViewController: UIViewController {
    
    // MARK: - Variables & Constants
    
    /// The message to present.
    var message: String?
    
    // MARK: - Outlets
    
    /// The message label.
    @IBOutlet weak var messageLabel: UILabel!
    
    // MARK: - Private Class Methods
    
    // MARK: - Class Method Overrides

    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure the MessageLabel to display the message.
        if (message != nil) {
            messageLabel.text = message
        } else {
            messageLabel.text = "An error occured!"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
