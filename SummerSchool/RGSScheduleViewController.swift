//
//  RGSScheduleViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSScheduleViewController: RGSBaseViewController, UICollectionViewDelegate, UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Variables & Constants
    
    /// The current day.
    var now: Date {
        return DateManager.sharedInstance.startOfDay(for: Date())
    }
    
    /// The current weekday offset.
    var currentWeekday: Int {
        return DateManager.sharedInstance.weekDayOffsetFromDate(now)
    }
    
    /// The current week for which content is being displayed in the tableView
    var week: Int = 0
    
    /// UICollectionViewCell Identifier.
    let scheduleCollectionViewCellIdentifier: String = "scheduleCollectionViewCellIdentifier"
    
    /// The number of items per row.
    let itemsPerRow: CGFloat = 3
    
    /// Section insets.
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    
    /// The events data model.
    var events: [RGSEventDataModel] = [] {
        didSet(oldEvents) {
            self.collectionView.performBatchUpdates({
                let indexSet = IndexSet(integer: 0)
                self.collectionView.reloadSections(indexSet)
            }, completion: nil)
        }
    }
    
    /// The events-per-day data model. This is set during during the creation of each collectionView cell.
    var eventsPerDay: [[RGSEventDataModel]] = [[], [], [], [], [], [], []]
    
    /// The display data model.
    var weekdays: [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun", "Mon"]
    
    /// Boolean variable indicating whether the controller is currently paging.
    var paging: Bool = false
    
    // MARK: - Outlets
    
    /// The UICollectionView
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// The RGSLoadingIndicatorView
    @IBOutlet weak var loadingIndicator: RGSLoadingIndicatorView!
    
    // MARK: - Actions
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (true, "Schedule")
    }
    
    // MARK: - UITableViewDelegate/DataSource Protocol Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return weekdays.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: RGSScheduleCollectionViewCell = collectionView.cellForItem(at: indexPath) as! RGSScheduleCollectionViewCell
        collectionView.deselectItem(at: indexPath, animated: false)
        
        if (indexPath.row % 8 == 0 || eventsPerDay[indexPath.row - 1].count == 0) {
            print("You have no business visiting this cell!")
        } else {
            print("You tapped: \(weekdays[indexPath.row]) with exactly: \(eventsPerDay[indexPath.row - 1].count)")
            self.performSegue(withIdentifier: "RGSScheduleEventsViewController", sender: cell)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /// Create the cell.
        let cell: RGSScheduleCollectionViewCell  = collectionView.dequeueReusableCell(withReuseIdentifier: scheduleCollectionViewCellIdentifier, for: indexPath) as! RGSScheduleCollectionViewCell
        
        /// Compute and set the current date.
        let offset: Int = (indexPath.row - currentWeekday) + (7 * week)
        let date: Date = DateManager.sharedInstance.startOfDay(in: offset, from: now)
        cell.date = date
        
        /// Filter and set all events for indices (1 -> 7). Do not calculate for the faded out padding days at indices (0,8)
        if (indexPath.row % 8 != 0) {
            let from: Date = DateManager.sharedInstance.startOfDay(in: offset, from: now)
            let to: Date = DateManager.sharedInstance.endOfDay(for: from)
            self.eventsPerDay[indexPath.row - 1] = eventsInRange(from: from, to: to, in: self.events)
            
            // Set the number of events: Remember to adjust the row value down.
            cell.eventCount = self.eventsPerDay[indexPath.row - 1].count
        } else {
            cell.eventCount = 0
        }
        
        // Set the highlight.
        if (offset == 0) {
            cell.setColorScheme(scheme: -1)
        } else {
            cell.setColorScheme(scheme: indexPath.row % 8)
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalPaddingSpace = sectionInsets.right * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - horizontalPaddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        let itemsPerColumn: CGFloat = 3
        let verticalPaddingSpace = sectionInsets.top * (itemsPerColumn + 1)
        let availableHeight = collectionView.frame.height - verticalPaddingSpace
        let heightPerItem = availableHeight / itemsPerColumn
        
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    // MARK: - UICollectionView ScrollView Delegate Protocol Methods
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset: CGPoint = scrollView.contentOffset
        
        // If the CollectionView is enabled, animate reload indicator when tugging. If it is disabled, then lock it to the reload position.
        if (scrollView.isUserInteractionEnabled) {
            if (offset.y <= 0) {
                let progress = CGFloat(offset.y / SpecificationManager.sharedInstance.collectionViewContentRefreshOffset)
                loadingIndicator.progress = progress
            }
        } else {
            if (offset.y >= SpecificationManager.sharedInstance.collectionViewContentReloadOffset) {
                
                // Reload offset depends on whether or not we're paging.
                var reloadOffset: CGPoint = .zero
                if (paging) {
                    let dir: CGFloat = (offset.x < 0) ? -1 : 1;
                    let buf: CGFloat = 10
                    let limit: CGFloat = SpecificationManager.sharedInstance.collectionViewContentPageOffset
                    reloadOffset = CGPoint(x: limit * dir - buf, y: 0)
                } else {
                    reloadOffset = CGPoint(x: 0, y: SpecificationManager.sharedInstance.collectionViewContentReloadOffset)
                }
                collectionView.contentOffset = reloadOffset
            }
        }
        
        // Set opacity.
        offset = scrollView.contentOffset
        let x_max: CGFloat = SpecificationManager.sharedInstance.collectionViewContentPageOffset + 30.0
        self.collectionView.alpha = 1.0 - fabs(offset.x) / x_max
        self.collectionView.setNeedsDisplay()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset: CGPoint = scrollView.contentOffset
        
        // Content reload.
        if (offset.y <= SpecificationManager.sharedInstance.collectionViewContentRefreshOffset) {
            print("Should reload content now!")
            suspendCollectionViewInteraction(contentOffset: CGPoint(x: offset.x, y: SpecificationManager.sharedInstance.collectionViewContentReloadOffset))
    
            // Manual refresh.
            self.refreshModelWithDataForWeeks([-1, 0, 1])
            
            return
        }
        
        // Content paging.
        if (fabs(offset.x) > SpecificationManager.sharedInstance.collectionViewContentPageOffset) {
            let x = SpecificationManager.sharedInstance.collectionViewContentPageOffset * (offset.x < 0 ? -1 : 1)
            print("Paging \(offset.x < 0 ? "left" : "right")")
            week += (offset.x < 0 ? -1 : 1)
            
            // Suspend interaction during paging.
            suspendCollectionViewPagingInteraction(contentOffset: CGPoint(x: x, y: 0.0))
            
            // Automatic refresh.
            self.refreshModelWithDataForWeeks(automatic: true, [-1, 0, 1], set: [], paging: true)
        }
    }
    
    // MARK: - Private Class Methods
    
    // Merges a set of events into the event structure. Favors latest entry if existing one is found with identical ID.
    func mergeEventSet (_ set: [RGSEventDataModel]?) {
        
        // Ignore nil sets.
        if set == nil {
            return
        }
        
        // Add to the current events set.
        self.events += set!
        
        // Sort events again.
        self.events.sort(by: RGSEventDataModel.sort)
        
        // Reload tableview.
        self.collectionView.reloadData()
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
    
    // Suspends interaction with the UICollectionView during paging.
    func suspendCollectionViewPagingInteraction(contentOffset offset: CGPoint) {
        collectionView.setContentOffset(offset, animated: true)
        collectionView.isUserInteractionEnabled = false
        collectionView.setNeedsDisplay()
        paging = true
    }
    
    // Resumes interaction with the UICollectionView after paging.
    func resumeCollectionViewPagingInteraction() {
        collectionView.isUserInteractionEnabled = true
        collectionView.setNeedsDisplay()
        paging = false
    }
    
    // Suspends interaction with the UICollectionView during reload.
    func suspendCollectionViewInteraction(contentOffset offset: CGPoint) {
        collectionView.setContentOffset(offset, animated: true)
        collectionView.isUserInteractionEnabled = false
        loadingIndicator.startAnimation()
    }
    
    // Resumes interaction with the UICollectionView after reload.
    func resumeCollectionViewInteraction() {
        loadingIndicator.stopAnimation()
        collectionView.isUserInteractionEnabled = true
        collectionView.setContentOffset(.zero, animated: true)
    }
    
    // MARK: - Notifications
    
    /// Handler for when the App is about to suspend execution.
    override func applicationWillResignActive(notification: NSNotification) {
        super.applicationWillResignActive(notification: notification)
        
        // Save events.
        print("Saving schedule data...")
        RGSEventDataModel.saveDataModel(events, context: DataManager.sharedInstance.context)
    }
    
    
    // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Extract destination ViewController, cell tapped in question.
        let scheduleEventsViewController: RGSScheduleEventsViewController = segue.destination as! RGSScheduleEventsViewController
        let indexPath: IndexPath = collectionView.indexPath(for: sender as! RGSScheduleCollectionViewCell)!
        
        // Set date, and events to be displayed.
        let events: [RGSEventDataModel] = eventsPerDay[indexPath.row - 1]
        scheduleEventsViewController.events = events
        scheduleEventsViewController.date = (sender as! RGSScheduleCollectionViewCell).date!
     }
    
    
    // MARK: - Class Method Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTheme()
        
        // Register custom UICollectionViewCell
        let scheduleCollectionViewCellNib: UINib = UINib(nibName: "RGSScheduleCollectionViewCell", bundle: nil)
        collectionView.register(scheduleCollectionViewCellNib, forCellWithReuseIdentifier: scheduleCollectionViewCellIdentifier)
        
        // Set UICollectionView directional lock to avoid diagonal scrolling.
        self.collectionView.isDirectionalLockEnabled = true
        
        // Attempt to load Schedule Model from Database.
        if let set = RGSEventDataModel.loadDataModel(context: DataManager.sharedInstance.context, sort: RGSEventDataModel.sort) {
            print("Loaded set okay (\(set.count))!")
            self.events = set
        }
        
        // Attempt to refresh Schedule Model by querying the server: Get next two weeks.
        self.refreshModelWithDataForWeeks([-1, 0, 1])
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
    
    func refreshModelWithDataForWeeks (automatic: Bool = true, _ weeks: [Int], set: [RGSEventDataModel] = [], paging: Bool = false) {
        
        // If no weeks in the set: Return.
        if (weeks.count == 0) {
            DispatchQueue.main.async {
                sleep(1)
                if (paging) {
                    self.resumeCollectionViewPagingInteraction()
                } else {
                    self.resumeCollectionViewInteraction()
                }
                self.displayWarningPopupIfNeeded(animated: true)
                self.events = set
            }
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
            let fetched = DataManager.sharedInstance.parseEventData(data: data)
            if (fetched == nil) {
                self.refreshModelWithDataForWeeks(automatic: automatic, Array(weeks.dropFirst(1)), set: set)
            } else {
                self.refreshModelWithDataForWeeks(automatic: automatic, Array(weeks.dropFirst(1)), set: set + fetched!)
            }
        })
    }
    
}
