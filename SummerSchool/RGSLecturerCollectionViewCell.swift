//
//  RGSLecturerCollectionViewCell.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/31/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSLecturerCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Variables & Constants
    
    /// The lecturer profile image
    var image: UIImage! {
        didSet(oldImage) {
            if (image != nil) {
                self.imageView.image = image
            }
        }
    }
    
    /// The lecturer name
    var name: String! {
        didSet(oldName) {
            if (name != nil && name != oldName) {
                self.nameLabel.text = name
            }
        }
    }
    
    // MARK: - Outlets
    
    /// The imageView displaying the profile image.
    @IBOutlet weak var imageView: UIImageView!
    
    /// The name label displaying the lecturer name.
    @IBOutlet weak var nameLabel: UILabel!
    
    // MARK: - Class Method Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Round the imageView to improve aesthetics.
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.layer.masksToBounds = true
        self.imageView.clipsToBounds = true
        
        // Add a rounded edge to the cell itself.
        self.layer.cornerRadius = 10
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
