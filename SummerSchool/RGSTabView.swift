//
//  RGSTabView.swift
//  SummerSchool
//
//  Created by Charles Randolph on 8/7/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

protocol RGSTabViewDelegate {
    
    /// Informs the delegate of a change to the tab selection.
    func didSelectTab(tab: UIButton, withTag: Int)
}

class RGSTabView: UIView {
    
    // MARK: - Variables & Constants
    
    /// The delegate.
    var delegate: RGSTabViewDelegate!
    
    /// The tag for the currently selected tab.
    private var selectedTag: Int = 0
    
    /// The contentView to contain the loaded NIB view stack.
    var contentView: UIView!
    
    /// The text color for the selected tab.
    var selectedTextColor: UIColor = UIColor.white
    
    /// The text color for the deselected tab.
    var deselectedTextColor: UIColor = UIColor.black
    
    /// The background color for the selected tab.
    var selectedBackgroundColor: UIColor = UIColor.black
    
    /// The background color for the deselected tab.
    var deselectedBackgroundColor: UIColor = UIColor.white
    
    /// Computed Nib Name variable
    var nibName: String {
        return String(describing: type(of: self))
    }
    
    // MARK: - Outlets
    
    @IBOutlet var tabButtons: [UIButton]!
    
    // MARK: - Actions
    
    @IBAction func didPressTabButton(_ sender: UIButton) {
        let tag = sender.tag
        if (tag != selectedTag) {
            setSelectedTab(tag: tag)
            
            if let delegate = delegate {
                delegate.didSelectTab(tab: sender, withTag: tag)
            }
        }
        selectedTag = tag
    }
    
    // MARK: - Private Class Methods
    
    func setTitles(_ titles: [String]) {
        if titles.count == tabButtons.count {
            for (index, title) in titles.enumerated() {
                tabButtons[index].setTitle(title, for: .normal)
            }
        } else {
            print("RGSTabView: Titles must map 1:1 to the number of tabs.")
        }
    }
    
    func setColors(_ selectedTextColor: UIColor, _ deselectedTextColor: UIColor, _ selectedBackgroundColor: UIColor, _ deselectedBackgroundColor: UIColor) {
        
        // Assign Colors.
        self.selectedTextColor = selectedTextColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self.deselectedTextColor = deselectedTextColor
        self.deselectedBackgroundColor = deselectedBackgroundColor
        
        // Re-render initial tab selection.
        setSelectedTab(tag: selectedTag)
        
        // Set background color
        contentView.backgroundColor = selectedBackgroundColor
    }
    
    func setSelectedTab(tag: Int) {
        
        // Assign Tab Button Colors
        for (index, tabButton) in tabButtons.enumerated() {
            if (index == tag) {
                tabButton.setTitleColor(selectedTextColor, for: .normal)
                tabButton.backgroundColor = selectedBackgroundColor
            } else {
                tabButton.setTitleColor(deselectedTextColor, for: .normal)
                tabButton.backgroundColor = deselectedBackgroundColor
            }
        }

    }
    
    // MARK: - Nib Initializer
    
    func loadViewFromNib() -> Void {
        contentView = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?[0] as! UIView
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = bounds
        addSubview(contentView)
    }
    
    // MARK: - Class Method Overrides
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialize the contentView.
        loadViewFromNib()
        
        // Set the tags in the button array.
        for (index, button) in tabButtons.enumerated() {
            button.tag = index
        }
        
        // Set initial tab selection.
        setSelectedTab(tag: selectedTag)
        
        // Set contentView background color to selected background color.
        contentView.backgroundColor = selectedBackgroundColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize the contentView.
        loadViewFromNib()
        
        // Set the tags in the button array.
        for (index, button) in tabButtons.enumerated() {
            button.tag = index
        }
        
        // Set initial tab selection.
        setSelectedTab(tag: selectedTag)
        
        // Set contentView background color to selected background color.
        contentView.backgroundColor = selectedBackgroundColor
    }
}
