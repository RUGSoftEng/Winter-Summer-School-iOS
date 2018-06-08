//
//  RGSForumViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSForumViewController: RGSBaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, RGSAuthenticatableObjectDelegate, RGSContentFormDelegate {
    
    // MARK: - Variables & Constants
    
    /// Content Form Segue Identifier.
    let contentFormSegueIdentifier = "showContentFormViewController"
    
    /// Forum Thread Segue Identifier.
    let forumThreadSegueIdentifier = "showForumThreadViewController"
    
    /// RGSForumThreadTableViewCellIdentifier
    let forumThreadTableViewCellIdentifier: String = "forumThreadTableViewCellIdentifier"
    
    /// RGSForumButtonTableViewCellIdentifier
    let forumButtonTableViewCellIdentifier: String = "forumButtonTableViewCellIdentifier"
    
    /// ForumThread Cell Custom Height
    let forumThreadTableViewCellHeight: CGFloat = 80
    
    /// ForumButton Cell Custom Height
    let forumButtonTableViewCellHeight: CGFloat = 46
    
    /// Data for the UITableView
    var forumThreads: [RGSForumThreadDataModel]! {
        didSet (oldForumThreads) {
            if (forumThreads != nil) {
                print("Got data!")
                print(forumThreads)
            } else {
                forumThreads = oldForumThreads
            }
        }
    }
    
    // MARK: - Outlets
    
    /// The UITableView
    @IBOutlet weak var tableView: UITableView!
    
    /// The RGSLoadingIndicatorView
    @IBOutlet weak var loadingIndicator: RGSLoadingIndicatorView!
    
    // MARK: - Actions
    
    /// Unwind Segue Handle
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (true, "Forum")
    }
    
    // MARK: - UITableViewDelegate/DataSource Protocol Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return (forumThreads == nil) ? 0 : forumThreads!.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (indexPath.section == 0 ? forumButtonTableViewCellHeight : forumThreadTableViewCellHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Selection is disabled for button cells.
        if (indexPath.section != 1) {
            return
        }
        
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        tableView.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: forumThreadSegueIdentifier, sender: cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.section == 0) {
            return initializeForumButtonTableViewCell()
        } else {
            return initializeForumThreadTableViewCell(with: forumThreads[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if (indexPath.section == 1) {
            let thread = forumThreads[indexPath.row]
            return (SecurityManager.sharedInstance.getUserAuthenticationState() && SecurityManager.sharedInstance.userIdentity == thread.authorID)
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        print("forumThread count prior = \(forumThreads.count)")
        
        // Extract thread.
        let thread: RGSForumThreadDataModel = forumThreads.remove(at: indexPath.row)

        print("IndexPath info: section = \(indexPath.section), row = \(indexPath.row)!")
        
        print("forumThread count after = \(forumThreads.count)")
        
        // Animate removal.
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        
        // Dispatch DELETE request.
        self.dispatchThreadDeleteRequest(thread.id!)
    }
    
    // MARK: - UITableView ScrollView Delegate Protocol Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGPoint = scrollView.contentOffset
        
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
    
    // MARK: - Private Class Methods: UITableView
    
    /// Initialize a thread view cell: A thread.
    func initializeForumThreadTableViewCell (with thread: RGSForumThreadDataModel) -> RGSForumThreadTableViewCell {
        var cell: RGSForumThreadTableViewCell? = tableView.dequeueReusableCell(withIdentifier: forumThreadTableViewCellIdentifier) as? RGSForumThreadTableViewCell
        
        if (cell == nil) {
            cell = RGSForumThreadTableViewCell()
        }

        cell?.title = thread.title
        cell?.author = thread.author
        cell?.date = thread.date
        cell?.commentCount = thread.commentCount
        cell?.authorImage = thread.image
        
        return cell!
    }
    
    /// Initialize a button view cell: Buttons for allowing thread posting and signing in/out.
    func initializeForumButtonTableViewCell () -> RGSForumButtonTableViewCell {
        var cell: RGSForumButtonTableViewCell? = tableView.dequeueReusableCell(withIdentifier: forumButtonTableViewCellIdentifier) as? RGSForumButtonTableViewCell
        
        if (cell == nil) {
            cell = RGSForumButtonTableViewCell()
        }
        
        // Set self as authenticatable delegate.
        cell?.delegate = self
        cell?.isAuthenticated = SecurityManager.sharedInstance.getUserAuthenticationState()
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
        print("User did request authentication!")
        
        // Initialize and present the authentication view controller.
        let authViewController = SecurityManager.sharedInstance.authenticationUI!.authViewController()
        present(authViewController, animated: true, completion: nil)
    }
    
    /// Method for when user invokes deauthentication button.
    func userDidRequestDeauthentication (sender: UITableViewCell) -> Void{
        print("User did request deauthentication!")
        
        // Signal to SecurityManager to sign the user out.
        SecurityManager.sharedInstance.deauthenticateUser()
    }
    
    /// Method for when the user submits content.
    /// contentString: - A string composing the body of the submitted content.
    func userDidSubmitContent (contentString: String?, sender: UITableViewCell) -> Void {
        print("User did request to submit thread")
        performSegue(withIdentifier: contentFormSegueIdentifier, sender: self)
    }
    
    // MARK: - RGSContentForm Delegate Methods
    
    /* Submits a content form to be handled by the delegate. Composes of a nonempty title and body */
    func submitContentForm (with title: String, and body: String) -> Void{
        dispatchThreadPostRequest(title, body)
    }
    
    // MARK: - Private Class Methods: AlertControllers
    
    /// Presents an error message to the user.
    /// - message: The message which will appear beneath the title.
    func displayNetworkActionAlert (_ message: String) {
        let alertController = ActionManager.sharedInstance.getActionSheet(title: "Network Anomaly", message: message, dismissMessage: "Okay")
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Notifications
    
    /// Handler for when the app is about to suspend execution
    override func applicationWillResignActive(notification: NSNotification) {
        super.applicationWillResignActive(notification: notification)
        
        if (forumThreads != nil) {
            print("Saving forum threads...")
            RGSForumThreadDataModel.saveDataModel(forumThreads, context: DataManager.sharedInstance.context)
        }
    }
    
    /// Handler for changes to user authentication state.
    func userAuthenticationStateDidChange (_ notification: Notification) -> Void {
        print("RGSForumViewController: Received change of notification state!")
        
        // Update buttonCell appearance.
        if let buttonTableViewCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? RGSForumButtonTableViewCell {
            buttonTableViewCell.isAuthenticated = (notification.userInfo != nil)
        }
        
        // Reload buttonCell.
        tableView.reloadSections(IndexSet.init(integer: 0), with: .middle)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == forumThreadSegueIdentifier) {
            
            // Extract destination ViewController, cell tapped in question.
            let forumThreadViewController: RGSForumThreadViewController = segue.destination as! RGSForumThreadViewController
            let indexPath: IndexPath = tableView.indexPath(for: sender as! RGSForumThreadTableViewCell)!
            
            // Set announcement to be displayed to that corresponding to the tapped cell.
            let forumThread = forumThreads[indexPath.row]
            forumThreadViewController.forumThread = forumThread
        } else {
            
            // Extact destination ViewController.
            let contentFormViewController: RGSContentFormViewController = segue.destination as! RGSContentFormViewController
            
            // Set delegate as self.
            contentFormViewController.delegate = self
        }
    }
    
    
    // MARK: - Class Method Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Try to refresh forum.
        self.refreshModelData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTheme()
        
        // Register Thread UITableViewCell
        let forumThreadTableViewCellNib: UINib = UINib(nibName: "RGSForumThreadTableViewCell", bundle: nil)
        tableView.register(forumThreadTableViewCellNib, forCellReuseIdentifier: forumThreadTableViewCellIdentifier)
        
        // Register Button UITableViewCell
        let forumButtonTableViewCellNib: UINib = UINib(nibName: "RGSForumButtonTableViewCell", bundle: nil)
        tableView.register(forumButtonTableViewCellNib, forCellReuseIdentifier: forumButtonTableViewCellIdentifier)
        
        // Attempt to load ForumThread Model from Core Data.
        if let forumThreads = RGSForumThreadDataModel.loadDataModel(context: DataManager.sharedInstance.context, sort: RGSForumThreadDataModel.sort) {
            self.forumThreads = forumThreads
        }
        
        // Register for User Authentication State Change notifications.
        let notificationName = Notification.Name(rawValue: "NSUserAuthenticationStateChange")
        NotificationCenter.default.addObserver(self, selector: #selector(userAuthenticationStateDidChange(_:)), name: notificationName, object: nil)

        // Attempt to refresh ForumThread Model by querying the server.
        self.refreshModelData();

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Flush forumThreads
        forumThreads = []
    }
    
}


extension RGSForumViewController {
    
    // MARK: - Network Support Methods.
    
    func filtered (model: [RGSForumThreadDataModel], by schoolId: String) -> [RGSForumThreadDataModel] {
        return model.filter({(model: RGSForumThreadDataModel) -> Bool in
            return true
        })
    }
    
    // MARK: - Network GET Requests.
    
    func refreshModelData(automatic: Bool = true) {
        
        // If popup was dismissed, undo upon manual refresh.
        if (automatic == false) {
            NetworkManager.sharedInstance.userAcknowledgedNetworkError = false
        }
        
        let url: String = NetworkManager.sharedInstance.URLForForumThreads()
        NetworkManager.sharedInstance.makeGetRequest(url: url, onCompletion: {(data: Data?, _ : URLResponse?) -> Void in
            let fetched: [RGSForumThreadDataModel]? = DataManager.sharedInstance.parseForumThreadData(data: data)
            sleep(1)
            DispatchQueue.main.async {
                self.forumThreads = fetched
                self.tableView.reloadData(in: 1, with: .fade)
                self.resumeTableViewInteraction()
                self.displayWarningPopupIfNeeded(animated: true)
                
                // Try to update images
                if (self.forumThreads != nil) {
                   self.refreshSecondaryModelData(model: self.forumThreads)
                }
            }
        })
    }
    
    /// Dispatches a task to fetch secondary resources.
    /// - model: An array of data models to update.
    func refreshSecondaryModelData (model: [RGSForumThreadDataModel]) -> Void {
        
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
                print("Reloading secondary data!")
                self.tableView.reloadData(in: 1, with: .fade)
            }
            
        }
    }
    
    // MARK: - Network POST Requests.
    
    /// Dispatches a task to perform a POST request to the application server.
    /// Presents an alertController on failure.
    /// - title: The title of the thread.
    /// - body: The body of the thread.
    func dispatchThreadPostRequest (_ title: String, _ body: String) {

        // Extract keys.
        var keys: [String: String] = DataManager.sharedInstance.getKeyMap(for: "threadFormKeys")
        
        // Construct POST request body.
        var hashMap: [String: String] = [:]
        hashMap[keys["title"]!] = title
        hashMap[keys["body"]!] = body
        hashMap[keys["author"]!] = SecurityManager.sharedInstance.userDisplayName
        hashMap[keys["authorId"]!] = SecurityManager.sharedInstance.userIdentity
        hashMap[keys["imagePath"]!] = SecurityManager.sharedInstance.userImageURL
        hashMap[keys["schoolId"]!] = SpecificationManager.sharedInstance.schoolId
        
        let bodyData: String = NetworkManager.sharedInstance.queryStringFromHashMap(map: hashMap)
        
        // Dispatch POST request.
        let data = bodyData.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let url = NetworkManager.sharedInstance.URLForForumThreads()
        NetworkManager.sharedInstance.makePostRequest(url: url, data: data, onCompletion: {(_, response: URLResponse?) -> Void in
            
            // Fail if no response.
            DispatchQueue.main.async {
                if response == nil || (response as! HTTPURLResponse).statusCode != 200 {
                    self.displayNetworkActionAlert("Unable to submit thread!")
                } else {
                    print("The thread was submitted. Refreshing the model data...")
                    self.refreshModelData()
                }
            }
            
        })
    }
    
    // MARK: - Network PUT Requests.
    
    // MARK: - Network DELETE Requests.
    
    /// Dispatches a task to perform a DELETE request to the application server.
    /// Presents an alertController on failure.
    /// - threadId: The ID of the thread to be deleted.
    func dispatchThreadDeleteRequest (_ threadId: String) {
        
        // Get keys.
        let keys: [String: String] = DataManager.sharedInstance.getKeyMap(for: "threadDeleteKeys")
        
        // Construct DELETE request URL.
        let url: String = NetworkManager.sharedInstance.URLWithOptions(url: NetworkManager.sharedInstance.URLForForumThreads(), options: "\(keys["id"]!)=\(threadId)")
        
        // Dispatch DELETE request.
        NetworkManager.sharedInstance.makeDeleteRequest(url: url, onCompletion: {(_, response: URLResponse?) -> Void in
            
            // Fail if no response.
            DispatchQueue.main.async {
                if (response == nil || (response as! HTTPURLResponse).statusCode != 200) {
                    self.displayNetworkActionAlert("Unable to delete thread!")
                } else {
                    print("The thread deletion was sent! Refreshing the model data...")
                    self.refreshModelData()
                }
            }
        })
    }
}
