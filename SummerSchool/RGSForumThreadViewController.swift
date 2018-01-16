//
//  RGSForumThreadViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/14/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import UIKit

class RGSForumThreadViewController: RGSBaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, RGSForumInputTableViewCellProtocol {
    
    // MARK: - Variables and Constants
    
    /// The forum thread object.
    var forumThread: RGSForumThreadDataModel!
    
    /// ForumContentTableViewCell identifier.
    var contentTableViewCellIdentifier: String = "contentTableViewCellIdentifier"
    
    /// ForumCommentTableViewCell identifier.
    var commentTableViewCellIdentifier: String = "commentTableViewCellIdentifier"
    
    /// ForumInputTableViewCell identifier.
    var inputTableViewCellIdentifier: String = "inputTableViewCellIdentifier"
    
    /// The current input cell instance.
    var inputTableViewCell: RGSForumInputTableViewCell?
    
    // MARK: - Outlets
    
    /// The UITableView.
    @IBOutlet weak var tableView: UITableView!
    
    /// The RGSLoadingIndicatorView
    @IBOutlet weak var loadingIndicator: RGSLoadingIndicatorView!
    
    // MARK: - UITableView Delegate/DataSource Protocol Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (section < 2) ? 1 : forumThread.comments!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.section == 0) {
            return initializeForumContentTableViewCell(with: forumThread)
        } else if (indexPath.section == 1) {
            return initializeForumInputTableViewCell(isAuthenticated: true)
        } else {
            return initializeForumCommentTableViewCell(with: forumThread.comments![indexPath.row])
        }
    }
    
    // MARK: - UITableView ScrollView Delegate Protocol Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGPoint = scrollView.contentOffset
        
        // If a first responder is active, close it: (Keyboard in case of adding a comment).
        if (inputTableViewCell != nil) {
            inputTableViewCell?.commentTextField.resignFirstResponder()
        }
        
        // If the TableView is enabled, animate reload indicator when tugging. If it is disabled, lock to reload position.
        if (tableView.isUserInteractionEnabled) {
            
            if (offset.y <= 0) {
                let progress = CGFloat(offset.y / SpecificationManager.sharedInstance.tableViewContentRefreshOffset)
                loadingIndicator.progress = progress
            }
            
        } else {
            
            if (offset.y >= SpecificationManager.sharedInstance.tableViewContentReloadOffset) {
                let reloadOffset: CGPoint = CGPoint(x: 0, y: SpecificationManager.sharedInstance.tableViewContentReloadOffset)
                tableView.contentOffset = reloadOffset
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset: CGPoint = scrollView.contentOffset
        if (offset.y <= SpecificationManager.sharedInstance.tableViewContentRefreshOffset) {
            print("Should reload content now!")
            suspendTableViewInteraction(contentOffset: CGPoint(x: offset.x, y: SpecificationManager.sharedInstance.tableViewContentReloadOffset))
            
            // Manual refresh.
            refreshModelData(automatic: false)
        }
    }
    
    // MARK: - RGSForumInputTableViewCell Delegate Methods
    
    /// Method for when user invokes authentication button.
    func userDidRequestAuthentication(sender: RGSForumInputTableViewCell) -> Void {
        print("User did request authentication!")
        sender.setAppearance(authenticated: true)
        sender.setNeedsLayout()
    }
    
    /// Method for when the user submits a comment.
    /// comment: - A string composing of the comment body.
    func userDidSubmitComment (comment: String, sender: RGSForumInputTableViewCell) -> Void {
        print("User did request to submit comment: \(comment)")
    }
    
    // MARK: - Private Class Methods
    
    /// Initialize a content view cell: The thread content.
    func initializeForumContentTableViewCell (with thread: RGSForumThreadDataModel) -> RGSForumContentTableViewCell {
        var cell: RGSForumContentTableViewCell?
        
        if ((cell = tableView.dequeueReusableCell(withIdentifier: contentTableViewCellIdentifier) as! RGSForumContentTableViewCell?) == nil) {
            cell = RGSForumContentTableViewCell()
        }
        
        cell?.title = thread.title
        cell?.body = thread.body
        return cell!
    }
    
    /// Initialize a comment view cell: A comment on the thread.
    func initializeForumCommentTableViewCell (with comment: RGSForumCommentDataModel) -> RGSForumCommentTableViewCell {
        var cell: RGSForumCommentTableViewCell?
        
        if ((cell = tableView.dequeueReusableCell(withIdentifier: commentTableViewCellIdentifier) as! RGSForumCommentTableViewCell?) == nil) {
            cell = RGSForumCommentTableViewCell()
        }
        
        cell?.author = comment.author
        cell?.date = comment.date
        cell?.body = comment.body
        return cell!
    }
    
    /// Initialize an input view cell: A cell for authenticating to the forum and submitting comments.
    func initializeForumInputTableViewCell (isAuthenticated: Bool) -> RGSForumInputTableViewCell {
        var cell: RGSForumInputTableViewCell?
        
        if ((cell = tableView.dequeueReusableCell(withIdentifier: inputTableViewCellIdentifier) as! RGSForumInputTableViewCell?) == nil) {
            cell = RGSForumInputTableViewCell(isAuthenticated: isAuthenticated)
        }
        
        // Set self as input table view cell delegate, and update reference.
        cell?.delegate = self
        inputTableViewCell = cell
        return cell!
    }
    
    func suspendTableViewInteraction(contentOffset offset: CGPoint) {
        tableView.setContentOffset(offset, animated: true)
        tableView.isUserInteractionEnabled = false
        loadingIndicator.startAnimation()
    }
    
    func resumeTableViewInteraction() {
        loadingIndicator.stopAnimation()
        tableView.isUserInteractionEnabled = true
        tableView.setContentOffset(.zero, animated: true)
    }
    
    func refreshModelData(automatic: Bool = true) {
        
        // If popup was dismissed, undo upon manual refresh.
        if (automatic == false) {
            NetworkManager.sharedInstance.userAcknowledgedNetworkError = false
        }
        
        // let url: String = NetworkManager.sharedInstance.URLForAnnouncements()
        // NetworkManager.sharedInstance.makeGetRequest(url: url, onCompletion: {(data: Data?) -> Void in
        //    let fetched: [RGSAnnouncementDataModel]? = DataManager.sharedInstance.parseAnnouncementData(data: data)
        //    sleep(1)
        //    DispatchQueue.main.async {
        //        self.announcements = fetched
        //        self.resumeTableViewInteraction()
        //        self.displayWarningPopupIfNeeded(animated: true)
        //    }
        //})
    }
    
    // MARK: - Superclass Method Overrides
    
    /// Handler for display of title label: Defaults to false
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (true, forumThread.author)
    }
    
    /// Handler for display of return button: Defaults to false
    override func shouldShowReturnButton() -> Bool {
        return true
    }
    
    // MARK: - Class Method Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTheme()
        
        // Register: Content Table View Cell.
        let contentTableViewCell: UINib = UINib(nibName: "RGSForumContentTableViewCell", bundle: nil)
        tableView.register(contentTableViewCell, forCellReuseIdentifier: contentTableViewCellIdentifier)
        
        // Register: Comment Table View Cell.
        let commentTableViewCell: UINib = UINib(nibName: "RGSForumCommentTableViewCell", bundle: nil)
        tableView.register(commentTableViewCell, forCellReuseIdentifier: commentTableViewCellIdentifier)
        
        // Register: Input Table View Cell.
        let inputTableViewCell: UINib = UINib(nibName: "RGSForumInputTableViewCell", bundle: nil)
        tableView.register(inputTableViewCell, forCellReuseIdentifier: inputTableViewCellIdentifier)
        
        // Configure table to do automatic cell sizing.
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
}
