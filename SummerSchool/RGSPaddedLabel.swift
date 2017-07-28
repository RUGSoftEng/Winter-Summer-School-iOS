//
//  RGSPaddedLabel.swift
//  SummerSchool
//
//  Created by Charles Randolph on 7/19/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSPaddedLabel: UIView {
    
    // MARK: - Variables & Constants
    
    var title: String! {
        didSet (oldTitle) {
            if (title != nil && title != oldTitle) {
                titleLabel.text = title
            }
        }
    }
    
    var content: String! {
        didSet (oldContent) {
            if (content != nil && content != oldContent) {
                contentTextView.text = content
            }
        }
    }
    
    /// Contains the custom loaded
    private var contentView: UIView!
    
    /// Computed Nib Name variable
    var nibName: String {
        return String(describing: type(of: self))
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var contentTextView: UITextView!
    
    // MARK: - Nib Initializer
    
    func loadViewFromNib() -> Void {
        contentView = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[0] as! UIView
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        contentTextView.layer.cornerRadius = 10.0
        addSubview(contentView)
    }
    
    // MARK: - Class Method Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }

}
