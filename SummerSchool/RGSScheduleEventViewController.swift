//
//  RGSScheduleEventViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/17/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSScheduleEventViewController: RGSBaseViewController {
    
    // MARK: - Variables & Constants
    
    /// The Event Object to be displayed in the View.
    var event: Event!
    
    // MARK: - Outlets
    
    @IBOutlet weak var timesButton: UIButton!
    
    @IBOutlet weak var titlePaddedLabel: RGSPaddedLabel!
    
    @IBOutlet weak var descriptionPaddedLabel: RGSPaddedLabel!
    
    @IBOutlet weak var addressPaddedLabel: RGSPaddedLabel!
    
    // MARK: - Actions
    
    @IBAction func didPressTimesButton(_ sender: UIControl) -> Void {
        print("There is no functionality tied to this right now!")
    }
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowReturnButton() -> Bool {
        return true
    }
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (false, nil)
    }
    
    // MARK: - Private Class Methods
    
    private func configureViews() -> Void {
        
        // Configure Titles
        titlePaddedLabel.title = "Summary"
        descriptionPaddedLabel.title = "Description"
        addressPaddedLabel.title = "Address"
        
        // Configure Contents
        if (event != nil) {
            titlePaddedLabel.content = event.title
            timesButton.setTitle("\(DateManager.sharedInstance.hoursAndMinutesFromDate(event.startDate)!) - \(DateManager.sharedInstance.hoursAndMinutesFromDate(event.endDate)!)", for: UIControlState.normal)
            descriptionPaddedLabel.content = event.description
            
            let urlString: String = ActionManager.sharedInstance.getMapURLString(event.address)
            let linkAttributes: [String: Any] = ActionManager.sharedInstance.getLinkAttributes(urlString)
            let attributedAddress: NSMutableAttributedString = NSMutableAttributedString(string: event.address!, attributes: linkAttributes)
            addressPaddedLabel.contentTextView.attributedText = attributedAddress
        }
    }
    
    
    // MARK: - Class Method Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the Navigation Bar Theme (Mandatory)
        setNavigationBarTheme()
        
        // Configure the contents of the views.
        configureViews()
    }

}
