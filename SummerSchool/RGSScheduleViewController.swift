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

protocol RGSCollapsibleTableViewHeaderDelegate {
    func toggleSection(header: RGSCollapsibleTableViewHeader, section: Int)
}

class RGSCollapsibleTableViewHeader: UITableViewHeaderFooterView {
    let titleLabel = UILabel()
    let arrowLabel = UILabel()
    var section: Int = 0
    var delegate: RGSCollapsibleTableViewHeaderDelegate?
    
    func setCollapsed(_ collapsed: Bool) {
        
    }
    
    func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? RGSCollapsibleTableViewHeader else {
            return
        }
        delegate?.toggleSection(header: self, section: cell.section)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let views = [
            "titleLabel" : titleLabel,
            "arrowLabel" : arrowLabel,
            ]
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-20-[titleLabel]-[arrowLabel]-20-|",
            options: [],
            metrics: nil,
            views: views
        ))
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[titleLabel]-|",
            options: [],
            metrics: nil,
            views: views
        ))
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[arrowLabel]-|",
            options: [],
            metrics: nil,
            views: views
        ))
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Add subiews, gesture recognizer
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowLabel)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapHeader(_:))))
        
        // Add constraints
        arrowLabel.widthAnchor.constraint(equalToConstant: 12).isActive = true
        arrowLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented yet!")
    }
}

class RGSScheduleViewController: RGSBaseViewController, UITableViewDelegate, UIScrollViewDelegate, UITableViewDataSource, RGSCollapsibleTableViewHeaderDelegate {
    
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
    let headerFooterViewIdentifier: String = "headerFooterViewIdentifier"
    
    /// UITableViewCell Identifier
    let scheduleTableViewCellIdentifier: String = "scheduleTableViewCellIdentifier"
    
    /// Empty UITableViewCell Identifier
    let scheduleEmptyTableViewCellIdentifier: String = "scheduleEmptyTableViewCellIdentifier"
    
    /// UITableViewCell Custom Height
    let scheduleTableViewCellHeight: CGFloat = 66
    
    /// Empty UITableViewCell Custom Height
    let scheduleEmptyTableViewCellHeight: CGFloat = 44
    
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
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lastWeekButton: UIButton!
    
    @IBOutlet weak var nextWeekButton: UIButton!
    
    // MARK: - Actions
    
    @IBAction func didPressLastWeekButton(_ sender: UIButton) {
        week = (week - 1)
    }
    
    @IBAction func didPressNextWeekButton(_ sender: UIButton) {
        week = (week + 1)
    }
    
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
        return 44
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if (sections.indices.contains(indexPath.section) && sections[indexPath.section].events.count > 0) {
            return scheduleTableViewCellHeight
        } else {
            return scheduleEmptyTableViewCellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerFooterViewIdentifier) as? RGSCollapsibleTableViewHeader ?? RGSCollapsibleTableViewHeader(reuseIdentifier: headerFooterViewIdentifier)
        header.titleLabel.text = sections[section].dateString
        header.arrowLabel.text = ">"
        header.setCollapsed(sections[section].isCollapsed)
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
                cell.title = "Nothing scheduled today!"
                return cell
            }
        } else {
            return UITableViewCell()
        }
    }
    
    // MARK: - UITableView ScrollView Delegate Protocol Methods
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let released: CGPoint = scrollView.contentOffset
        if (released.y <= SpecificationManager.sharedInstance.tableViewContentRefreshOffset) {
            print("Should reload content now!")
            refreshModelWithDataForWeek(week)
        }
    }
    
    // MARK: - RGSCollapsibleTableViewHeader Delegate Protocol Methods
    
    func toggleSection(header: RGSCollapsibleTableViewHeader, section: Int) {
        let collapsed = !sections[section].isCollapsed
        
        // Toggle collapse
        sections[section].isCollapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Reload section
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
        
        // Attempt to load Schedule Model from Database
        if let eventPacket = DataManager.sharedInstance.loadScheduleData() {
            self.events = eventPacket.events
        }
        
        // Attempt to refresh Schedule Model by querying the server.
        self.refreshModelWithDataForWeek(self.week)
        
        // Auto resizing the height of the cell
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Flushing events
        events = [];
    }

}
