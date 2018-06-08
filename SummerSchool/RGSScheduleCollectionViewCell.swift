//
//  RGSScheduleCollectionViewCell.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/5/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import UIKit

class RGSScheduleCollectionViewCell: UICollectionViewCell {

    // MARK: - Variables & Constants
    
    /// The date.
    var date: Date! {
        didSet (oldDate) {
            
            /// Extract and set day of the month label.
            monthDayLabel.text = DateManager.sharedInstance.monthDayFromDate(date)
            
            /// Extract and set Month.
            weekdayLabel.text = DateManager.sharedInstance.weekDayFromDate(date)
            
        }
    }
    
    /// The number of events.
    var eventCount: Int = 0 {
        didSet (oldEventCount) {
            
            /// Set the label.
            eventCountLabel.text = "\(eventCount)"
            
            /// Only show the event count and it's background if value > 0.
            let shouldHide: Bool = (eventCount <= 0)
    
            // Show or hide label and background.
            eventCountLabel.isHidden = shouldHide
            eventCountHighlightView.isHidden = shouldHide
        }
    }
    
    // MARK: - Outlets
    
    /// The day of the month label.
    @IBOutlet weak var monthDayLabel: UILabel!
    
    /// The number of events label.
    @IBOutlet weak var eventCountLabel: UILabel!
    
    /// The current weekday.
    @IBOutlet weak var weekdayLabel: UILabel!
    
    /// The banner on which the weekday sits.
    @IBOutlet weak var weekdayLabelView: UIView!
    
    /// The circular highlight of the eventCountLabel.
    @IBOutlet weak var eventCountHighlightView: UIView!
    
    // MARK: - Methods
    
    /// Sets the color scheme. 0 = normal, 1 = highlighted, anything else = muted.
    func setColorScheme (scheme: Int) {
        
        // Highlighted color scheme.
        if (scheme == -1) {
            monthDayLabel.textColor = AppearanceManager.sharedInstance.darkGrey
            weekdayLabelView.backgroundColor = AppearanceManager.sharedInstance.red
            weekdayLabel.textColor = UIColor.white
            return
        }
        
        // Muted color scheme.
        if (scheme == 0) {
            monthDayLabel.textColor = AppearanceManager.sharedInstance.grey
            weekdayLabelView.backgroundColor = UIColor.clear
            weekdayLabel.textColor = AppearanceManager.sharedInstance.grey
            return
        }
        
        // Normal color scheme.
        monthDayLabel.textColor = AppearanceManager.sharedInstance.darkGrey
        weekdayLabelView.backgroundColor = UIColor.clear
        weekdayLabel.textColor = AppearanceManager.sharedInstance.red
        return
    }
    
    // MARK: - Class Method Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Force subviews to be drawn before changes are made.
        self.layoutIfNeeded()
        
        // Round the eventCountHighlightView to improve aesthetics.
        self.eventCountHighlightView.layer.cornerRadius = self.eventCountHighlightView.frame.size.width / 2
        self.eventCountHighlightView.layer.masksToBounds = true
        self.eventCountHighlightView.clipsToBounds = true
        
        // Add a rounded edge to the cell as well.
        self.layer.cornerRadius = 10
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Resize cell to fit.
        self.contentView.autoresizingMask = [.flexibleHeight , .flexibleWidth]
        self.contentView.translatesAutoresizingMaskIntoConstraints = true
    }

}
