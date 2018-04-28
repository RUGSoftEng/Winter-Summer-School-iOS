//
//  RGSScheduleViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSScheduleViewController: RGSBaseViewController, UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables & Constants
    
    /// The current day.
    var now: Date {
        return Date()
    }
    
    /// The current week for which content is being displayed in the tableView
    var week: Int = 0
    
    /// UITableViewCell Identifier
    let scheduleTableViewCellIdentifier: String = "scheduleTableViewCellIdentifier"
    
    /// Empty UITableViewCell Identifier
    let scheduleEmptyTableViewCellIdentifier: String = "scheduleEmptyTableViewCellIdentifier"
    
    /// Data for the UITableView
    //var events: [RGSEventDataModel]? {
    //    didSet (oldEvents) {
    //        print("Got data: \(events?.count) events!")
    //        let sections = IndexSet(integersIn: 0...self.tableView.numberOfSections - 1)
    //        tableView.reloadSections(sections, with: .automatic)
    //    }
    //}

    // Data for the UITableView
    var events: [[RGSEventDataModel]] = [[], [], [], [], [], [], []]
    
    // MARK: - Outlets
    
    /// The UITableView
    @IBOutlet weak var tableView: UITableView!
    
    /// The RGSLoadingIndicatorView
    @IBOutlet weak var loadingIndicator: RGSLoadingIndicatorView!
    
    // MARK: - Actions
    
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (true, "Schedule")
    }
    
    // MARK: - UITableViewDelegate/DataSource Protocol Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // A section for each of the next seven days, starting from the current day.
        return 7
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // If the section is zero (today), simply return that instead.
        if (section == 0) {
            return "Today"
        }
        
        // Otherwise, compute the date "section" number of days into the future.
        let sectionDate = DateManager.sharedInstance.startOfDay(in: section, from: now)
        return DateManager.sharedInstance.dateToISOString(sectionDate, format: .weekdayDateFormat)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // If there aren't any events in this section's cell, then return 1 for "empty" cell.
        if (events[section].count == 0) {
            return 1
        }
        
        // Otherwise return the number of events for the section.
        return events[section].count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Disregard taps to the empty cell.
        if (events[indexPath.section].count == 0) {
            return
        }

        let cell: RGSScheduleTableViewCell = tableView.cellForRow(at: indexPath) as! RGSScheduleTableViewCell
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "RGSScheduleEventViewController", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // If no events, return "empty" cell.
        if (events[indexPath.section].count == 0) {
            let cell: RGSEmptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: scheduleEmptyTableViewCellIdentifier) as! RGSEmptyTableViewCell
            return cell
        }
        
        
        let cell: RGSScheduleTableViewCell = tableView.dequeueReusableCell(withIdentifier: scheduleTableViewCellIdentifier, for: indexPath) as! RGSScheduleTableViewCell
        let event: RGSEventDataModel = events[indexPath.section][indexPath.row]
        cell.startDate = event.startDate
        cell.title = event.title
        cell.address = event.location
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
            
            // Manual refresh
            refreshModelWithDataForWeeks(automatic: false, [0,1])
        }
    }
    
    // MARK: - Private Class Methods
    
    // Coalesces the events object into one superset. 
    func coalescedEvents () -> [RGSEventDataModel] {
        var all: [RGSEventDataModel] = []
        for set in events {
            all += set
        }
        return all
    }
    
    // Merges a set of events into the event structure. Favors latest entry if existing one is found with identical ID. 
    func mergeEventSet (_ set: [RGSEventDataModel]?) {
        
        // Ignore nil sets.
        if set == nil {
            return
        }
        
        // Iterate over each section. If there's nothing new for that section, leave it be. 
        // If there is, replace it entirely.
        for s in 0...6 {
            
            // Extract a set of events that may potentially replace those in that section.
            let new = eventsForSection(section: s, in: set!).filter(RGSEventDataModel.filter).sorted(by: RGSEventDataModel.sort)
            
            // If there's nothing new, then ignore.
            if (new.count == 0) {
                continue
            }
            
            // Otherwise replace the current set with the new set.
            self.events[s] = new
        }
        
        // Reload tableview.
        let sections = IndexSet(integersIn: 0...self.tableView.numberOfSections - 1)
        tableView.reloadSections(sections, with: .automatic)
    }

    // Returns the number of events for a given section.
    func eventsForSection (section: Int, in set: [RGSEventDataModel]) -> [RGSEventDataModel] {
        let from: Date = DateManager.sharedInstance.startOfDay(in: section, from: now)
        let to: Date = DateManager.sharedInstance.endOfDay(for: from)
        return eventsInRange(from: from, to: to, in: set)
    }
    
    // Returns the number of events that lie within a specific date range.
    func eventsInRange (from: Date, to: Date, in set: [RGSEventDataModel]) -> [RGSEventDataModel] {
        return set.filter({(e: RGSEventDataModel) -> Bool in
            return (e.startDate! >= from && e.startDate! < to)
        })
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
    
    // MARK: - Notifications
    
    /// Handler for when the App is about to suspend execution.
    override func applicationWillResignActive(notification: NSNotification) {
        super.applicationWillResignActive(notification: notification)
        
        // Save events.
        print("Saving schedule data...")
        RGSEventDataModel.saveDataModel(coalescedEvents(), context: DataManager.sharedInstance.context)
    }
    
    
    // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Extract destination ViewController, cell tapped in question.
        let scheduleEventViewController: RGSScheduleEventViewController = segue.destination as! RGSScheduleEventViewController
        let indexPath: IndexPath = tableView.indexPath(for: sender as! RGSScheduleTableViewCell)!
        
        // Set event to be displayed to that corresponding to the tapped cell.

        let event: RGSEventDataModel = events[indexPath.section][indexPath.row]
        scheduleEventViewController.event = event
     }
    
    
    // MARK: - Class Method Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTheme()
        
        // Register custom UITableViewCell
        let scheduleTableViewCellNib: UINib = UINib(nibName: "RGSScheduleTableViewCell", bundle: nil)
        tableView.register(scheduleTableViewCellNib, forCellReuseIdentifier: scheduleTableViewCellIdentifier)
        
        // Register custom Empty UITableViewCell
        let scheduleEmptyTableViewCellNib: UINib = UINib(nibName: "RGSEmptyTableViewCell", bundle: nil)
        tableView.register(scheduleEmptyTableViewCellNib, forCellReuseIdentifier: scheduleEmptyTableViewCellIdentifier)
        
        // Configure table to do automatic cell sizing.
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Explicity set tableView background color to clear to avoid odd animation bug where headers are opaque when sliding in.
        tableView.backgroundColor = UIColor.clear
        
        // Attempt to load Schedule Model from Database.
        if let set = RGSEventDataModel.loadDataModel(context: DataManager.sharedInstance.context, sort: RGSEventDataModel.sort) {
            mergeEventSet(set)
        }
        
        // Attempt to refresh Schedule Model by querying the server: Get next two weeks.
        self.refreshModelWithDataForWeeks([0,1])
        
        
        // Set background color for the UITableView.
        self.tableView.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Flushing events
        events = [];
    }

}

extension RGSScheduleViewController {
    
    // MARK: - Network Support Methods
    
    // MARK: - Network GET Requests.
    
    func refreshModelWithDataForWeeks(automatic: Bool = true, _ weeks: [Int]) {
        
        // If no weeks, return.
        if (weeks.count == 0) {
            return
        }
        
        // If popup was dismissed, undo upon manual refresh.
        if (automatic == false) {
            NetworkManager.sharedInstance.userAcknowledgedNetworkError = false
        }
        
        // Obtain URL.
        let url: String = NetworkManager.sharedInstance.URLForEventsByWeek(offset: weeks.first!)
        
        // Dispatch request, merge results on completion.
        NetworkManager.sharedInstance.makeGetRequest(url: url, onCompletion: {(data: Data?, _ : URLResponse?) -> Void in
            let fetched: [RGSEventDataModel]? = DataManager.sharedInstance.parseEventData(data: data)
            sleep(1)
            DispatchQueue.main.async() {
                self.mergeEventSet(fetched)
                self.resumeTableViewInteraction()
                self.displayWarningPopupIfNeeded(animated: true)
            }
        })
        
        // Perform recursive call.
        refreshModelWithDataForWeeks(automatic: automatic, Array(weeks.dropFirst(1)))
    }
}
