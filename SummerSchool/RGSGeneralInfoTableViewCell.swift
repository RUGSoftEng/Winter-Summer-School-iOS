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
    
    /// Post type.
    var isAdmin: Bool = false {
        didSet (oldIsAdmin) {
            if (oldIsAdmin != isAdmin) {
                self.layoutSubviews()
                self.setNeedsDisplay()
            }
        }
    }
    
    // MARK: - Outlets
    
    /// Title label
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Icon ImageView
    @IBOutlet weak var iconImageView: UIImageView!
    
    /// PostTypeLabel view.
    @IBOutlet weak var postLabelView: UIView!
    
    /// PostTypeLabel label.
    @IBOutlet weak var postLabel: UILabel!
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Force subviews to be drawn before changes are made.
        self.layoutIfNeeded()
        
        // If isAdmin: Draw red circle with A symbol. Otherwise draw gray circle with C.
        if (isAdmin) {
            self.postLabel.text = "A"
            self.postLabel.textColor = UIColor.white
            self.postLabelView.backgroundColor = AppearanceManager.sharedInstance.red
        } else {
            self.postLabel.text = "C"
            self.postLabel.textColor = AppearanceManager.sharedInstance.darkGrey
            self.postLabelView.backgroundColor = AppearanceManager.sharedInstance.lightBackgroundGrey
        }
        
        // Round the postLabelView to improve aesthetics.
        self.postLabelView.layer.cornerRadius = self.postLabelView.frame.size.width / 2
        self.postLabelView.layer.masksToBounds = true
        self.postLabelView.clipsToBounds = true
        
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layoutSubviews()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
