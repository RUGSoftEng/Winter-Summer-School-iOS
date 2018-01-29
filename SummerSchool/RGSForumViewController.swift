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
    
    let fifthComment: RGSForumCommentDataModel = RGSForumCommentDataModel(id: "5", author: "Mervin Kelly", authorID: "MK", body: "That's enough Shockley. Your attitude is grounds for termination.", imagePath: "https://history.aip.org/phn/Photos/kelly_mervin_a5.jpg", date: Date())
    
    forumThread.comments = [firstComment, secondComment, thirdComment, forthComment, fifthComment]
    
}


class RGSForumViewController: RGSBaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    // MARK: - Variables & Constants
    
    /// UITableViewCellIdentifier
    let forumThreadTableViewCellIdentifier: String = "forumThreadTableViewCellIdentifier"
    
    /// UITableViewCell Custom Height
    let forumThreadTableViewCellHeight: CGFloat = 80
    
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (forumThreads == nil) ? 0 : forumThreads!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return forumThreadTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        tableView.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: "RGSForumThreadViewController", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RGSForumThreadTableViewCell = tableView.dequeueReusableCell(withIdentifier: forumThreadTableViewCellIdentifier) as! RGSForumThreadTableViewCell
        let forumThread = forumThreads[indexPath.row]
        
        cell.title = forumThread.title
        cell.author = forumThread.author
        cell.date = forumThread.date
        cell.commentCount = forumThread.comments?.count
        cell.authorImage = forumThread.image
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let authorIdentity: String = forumThreads[indexPath.row].authorID!
        debugPrint("User with identity \(SecurityManager.sharedInstance.userIdentity) is trying to edit a post with author identity \(authorIdentity)")
        return (SecurityManager.sharedInstance.identityIsAuthenticated() && (SecurityManager.sharedInstance.userIdentity == authorIdentity))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // Action for deletion.
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            let alertController: UIAlertController = ActionManager.sharedInstance.getRemoveActionSheet(title: "Forum Thread Deletion", message: "Are you sure you want to delete this thread?", dismissMessage: "I am", handler: {(_: UIAlertAction) -> Void in
                self.forumThreads.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            })
            present(alertController, animated: true, completion: nil)
        }
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
    
    
    // MARK: - Private Class Methods
    
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
    
    // MARK: - Notifications
    
    /// Handler for when the app is about to suspend execution
    override func applicationWillResignActive(notification: NSNotification) {
        super.applicationWillResignActive(notification: notification)
        
        if (forumThreads != nil) {
            print("Saving forum threads...")
            RGSForumThreadDataModel.saveDataModel(forumThreads, context: DataManager.sharedInstance.context)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Extract destination ViewController, cell tapped in question.
        let forumThreadViewController: RGSForumThreadViewController = segue.destination as! RGSForumThreadViewController
        let indexPath: IndexPath = tableView.indexPath(for: sender as! RGSForumThreadTableViewCell)!
        
        // Set announcement to be displayed to that corresponding to the tapped cell.
        let forumThread = forumThreads[indexPath.row]
        forumThreadViewController.forumThread = forumThread
    }
    
    
    // MARK: - Class Method Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTheme()
        
        // Register Custom UITableViewCell
        let forumTableViewCellNib: UINib = UINib(nibName: "RGSForumThreadTableViewCell", bundle: nil)
        tableView.register(forumTableViewCellNib, forCellReuseIdentifier: forumThreadTableViewCellIdentifier)
        
        // Attempt to load ForumThread Model from Core Data.
        if let forumThreads = RGSForumThreadDataModel.loadDataModel(context: DataManager.sharedInstance.context, sort: RGSForumThreadDataModel.sort) {
            self.forumThreads = forumThreads
        }

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
