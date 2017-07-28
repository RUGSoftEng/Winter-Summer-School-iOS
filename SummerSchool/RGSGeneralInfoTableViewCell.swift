//
//  RGSGeneralInfoTableViewCell.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/27/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSGeneralInfoTableViewCell: UITableViewCell {
    
    // MARK: - Variables & Constants
    
    /// GeneralInfo title
    var title: String! {
        didSet (oldTitle) {
            if (title != nil && title != oldTitle) {
                titleLabel.text = title
            }
        }
    }
    
    /// GeneralInfo Description
    var itemDescription: String! {
        didSet (oldItemDescription) {
            if (itemDescription != nil && itemDescription != oldItemDescription) {
                descriptionLabel.text = itemDescription
            }
        }
    }
    
    // MARK: - Outlets
    
    /// Title label
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Description label
    @IBOutlet weak var descriptionLabel: UILabel!
    
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
