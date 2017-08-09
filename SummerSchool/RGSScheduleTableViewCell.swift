//
//  RGSScheduleTableViewCell.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/10/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSScheduleTableViewCell: UITableViewCell {
    
    // MARK: - Variables and Constants
    
    /// Event startDate.
    var startDate: Date? {
        didSet (oldDate) {
            if (startDate != nil && startDate != oldDate) {
                let hoursAndMinutesString: String? = DateManager.sharedInstance.dateToISOString(startDate!, format: .hoursAndMinutesFormat)
                startDateLabel.text = hoursAndMinutesString
            }
        }
    }
    
    /// Event title.
    var title: String? {
        didSet (oldTitle) {
            if (title != nil && title != oldTitle) {
                titleLabel.text = title
            }
        }
    }
    
    /// Event address.
    var address: String? {
        didSet (oldAddress) {
            if (address != nil && address != oldAddress) {
                addressLabel.text = address
            }
        }
    }
    
    // MARK: - Outlets
    
    /// Day Label
    @IBOutlet weak var startDateLabel: UILabel!
    
    /// Date Label
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Event count Label
    @IBOutlet weak var addressLabel: UILabel!
    

    // MARK: - Class Method Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
