//
//  RGSScheduleEventsViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/5/18.
//  Copyright © 2018 RUG. All rights reserved.
//

import UIKit

class RGSScheduleEventsViewController: RGSBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Variables & Constants
    
    /// The UITableViewCell identifier.
    let scheduleTableViewCellIdentifier: String = "scheduleTableViewCellIdentifier"
    
    /// The day on which these events occur: Initialized to current day.
    var date: Date = Date()
    
    /// The events array: Initialized empty.
    var events: [RGSEventDataModel] = []
    
    // MARK: - Outlets
    
    /// The UITableView.
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Actions
    
    // MARK: - UITableViewDelegate Methods
    
    /// Sections in the UITableView.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Rows per section of the UITableView.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    /// Action for row selection.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: RGSScheduleTableViewCell = tableView.cellForRow(at: indexPath) as! RGSScheduleTableViewCell
        tableView.deselectRow(at: indexPath, animated: false)
        performSegue(withIdentifier: "RGSScheduleEventViewController", sender: cell)
    }
    
    /// Delegate method for cell configuration.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Create TableViewCell.
        let cell: RGSScheduleTableViewCell = tableView.dequeueReusableCell(withIdentifier: scheduleTableViewCellIdentifier, for: indexPath) as! RGSScheduleTableViewCell
        let event: RGSEventDataModel = events[indexPath.row]
        cell.startDate = event.startDate
        cell.title = event.title
        cell.address = event.location
        return cell
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Extract destination ViewController, cell tapped in question.
        let scheduleEventViewController: RGSScheduleEventViewController = segue.destination as! RGSScheduleEventViewController
        let indexPath: IndexPath = tableView.indexPath(for: sender as! RGSScheduleTableViewCell)!
        
        // Set event to be displayed to that corresponding to the tapped cell.
        let event: RGSEventDataModel = events[indexPath.row]
        scheduleEventViewController.event = event
    }
    
    // MARK: Superclass Method Overrides
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (true, DateManager.sharedInstance.dateToISOString(date, format: .generalPresentationDateFormat))
    }
    
    override func shouldShowReturnButton() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTheme()
        
        // Register custom UITableViewCell
        let scheduleTableViewCellNib: UINib = UINib(nibName: "RGSScheduleTableViewCell", bundle: nil)
        tableView.register(scheduleTableViewCellNib, forCellReuseIdentifier: scheduleTableViewCellIdentifier)
        
        // Configure table to do automatic cell sizing.
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
        self.events = []
    }
    
}
