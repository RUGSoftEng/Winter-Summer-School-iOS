//
//  RGSInfoViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSInfoViewController: RGSBaseViewController, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    // MARK: - Variables & Constants
    
    /// Overridden StatusBarStyle. Set to light to contrast off red background.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    /// UITableViewCellIdentifier
    let generalInfoTableViewCellIdentifier: String = "generalInfoTableViewCellIdentifier"
    
    /// UITableViewCell Custom Height
    let generalInfoTableViewCellHeight: CGFloat = 48
    
    /// Data for the UITableView
    var generalInfo: [GeneralInfo]! {
        didSet (oldGeneralInfo) {
            if (generalInfo != nil) {
                tableView.reloadData()
            } else {
                generalInfo = oldGeneralInfo
                
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
        return (true, "General Information")
    }
    
    override func shouldShowReturnButton() -> Bool {
        return false
    }
    
    // MARK: - UITableViewDelegate/DataSource Protocol Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (generalInfo == nil) ? 0 : generalInfo!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return generalInfoTableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        tableView.deselectRow(at: indexPath, animated: false)
        self.performSegue(withIdentifier: "RGSInfoDetailViewController", sender: cell)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: RGSGeneralInfoTableViewCell = tableView.dequeueReusableCell(withIdentifier: generalInfoTableViewCellIdentifier) as! RGSGeneralInfoTableViewCell
        let generalInfoItem: GeneralInfo = generalInfo[indexPath.row]
        cell.title = generalInfoItem.title
        cell.category = generalInfoItem.category
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

        let url: String = NetworkManager.sharedInstance.URLForGeneralInformation()
        NetworkManager.sharedInstance.makeGetRequest(url: url, onCompletion: {(data: Data?) -> Void in
            let fetched: [GeneralInfo]? = DataManager.sharedInstance.parseDataToGeneralInfo(data: data)
            sleep(1)
            DispatchQueue.main.async {
                self.generalInfo = fetched
                self.resumeTableViewInteraction()
                self.displayWarningPopupIfNeeded(animated: true)
            }
        })
    }
    
    // MARK: - Notifications
    
    /// Handler for when the app is about to suspend execution
    override func applicationWillResignActive(notification: NSNotification) {
        super.applicationWillResignActive(notification: notification)
        
        if (generalInfo != nil) {
            print("Saving generalInfo data...")
            DataManager.sharedInstance.saveGeneralInfoData(generalInfo: generalInfo)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Extract destination ViewController, cell tapped in question.
        let infoDetailViewController: RGSInfoDetailViewController = segue.destination as! RGSInfoDetailViewController
        let indexPath: IndexPath = tableView.indexPath(for: sender as! RGSGeneralInfoTableViewCell)!
        
        // Set announcement to be displayed to that corresponding to the tapped cell.
        let generalInfoItem = generalInfo[indexPath.row]
        infoDetailViewController.generalInfoItem = generalInfoItem
    }
    
    
    // MARK: - Class Method Overrides
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTheme()
        
        // Register Custom UITableViewCell
        let generalInfoTableViewCell: UINib = UINib(nibName: "RGSGeneralInfoTableViewCell", bundle: nil)
        tableView.register(generalInfoTableViewCell, forCellReuseIdentifier: generalInfoTableViewCellIdentifier)
        
        // Attempt to load GeneralInfo Model from DataBase
        if let generalInfo = DataManager.sharedInstance.loadGeneralInfoData() {
            self.generalInfo = generalInfo
        }
        
        // Attempt to refresh GeneralInfo Model by querying the server.
        self.refreshModelData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Flush generalInfo
        self.generalInfo = []
    }

}
