//
//  RGSForumThreadViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 1/14/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import UIKit


class RGSForumThreadViewController: RGSBaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, RGSAuthenticatableObjectDelegate {
    
    // MARK: - Variables and Constants
    
    /// The forum thread object.
    var forumThread: RGSForumThreadDataModel!
    
    /// The forum comments model.
    var forumComments: [RGSForumCommentDataModel]!
    
    /// ForumContentTableViewCell identifier.
    var contentTableViewCellIdentifier: String = "contentTableViewCellIdentifier"
    
    /// ForumCommentTableViewCell identifier.
    var commentTableViewCellIdentifier: String = "commentTableViewCellIdentifier"
    
    /// ForumInputTableViewCell identifier.
    var inputTableViewCellIdentifier: String = "inputTableViewCellIdentifier"
    
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
        if (section < 2) {
            return 1
        }
        return (forumComments == nil) ? 0 : forumComments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            return initializeForumContentTableViewCell(with: forumThread)
        } else if (indexPath.section == 1) {
            return initializeForumInputTableViewCell(isAuthenticated: SecurityManager.sharedInstance.getUserAuthenticationState())
        } else {
            return initializeForumCommentTableViewCell(with: forumComments[indexPath.row])
        }
    }
    
    // MARK: - UITableView Editing/Deletion Methods
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // Only comment cells may be edited.
        if (indexPath.section > 1) {
            let authenticated = SecurityManager.sharedInstance.getUserAuthenticationState()
            let userID = SecurityManager.sharedInstance.userIdentity
            
            // A comment cell may be edited on condition that the user is authenticated.
            let forumComment = forumComments[indexPath.row]
            
            return (authenticated && userID == forumComment.authorID)
        }
        
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            // Extract comment.
            let comment: RGSForumCommentDataModel = forumComments[indexPath.row]
            
            // Dispatch DELETE request.
            self.dispatchCommentDeleteRequest(comment.id!)
            
            // Remove entry from data source.
            forumComments.remove(at: indexPath.row)
            
            // Animate removal.
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    // MARK: - UITableView ScrollView Delegate Protocol Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGPoint = scrollView.contentOffset
        
        // If a first responder is active, close it: (Keyboard in case of adding a comment).
        if let inputTableViewCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? RGSForumInputTableViewCell {
            inputTableViewCell.commentTextField.resignFirstResponder()
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
            suspendTableViewInteraction(contentOffset: CGPoint(x: offset.x, y: SpecificationManager.sharedInstance.tableViewContentReloadOffset))
            
            // Manual refresh.
            refreshModelData(automatic: false)
        }
    }
    
    // MARK: - Private Class Methods: UITableView
    
    /// Initialize a content view cell: The thread content.
    func initializeForumContentTableViewCell (with thread: RGSForumThreadDataModel) -> RGSForumContentTableViewCell {
        var cell: RGSForumContentTableViewCell? = tableView.dequeueReusableCell(withIdentifier: contentTableViewCellIdentifier) as? RGSForumContentTableViewCell
        
        if (cell == nil) {
            cell = RGSForumContentTableViewCell()
        }
        
        cell?.title = thread.title
        cell?.body = thread.body
        return cell!
    }
    
    /// Initialize a comment view cell: A comment on the thread.
    func initializeForumCommentTableViewCell (with comment: RGSForumCommentDataModel) -> RGSForumCommentTableViewCell {
        var cell: RGSForumCommentTableViewCell? = tableView.dequeueReusableCell(withIdentifier: commentTableViewCellIdentifier) as? RGSForumCommentTableViewCell
        
        if (cell == nil) {
            cell = RGSForumCommentTableViewCell()
        }
        
        cell?.author = comment.author
        cell?.date = comment.date
        cell?.body = comment.body
        cell?.authorImage = comment.image
        
        return cell!
    }
    
    /// Initialize an input view cell: A cell for authenticating to the forum and submitting comments.
    func initializeForumInputTableViewCell (isAuthenticated: Bool) -> RGSForumInputTableViewCell {
        var cell: RGSForumInputTableViewCell? = tableView.dequeueReusableCell(withIdentifier: inputTableViewCellIdentifier) as? RGSForumInputTableViewCell

        if (cell == nil) {
            cell = RGSForumInputTableViewCell()
        }
        
        // Set self as authenticatable delegate.
        cell?.delegate = self
        cell?.isAuthenticated = isAuthenticated
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
    
    // MARK: - RGSAuthenticatableObjectDelegate Delegate Methods
    
    /// Method for when user invokes authentication button.
    func userDidRequestAuthentication(sender: UITableViewCell) -> Void {
        
        // Initialize and present the authentication view controller.
        let authViewController = SecurityManager.sharedInstance.authenticationUI!.authViewController()
        present(authViewController, animated: true, completion: nil)
    }
    
    /// Method for when user invokes deauthentication button.
    func userDidRequestDeauthentication (sender: UITableViewCell) -> Void{
        
        // Signal to SecurityManager to sign the user out.
        SecurityManager.sharedInstance.deauthenticateUser()
    }
    
    /// Method for when the user submits content.
    /// contentString: - A string composing the body of the submitted content.
    func userDidSubmitContent (contentString: String?, sender: UITableViewCell) -> Void {
        if let comment = contentString {
            dispatchCommentPostRequest(comment)
        }
    }
    
    // MARK: - Private Class Methods: AlertControllers
    
    /// Presents an error message to the user.
    /// - message: The message which will appear beneath the title.
    func displayNetworkActionAlert (_ message: String) {
        let alertController = ActionManager.sharedInstance.getActionSheet(title: "Network Anomaly", message: message, dismissMessage: "Okay")
        self.present(alertController, animated: false, completion: nil)
    }
    
    // MARK: - Notifications
    
    /// Handler for changes to user authentication state.
    func userAuthenticationStateDidChange (_ notification: Notification) -> Void {

        // Update inputCell appearance.
        if let inputTableViewCell = tableView.cellForRow(at: IndexPath(row: 0, section: 1)) as? RGSForumInputTableViewCell {
            inputTableViewCell.isAuthenticated = (notification.userInfo != nil)
        }
        
        // Reload inputCell.
        tableView.reloadSections(IndexSet.init(integer: 1), with: .middle)
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
        
        // Register for User Authentication State Change notifications.
        let notificationName = Notification.Name(rawValue: "NSUserAuthenticationStateChange")
        NotificationCenter.default.addObserver(self, selector: #selector(userAuthenticationStateDidChange(_:)), name: notificationName, object: nil)
        
        // Attempt to refresh ForumComment Model by querying the server.
        self.refreshModelData();
    }
    
}

extension RGSForumThreadViewController {
    
    // MARK: - Network GET Requests.
    
    /// Dispatches a task to perform a GET request for new model data.
    /// Automatically invokes secondary model data GET request.
    func refreshModelData(automatic: Bool = true) {
        
        // If popup was dismissed, undo upon manual refresh.
        if (automatic == false) {
            NetworkManager.sharedInstance.userAcknowledgedNetworkError = false
        }
        
        let url: String = NetworkManager.sharedInstance.URLWithOptions(url: NetworkManager.sharedInstance.URLForForumComments(), options: "parentThread=\(forumThread.id!)")
        NetworkManager.sharedInstance.makeGetRequest(url: url, onCompletion: {(data: Data?, response: URLResponse?) -> Void in
            let fetched: [RGSForumCommentDataModel]? = DataManager.sharedInstance.parseForumCommentData(data: data)
            sleep(1)
            DispatchQueue.main.async {
                self.forumComments = fetched
                self.tableView.reloadData(in: 2, with: .fade)
                self.resumeTableViewInteraction()
                self.displayWarningPopupIfNeeded(animated: true)
        
                // Try to update images
                if (self.forumComments != nil) {
                    self.refreshSecondaryModelData(model: self.forumComments)
                }
           }
        })
    }
    
    /// Dispatches a task to perform a GET request for all secondary resources.
    /// - model: An array of data models to update.
    func refreshSecondaryModelData (model: [RGSForumCommentDataModel]) -> Void {
        
        // Start Network Activity Indicator.
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Dispatch asychronous dataTask.
        DispatchQueue.global().async {
            var resource: [UIImage?] = []
            
            // Retrieve Resources: Ensure models are only read.
            for item in model {
                
                guard
                    let resourceURL = item.imagePath,
                    let imageData = URLSession.shared.synchronousDataTask(with: URL(string: resourceURL)!).0,
                    let image = UIImage(data: imageData)
                else {
                    resource.append(AppearanceManager.sharedInstance.profilePlaceholderImage)
                    continue
                }
                
                resource.append(image)
            }
            
            // Dispatch task to Grand Central: Required for UI updates.
            DispatchQueue.main.async {
                
                // Stop Network Activity Indicator.
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Map changes to models.
                for (i, item) in model.enumerated() {
                    item.image = resource[i]
                }
                self.tableView.reloadData(in: 2, with: .fade)
            }
            
        }
    }
    
    // MARK: - Network POST Requests.
    
    /// Dispatches a task to perform a POST request to the application server.
    /// Presents an alertController on failure.
    func dispatchCommentPostRequest (_ comment: String) {
        
        // Extract Keys.
        let keys: [String: String] = DataManager.sharedInstance.getKeyMap(for: "commentFormKeys")
        
        // Construct POST request body.
        var hashMap: [String: String] = [:]
        hashMap[keys["body"]!] = comment
        hashMap[keys["author"]!] = SecurityManager.sharedInstance.userDisplayName
        hashMap[keys["authorId"]!] = SecurityManager.sharedInstance.userIdentity
        hashMap[keys["imagePath"]!] = SecurityManager.sharedInstance.userImageURL
        hashMap[keys["parentThread"]!] = forumThread.id
        
        let bodyData: String = NetworkManager.sharedInstance.queryStringFromHashMap(map: hashMap)
        
        // Dispatch POST request.
        let data = bodyData.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let url = NetworkManager.sharedInstance.URLForForumComments()
        NetworkManager.sharedInstance.makePostRequest(url: url, data: data, onCompletion: {(_, response: URLResponse?) -> Void in
            
            // Fail if no response.
            DispatchQueue.main.async {
                if response == nil || (response as! HTTPURLResponse).statusCode != 200 {
                    self.displayNetworkActionAlert("Unable to submit comment!")
                } else {
                    self.refreshModelData()
                }
            }
            
        })
    }
    
    // MARK: - Network DELETE Requests.
    
    /// Dispatches a task to perform a DELETE request to the application server.
    /// Presents an alertController on failure.
    /// - commentId: The ID of the comment to be deleted.
    func dispatchCommentDeleteRequest (_ commentId: String) {
        
        // Get keys.
        let keys: [String: String] = DataManager.sharedInstance.getKeyMap(for: "commentDeleteKeys")
        
        // Construct DELETE request URL.
        let url: String = NetworkManager.sharedInstance.URLWithOptions(url: NetworkManager.sharedInstance.URLForForumComments(), options: "\(keys["id"]!)=\(commentId)")
        
        // Dispatch DELETE request.
        NetworkManager.sharedInstance.makeDeleteRequest(url: url, onCompletion: {(_, response: URLResponse?) -> Void in
            
            // Fail if no response.
            DispatchQueue.main.async {
                if response == nil || (response as! HTTPURLResponse).statusCode != 200 {
                    self.displayNetworkActionAlert("Unable to delete comment!")
                } else {
                    self.refreshModelData()
                }
            }
        })
    }
}


