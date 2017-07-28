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
    
    /// UITableViewCellIdentifier
    let generalInfoTableViewCellIdentifier: String = "generalInfoTableViewCellIdentifier"
    
    /// UITableViewCell Custom Height
    let generalInfoTableViewCellHeight: CGFloat = 64
    
    /// Data for the UITableView
    var generalInfo: [GeneralInfo]! {
        didSet (oldGeneralInfo) {
            tableView.reloadData()
        }
    }
    
    // MARK: - Outlets
    
    /// The UITableView
    @IBOutlet weak var tableView: UITableView!
    
    
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
        cell.itemDescription = generalInfoItem.description
        return cell
    }
    
    // MARK: - UITableView ScrollView Delegate Protocol Methods
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let released: CGPoint = scrollView.contentOffset
        if (released.y <= SpecificationManager.sharedInstance.tableViewContentRefreshOffset) {
            print("Should reload content now!")
            refreshModelData()
        }
    }
    
    // MARK: - Private Class Methods
    
    func refreshModelData() {
        let url: String = NetworkManager.sharedInstance.URLForGeneralInformation()
        NetworkManager.sharedInstance.makeGetRequest(url: url, onCompletion: {(data: Data?) -> Void in
            let fetched: [GeneralInfo]? = DataManager.sharedInstance.parseDataToGeneralInfo(data: data)
            DispatchQueue.main.async {
                self.generalInfo = fetched
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
        
        // Attempt to load Announcement Model from DataBase
        if let generalInfo = DataManager.sharedInstance.loadGeneralInfoData() {
            self.generalInfo = generalInfo
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Flush generalInfo
        self.generalInfo = []
    }

}
