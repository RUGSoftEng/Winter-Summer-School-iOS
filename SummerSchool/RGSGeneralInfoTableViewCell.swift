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
    
    /// GeneralInfo Icon
    var category: InfoCategory! {
        didSet (oldCategory) {
            if (category != nil && category != oldCategory) {
                if let iconImage: UIImage = UIImage(named: imageNameForCategory(category: category)) {
                    iconImageView.image = iconImage
                }
            }
        }
    }
    
    // MARK: - Outlets
    
    /// Title label
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Icon ImageView
    @IBOutlet weak var iconImageView: UIImageView!
    
    // MARK: - Private Class Methods
    //Food = 0, Location, Internet, Accomodation, Information
    
    private func imageNameForCategory(category: InfoCategory) -> String {
        switch category {
        case .Food:
            return "FoodIcon"
        case .Location:
            return "LocationIcon"
        case .Internet:
            return "InternetIcon"
        case .Accomodation:
            return "AccomodationIcon"
        default:
            return "InformationIcon"
        }
    }
    
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
