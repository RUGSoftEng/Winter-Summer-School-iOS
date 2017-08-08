//
//  RGSAnnouncementViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSAnnouncementViewController: RGSBaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {

    // MARK: - Variables & Constants
    
    /// UITableViewCellIdentifier
    let announcementTableViewCellIdentifier: String = "announcementTableViewCellIdentifier"
    
    /// UITableViewCell Custom Height
    let announcementTableViewCellHeight: CGFloat = 64
    
    /// Data for the UITableView
    var announcements: [Announcement]! {
        didSet (oldAnnouncements) {
            if (announcements != nil) {
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - Outlets
    
    /// The UITableView.
    @IBOutlet weak var tableView: UITableView!
    
    /// The RGSLoadingIndicatorView.
    @IBOutlet weak var loadingIndicator: RGSLoadingIndicatorView!
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (true, "Announcements")
    }
    
    // MARK: - UITableViewDelegate/DataSource Protocol Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (announcements == nil) ? 0 : announcements!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return announcementTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        tableView.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: "RGSAnnouncementEventViewController", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RGSAnnouncementTableViewCell = tableView.dequeueReusableCell(withIdentifier: announcementTableViewCellIdentifier) as! RGSAnnouncementTableViewCell
        let announcement: Announcement = announcements[indexPath.row]
        cell.title = announcement.title
        cell.poster = announcement.poster
        cell.date = announcement.date
        return cell
    }
    
    
    // MARK: - UITableView ScrollView Delegate Protocol Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGPoint = scrollView.contentOffset
        if (offset.y <= 0) {
            let progress = CGFloat(offset.y / SpecificationManager.sharedInstance.tableViewContentRefreshOffset)
            loadingIndicator.progress = progress
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let released: CGPoint = scrollView.contentOffset
        if (released.y <= SpecificationManager.sharedInstance.tableViewContentRefreshOffset) {
            print("Should reload content now!")
            refreshModelData()
        }
    }
    
    
    // MARK: - Private Class Methods
    
    func refreshModelData() {
        let url: String = NetworkManager.sharedInstance.URLForAnnouncements()
        NetworkManager.sharedInstance.makeGetRequest(url: url, onCompletion: {(data: Data?) -> Void in
            let fetched: [Announcement]? = DataManager.sharedInstance.parseDataToAnnouncements(data: data)
            DispatchQueue.main.async {
                if (fetched == nil) {
                    
                } else {
                    self.announcements = fetched
                }
            }
        })
    }
    
    // MARK: - Notifications
    
    /// Handler for when the app is about to suspend execution
    override func applicationWillResignActive(notification: NSNotification) {
        super.applicationWillResignActive(notification: notification)
        
        if (announcements != nil) {
            print("Saving announcement data...")
            DataManager.sharedInstance.saveAnnouncementData(announcements: announcements)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Extract destination ViewController, cell tapped in question.
        let announcementEventViewController: RGSAnnouncementEventViewController = segue.destination as! RGSAnnouncementEventViewController
        let indexPath: IndexPath = tableView.indexPath(for: sender as! RGSAnnouncementTableViewCell)!
        
        // Set announcement to be displayed to that corresponding to the tapped cell.
        let announcement = announcements[indexPath.row]
        announcementEventViewController.announcement = announcement
    }
    
    // MARK: - Class Method Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTheme()
        
        // Register Custom UITableViewCell
        let announcementTableViewCellNib: UINib = UINib(nibName: "RGSAnnouncementTableViewCell", bundle: nil)
        tableView.register(announcementTableViewCellNib, forCellReuseIdentifier: announcementTableViewCellIdentifier)
        
        // Attempt to load Announcement Model from DataBase
        if let announcements = DataManager.sharedInstance.loadAnnouncementData() {
            self.announcements = announcements
        }
        
        // Attempt to refresh Announcement Model by querying the server.
        self.refreshModelData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Flush announcements
        announcements = []
    }
    

}
