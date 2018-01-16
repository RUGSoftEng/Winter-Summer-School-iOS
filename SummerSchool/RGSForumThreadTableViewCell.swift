//
//  RGSForumThreadTableViewCell.swift
//  SummerSchool
//
//  Created by Charles Randolph on 12/13/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSForumThreadTableViewCell: UITableViewCell {
    
    // MARK: - Variables & Constants
    
    /// The Author's profile image.
    var authorImage: UIImage! {
        didSet (oldAuthorImage) {
            if (authorImage != nil) {
                authorImageView.image = authorImage;
            }
        }
    }
    
    // The posting date of the thread.
    var date: Date! {
        didSet (oldDate) {
            if (date != nil) {
                dateLabel.text = AppearanceManager.compactDateString(for: date)
            }
        }
    }
    
    // The identify of the author.
    var author: String! {
        didSet (oldAuthor) {
            if (author != nil) {
                authorLabel.text = author;
            }
        }
    }
    
    // The title of the forum thread.
    var title: String! {
        didSet (oldTitle) {
            if (title != nil) {
                titleLabel.text = title;
            }
        }
    }
    
    // The number of comments on the forum thread.
    var commentCount: Int! {
        didSet (oldCommentCount) {
            if (commentCount != nil) {
                commentCountLabel.text = "\(commentCount!) comment" + (commentCount == 1 ? "" : "s")
            }
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var authorImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var commentCountLabel: UILabel!
    

    // MARK: - Class Method Overrides.

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Force subviews to be drawn before changes are made.
        self.layoutIfNeeded()
        
        // Round the imageView to improve aesthetics.
        self.authorImageView.layer.cornerRadius = self.authorImageView.frame.size.width / 2
        self.authorImageView.layer.masksToBounds = true
        self.authorImageView.clipsToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
