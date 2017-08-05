//
//  RGSScheduleTableViewHeaderFooterView.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

protocol RGSScheduleTableViewHeaderFooterViewProtocol {
    
    /// Method for toggling the display of the section associated with the header-footer view.
    func toggleSection(header: RGSScheduleTableViewHeaderFooterView, section: Int)
}

class RGSScheduleTableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    // MARK: - Variables & Constants
    
    /// The collapsed state of the header-footer view
    var isCollapsed: Bool = true {
        didSet (oldIsCollapsed) {
            if (isCollapsed != oldIsCollapsed) {
                isCollapsed ? rotateImageView(angle: 0.0) : rotateImageView(angle: -90)
            }
        }
    }
    
    /// The section the header-footer view represents.
    var section: Int = 0
    
    /// The delegate to handle section toggling.
    var delegate: RGSScheduleTableViewHeaderFooterViewProtocol?
    
    /// The title of the header-footer view.
    var title: String! {
        didSet (oldTitle) {
            if (title != nil && title != oldTitle) {
                titleLabel.text = title
            }
        }
    }
    
    /// The image displayed at the right corner of the header-footer view.
    var image: UIImage! {
        didSet (oldImage) {
            if (image != nil) {
                imageView.image = image
            }
        }
    }
    
    // MARK: - Outlets
    
    /// The UILabel for the title of the header-footer view.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The UIImageView for the right-corner image of the header-footer view.
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Private Methods
    
    /// Rotates the imageView by the given angle (in degrees)
    func rotateImageView(angle: Double) {
        self.imageView.rotate(degrees: angle)
    }
    
    /// Method for tapping on the header-footer cell.
    func didTapHeaderFooterView(_ sender: UIGestureRecognizer) {
        print("Did tap header for section \(section)")
        if let delegate = self.delegate, let header = sender.view as? RGSScheduleTableViewHeaderFooterView {
            print("Calling delegate...")
            delegate.toggleSection(header: header, section: header.section)
        }
    }
    
    // MARK: - Class Method Overrides
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Add Tap Gesture Recognizer
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(didTapHeaderFooterView(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Add Tap Gesture Recognizer.
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action:  #selector(didTapHeaderFooterView(_:))))
    }
    
}
