//
//  RGSForumViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

func installComments (forumThread: RGSForumThreadDataModel) -> Void {
    //let forumThread: RGSForumThreadDataModel = RGSForumThreadDataModel(id: "1", title: "Issuing a formal complaint.", author: "Walter Brattain", authorID: "WB", body: "I'd like to make a formal complaint about Mr.Shockley. For the past year John Bardeen and I have slaved away in our laboratory on what eventually became the point-touch transistor. Countless hours were spent experimenting with Germanium of various purities and electrical currents. Meanwhile, Mr.Shockley spent his time almost entirely preoccupied with his own projects and gave little to no assistance (or even an indication of interest) whatsoever. This is why I find it absolutely unacceptable that he interrupts our established tradition of not stepping on others work by introducing this so called joint transistor during our public release phase. I imagine Mr.Bardeen would agree with me immensely.", imagePath: "https://upload.wikimedia.org/wikipedia/commons/c/c4/Brattain.jpg", date: Date(), comments: [])
    
    let firstComment: RGSForumCommentDataModel = RGSForumCommentDataModel(id: "1", author: "William Shockley", authorID: "WS", body: "Yes, but I still invented the joint transistor. And it's an improvement over the point-touch transistor anyways.", imagePath: "https://www.nobelprize.org/nobel_prizes/physics/laureates/1956/shockley_postcard.jpg", date: Date())
    
    let secondComment: RGSForumCommentDataModel = RGSForumCommentDataModel(id: "2", author: "Walter Brattain", authorID: "WB", body: "It's just ridiculous and not in the spirit of our work environment here at Bell Labs. You just had to try and trump our breakthrough with the point-contact transistor.", imagePath: "https://upload.wikimedia.org/wikipedia/commons/c/c4/Brattain.jpg", date: Date())
    
    let thirdComment: RGSForumCommentDataModel = RGSForumCommentDataModel(id: "3", author: "John Bardeen", authorID: "JB", body: "You also took over a lot of the lecturer roles at our press conferences with regard to the subject...", imagePath: "https://upload.wikimedia.org/wikipedia/commons/4/4a/Bardeen.jpg", date: Date())
    
    let forthComment: RGSForumCommentDataModel = RGSForumCommentDataModel(id: "4", author: "William Shockley", authorID: "WS", body: "Sorry, but I think you both kind of discovered it by brute force. It's not really an original idea you executed. The joint transistor, however, is arguably an original idea.", imagePath: "https://www.nobelprize.org/nobel_prizes/physics/laureates/1956/shockley_postcard.jpg", date: Date())
    
    let fifthComment: RGSForumCommentDataModel = RGSForumCommentDataModel(id: "5", author: "Mervin Kelly", authorID: "9QaYeJ9aWBbc4zWLLrrjxzTAoOT2", body: "That's enough Shockley. Your attitude is grounds for termination.", imagePath: "https://history.aip.org/phn/Photos/kelly_mervin_a5.jpg", date: Date())
    
    forumThread.comments = [firstComment, secondComment, thirdComment, forthComment, fifthComment]
    
}


class RGSForumViewController: RGSBaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, RGSAuthenticatableObjectDelegate {
    
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
                tableView.reloadData()
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
        let thread = forumThreads[indexPath.row]
        
        return (SecurityManager.sharedInstance.getUserAuthenticationState() && SecurityManager.sharedInstance.userIdentity == thread.authorID)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Extract thread.
        let thread: RGSForumThreadDataModel = forumThreads[indexPath.row]
        
        // Dispatch DELETE request.
        self.dispatchThreadDeleteRequest(thread.id!)
        
        // Remove entry from data source.
        forumThreads.remove(at: indexPath.row)
        
        // Animate removal.
        tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
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
        var cell: RGSForumThreadTableViewCell?
        
