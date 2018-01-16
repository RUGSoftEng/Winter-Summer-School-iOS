//
//  RGSForumViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

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
        
        return cell
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
            }
        })
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Flush forumThreads
        forumThreads = []
    }
    
}
