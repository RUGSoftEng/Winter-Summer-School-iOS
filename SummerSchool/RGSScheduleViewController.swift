//
//  RGSScheduleViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

struct Section {
    var dateString: String
    var events: [Event]
    var isCollapsed: Bool
    
    init(dateString: String, events: [Event], isCollapsed: Bool = false) {
        self.dateString = dateString
        self.events = events
        self.isCollapsed = isCollapsed
    }
}

class RGSScheduleViewController: RGSBaseViewController, UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource, RGSScheduleTableViewHeaderFooterViewProtocol {
    
    // MARK: - Variables & Constants
    
    /// The current week for which content is being displayed in the tableView
    var week: Int = 0 {
        didSet (oldWeek) {
            if (week != oldWeek) {
                refreshModelWithDataForWeek(week)
            }
        }
    }
    
    /// UITableViewHeaderFooterView Identifier
    let scheduleTableViewHeaderFooterViewIdentifier: String = "scheduleTableViewHeaderFooterViewIdentifier"
    
    /// UITableViewCell Identifier
    let scheduleTableViewCellIdentifier: String = "scheduleTableViewCellIdentifier"
    
    /// Empty UITableViewCell Identifier
    let scheduleEmptyTableViewCellIdentifier: String = "scheduleEmptyTableViewCellIdentifier"
    
    /// UITableViewCell Custom Height
    let scheduleTableViewCellHeight: CGFloat = 66
    
    /// Empty UITableViewCell Custom Height
    let scheduleEmptyTableViewCellHeight: CGFloat = 44
    
    /// TableViewHeaderFooterView Custom Height
    var scheduleTableViewHeaderFooterViewHeight: CGFloat {
        return tableView == nil ? CGFloat(44) : CGFloat(tableView.bounds.height / 7)
    }
    
    /// Data for the UITableView
    var events: [(Date, [Event])]? {
        didSet {
            if (tableView != nil && events != nil) {
                sections = eventsToSections(events!)
                tableView.reloadData()
            }
        }
    }
    
    /// Array of titles for each section.
    private var sections: [Section]!
    
    /// Iterates over the raw events and sorts them into sections
    func eventsToSections(_ events: [(Date, [Event])]) -> [Section] {
        var sections: [Section] = []
        for (date, dateEvents) in events {
            let dateString: String = DateManager.sharedInstance.longStyleDateFromDate(date)!
            sections.append(Section(dateString: dateString, events: dateEvents, isCollapsed: true))
        }
        return sections
    }
    
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
        return (sections == nil) ? 0 : sections!.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (sections.indices.contains(section) && sections[section].isCollapsed == false) {
            return max(sections[section].events.count, 1)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return scheduleTableViewHeaderFooterViewHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (sections.indices.contains(indexPath.section) && sections[indexPath.section].events.count > 0) {
            return scheduleTableViewCellHeight
        } else {
            return scheduleEmptyTableViewCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: scheduleTableViewHeaderFooterViewIdentifier) as? RGSScheduleTableViewHeaderFooterView ?? RGSScheduleTableViewHeaderFooterView(reuseIdentifier: scheduleTableViewHeaderFooterViewIdentifier)
        
        header.title = sections[section].dateString
        header.section = section
        header.delegate = self
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Only select a cell if it will be a RGSScheduleTableViewCell.
        if (sections[indexPath.section].events.count > 0) {
            let cell: RGSScheduleTableViewCell = tableView.cellForRow(at: indexPath) as! RGSScheduleTableViewCell
            tableView.deselectRow(at: indexPath, animated: false)
            performSegue(withIdentifier: "RGSScheduleEventViewController", sender: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (sections.indices.contains(indexPath.section)) {
            let s: Section = sections[indexPath.section]
            
            if (s.events.indices.contains(indexPath.row)) {
                let cell: RGSScheduleTableViewCell = tableView.dequeueReusableCell(withIdentifier: scheduleTableViewCellIdentifier, for: indexPath) as! RGSScheduleTableViewCell
                let event: Event = s.events[indexPath.row]
                
                cell.startDate = event.startDate
                cell.title = event.title
                cell.address = event.address
                return cell
            } else {
                let cell: RGSEmptyTableViewCell = tableView.dequeueReusableCell(withIdentifier: scheduleEmptyTableViewCellIdentifier, for: indexPath) as! RGSEmptyTableViewCell
                cell.title = "Nothing scheduled!"
                return cell
            }
        } else {
            return UITableViewCell()
        }
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
            refreshModelWithDataForWeek(week)
        }
    }
    
    // MARK: - RGSCollapsibleTableViewHeader Delegate Protocol Methods
    
    func toggleSection(header: RGSScheduleTableViewHeaderFooterView, section: Int) {
        
        // Assign the inverse state to collapsed.
        let collapsed = !sections[section].isCollapsed
        
        // Toggle collapse/expansion
        sections[section].isCollapsed = collapsed
        header.isCollapsed = collapsed
        
        // Reload the section
        tableView.reloadSections(NSIndexSet(index: section) as IndexSet, with: .automatic)
    }
    
    // MARK: - Private Class Methods
    
    func refreshModelWithDataForWeek(_ week: Int) {
        let url: String = NetworkManager.sharedInstance.URLForEventsByWeek(offset: week)
        NetworkManager.sharedInstance.makeGetRequest(url: url, onCompletion: {(data: Data?) -> Void in
            let fetched: EventPacket? = DataManager.sharedInstance.parseDataToEventPacket(data: data)
            DispatchQueue.main.async() {
                self.events = fetched?.events
            }
        })
    }
    
    // MARK: - Notifications
    
    /// Handler for when the App is about to suspend execution.
    override func applicationWillResignActive(notification: NSNotification) {
        super.applicationWillResignActive(notification: notification)
        
        // Save events
        if (events != nil) {
            print("Saving schedule data...")
            DataManager.sharedInstance.saveScheduleData(events: self.events!)
        }
    }
    
    
    // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Extract destination ViewController, cell tapped in question.
        let scheduleEventViewController: RGSScheduleEventViewController = segue.destination as! RGSScheduleEventViewController
        let indexPath: IndexPath = tableView.indexPath(for: sender as! RGSScheduleTableViewCell)!
        
        // Set event to be displayed to that corresponding to the tapped cell.
        let s: Section = sections[indexPath.section]
        scheduleEventViewController.event = s.events[indexPath.row]
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
        
        // Register custom UITableViewHeaderFooterView
        let scheduleTableViewHeaderFooterViewNib: UINib = UINib(nibName: "RGSScheduleTableViewHeaderFooterView", bundle: nil)
        tableView.register(scheduleTableViewHeaderFooterViewNib, forHeaderFooterViewReuseIdentifier: scheduleTableViewHeaderFooterViewIdentifier)
        
        // Attempt to load Schedule Model from Database
        if let eventPacket = DataManager.sharedInstance.loadScheduleData() {
            self.events = eventPacket.events
        }
        
        // Attempt to refresh Schedule Model by querying the server.
        self.refreshModelWithDataForWeek(self.week)
        
        // Set background color for the UITableView.
        self.tableView.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Flushing events
        events = [];
    }

}