        if ((cell = tableView.dequeueReusableCell(withIdentifier: forumThreadTableViewCellIdentifier) as! RGSForumThreadTableViewCell?) == nil) {
            cell = RGSForumThreadTableViewCell()
        }

        cell?.title = thread.title
        cell?.author = thread.author
        cell?.date = thread.date
        cell?.commentCount = thread.comments?.count
        cell?.authorImage = thread.image
        
        return cell!
    }
    
    /// Initialize a button view cell: Buttons for allowing thread posting and signing in/out.
    func initializeForumButtonTableViewCell () -> RGSForumButtonTableViewCell {
        var cell: RGSForumButtonTableViewCell?
        
        if ((cell = tableView.dequeueReusableCell(withIdentifier: forumButtonTableViewCellIdentifier) as! RGSForumButtonTableViewCell?) == nil) {
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
            
        }
    }
    
    
    // MARK: - Class Method Overrides

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
        
        
        let forumThread: RGSForumThreadDataModel = RGSForumThreadDataModel(id: "1", title: "Issuing a formal complaint.", author: "Walter Brattain", authorID: "WB", body: "I'd like to make a formal complaint about Mr.Shockley. For the past year John Bardeen and I have slaved away in our laboratory on what eventually became the point-touch transistor. Countless hours were spent experimenting with Germanium of various purities and electrical currents. Meanwhile, Mr.Shockley spent his time almost entirely preoccupied with his own projects and gave little to no assistance (or even an indication of interest) whatsoever. This is why I find it absolutely unacceptable that he interrupts our established tradition of not stepping on others work by introducing this so called joint transistor during our public release phase. I imagine Mr.Bardeen would agree with me immensely.", imagePath: "https://upload.wikimedia.org/wikipedia/commons/c/c4/Brattain.jpg", date: Date(), comments: [])
        self.forumThreads = [forumThread]
        
        // INSTALL DEMO COMMENTS
        installComments(forumThread: forumThreads[0])
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
                self.resumeTableViewInteraction()
                self.displayWarningPopupIfNeeded(animated: true)
                
                // Try to update images
                self.refreshSecondaryModelData(model: self.forumThreads)
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
                if let resourceURL = item.imagePath {
                    let (data, _, _) = URLSession.shared.synchronousDataTask(with: URL(string: resourceURL)!)
                    
                    if let imageData = data, let image = UIImage(data: imageData) {
                        resource.append(image)
                    } else {
                        resource.append(nil)
                    }
                }
            }
            
            // Dispatch task to Grand Central: Required for UI updates.
            DispatchQueue.main.async {
                
                // Stop Network Activity Indicator.
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Map changes to models.
                for (i, item) in model.enumerated() {
                    item.image = resource[i]
                }
                self.tableView.reloadData()
            }
            
        }
    }
    
    // MARK: - Network POST Requests.
    
    // MARK: - Network PUT Requests.
    
    // MARK: - Network DELETE Requests.
    
    /// Dispatches a task to perform a DELETE request to the application server.
    /// Presents an alertController on failure.
    /// - threadId: The ID of the thread to be deleted.
    func dispatchThreadDeleteRequest (_ threadId: String) {
        
        // Construct DELETE request URL.
        let url: String = NetworkManager.sharedInstance.URLWithOptions(url: NetworkManager.sharedInstance.URLForForumThreads(), options: "id=\(threadId)")
        
        // Dispatch DELETE request.
        NetworkManager.sharedInstance.makeDeleteRequest(url: url, onCompletion: {(_, response: URLResponse?) -> Void in
            
            // Extract httpResponse.
            let httpResponse: HTTPURLResponse = response as! HTTPURLResponse
            DispatchQueue.main.async {
                if (httpResponse.statusCode != 200) {
                    self.displayNetworkActionAlert("Unable to delete thread!")
                } else {
                    print("The thread deletion was sent! Refreshing the model data...")
                    self.refreshModelData()
                }
            }
        })
    }
}
