//
//  RGSMessageViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/13/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSMessageViewController: UIViewController {
    
    // MARK: - Variables & Constants
    
    var message: String! {
        didSet (oldMessage) {
            if (message != nil && message != oldMessage) {
                messageLabel.text = title
            }
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    // MARK: - Class Method Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
