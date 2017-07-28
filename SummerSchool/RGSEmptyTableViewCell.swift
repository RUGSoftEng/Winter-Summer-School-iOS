//
//  RGSEmptyTableViewCell.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/19/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSEmptyTableViewCell: UITableViewCell {
    
    // MARK: - Variables & Constants
    
    /// Cell title
    var title: String! {
        didSet (oldTitle) {
            if (title != nil && title != oldTitle) {
                titleLabel.text = title
            }
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    
    
    // MARK: - Class Method Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
