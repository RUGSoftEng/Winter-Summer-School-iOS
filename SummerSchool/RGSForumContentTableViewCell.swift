//
//  RGSForumContentTableViewCell
//  SummerSchool
//
//  Created by Charles Randolph on 1/14/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import UIKit

class RGSForumContentTableViewCell: UITableViewCell {
    
    // MARK: - Variables & Constants
    
    // The title of the forum thread.
    var title: String? {
        didSet (oldTitle) {
            if (title != nil) {
                titleLabel.text = title
            }
        }
    }
    
    // The body of the forum thread.
    var body: String? {
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
    
    // MARK: - Outlets
    
    /// The label containing the thread title.
    @IBOutlet weak var titleLabel: UILabel!
    
    /// The label containing the thread bodu.
    @IBOutlet weak var bodyTextView: UITextView!
    
    // MARK: - Class Method Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Round the textView.
        bodyTextView.layer.cornerRadius = 10.0
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    convenience init? (title: String, body: String, reuseIdentifier: String?) {
        self.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        // Set title, body.
        self.title = title
        self.body = body
    }
    
}
