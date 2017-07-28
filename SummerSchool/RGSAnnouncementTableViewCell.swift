//
//  RGSAnnouncementTableViewCell.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/27/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSAnnouncementTableViewCell: UITableViewCell {
    
    // MARK: - Variables & Constants
    
    /// Announcement title
    var title: String? {
        didSet (oldTitle) {
            if (title != nil && title != oldTitle) {
                titleLabel.text = title
            }
        }
    }
    
    /// Announcement poster
    var poster: String? {
        didSet (oldPoster) {
            if (poster != nil && poster != oldPoster) {
                posterLabel.text = "By " + poster!
            }
        }
    }
    
    /// Announcement date
    var date: Date? {
        didSet (oldDate) {
            if (date != nil && date != oldDate) {
                let dateString: String = DateManager.sharedInstance.dateToISOString(date, format: .announcementDateFormat)!
                dateLabel.text = dateString
            }
        }
    }
    
    // MARK: - Outlets
    
    /// Title label
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Poster label
    @IBOutlet weak var posterLabel: UILabel!
    
    /// Date label
    @IBOutlet weak var dateLabel: UILabel!
    
    // MARK: - Class Method Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
