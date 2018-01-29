//
//  RGSForumCommentTableViewCell.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/15/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import UIKit

class RGSForumCommentTableViewCell: UITableViewCell {
    
    // MARK: - Variables & Constants
    
    /// The comment author.
    var author: String! {
        didSet (oldAuthor) {
            if (author != nil) {
                self.authorLabel.text = author
            }
        }
    }
    
    /// The date of the comment.
    var date: Date! {
        didSet (oldDate) {
            if (date != nil) {
                self.dateLabel.text = AppearanceManager.compactDateString(for: date)
            }
        }
    }
    
    /// The comment body.
    var body: String! {
        didSet (oldBody) {
            if (body != nil) {
                do {
                    bodyTextView.attributedText = try NSAttributedString(HTMLString: body!, font: bodyTextView.font)
                } catch {
                    bodyTextView.text = body
                }
            }
        }
    }
    
    /// The comment author image.
    var authorImage: UIImage! {
        didSet (oldAuthorImage) {
            if (authorImage != nil) {
                authorImageView.image = authorImage
            }
        }
    }
    
    // MARK: - Outlets
    
    /// The author profile image.
    @IBOutlet weak var authorImageView: UIImageView!
    
    /// The label containing the author.
    @IBOutlet weak var authorLabel: UILabel!
    
    /// The label containing the date.
    @IBOutlet weak var dateLabel: UILabel!
    
    /// The textView containing the body.
    @IBOutlet weak var bodyTextView: UITextView!
    
    // MARK: - Class Method Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Force subviews to be drawn before changes are made.
        self.layoutIfNeeded()
        
        // Round the textView.
        bodyTextView.layer.cornerRadius = 10.0
        
        // Round the imageView to improve aesthetics.
        self.authorImageView.layer.cornerRadius = self.authorImageView.frame.size.width / 2
        self.authorImageView.layer.masksToBounds = true
        self.authorImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
