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
    
    // MARK: - Outlets
    
    /// Title label
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The Icon ImageView
    @IBOutlet weak var iconImageView: UIImageView!
    
    // MARK: - Class Method Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Configure UIImage
        if let iconImage: UIImage = UIImage(named: "AnnouncementCellIcon") {
            iconImageView.image = iconImage
        }

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
