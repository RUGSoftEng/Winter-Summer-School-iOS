//
//  RGSLecturerViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSLecturerViewController: RGSBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    // MARK: - Variables & Constants
    
    /// CollectionViewCell Identifier
    let lecturerCollectionViewCellIdentifier: String = "lecturerCollectionViewCell"
    
    /// Number of items per row
    let itemsPerRow: CGFloat = 2
    
    /// Section insets
    let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    /// The data model
    var lecturers: [Lecturer]! {
        didSet (oldLecturers) {
            if (lecturers != nil) {
                self.collectionView.reloadData()
            } else {
                lecturers = oldLecturers
            }
        }
    }
    
    // MARK: - Outlets
    
    /// The UICollectionView
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// The RGSLoadingIndicatorView
    @IBOutlet weak var loadingIndicator: RGSLoadingIndicatorView!
    
    // MARK: - Actions
    
    // MARK: - UICollectionViewDelegate/DataSource Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (lecturers == nil) ? 0 : lecturers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell: RGSLecturerCollectionViewCell = collectionView.cellForItem(at: indexPath) as! RGSLecturerCollectionViewCell
        collectionView.deselectItem(at: indexPath, animated: false)
        performSegue(withIdentifier: "RGSLecturerProfileViewController", sender: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RGSLecturerCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: lecturerCollectionViewCellIdentifier, for: indexPath) as! RGSLecturerCollectionViewCell
        let lecturer: Lecturer = lecturers[indexPath.row]
        
        cell.name = lecturer.name
        if (lecturer.image != nil) {
            cell.image = lecturers[indexPath.row].image
        } else {
            
        }
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout Methods
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.right * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    // MARK: - UITableView ScrollView Delegate Protocol Methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset: CGPoint = scrollView.contentOffset
        
        // If the CollectionView is enabled, animate reload indicator when tugging. If it is disabled, lock to reload position.
        if (scrollView.isUserInteractionEnabled) {
            
            if (offset.y <= 0) {
                let progress = CGFloat(offset.y / SpecificationManager.sharedInstance.collectionViewContentRefreshOffset)
                loadingIndicator.progress = progress
            }
            
        } else {
            
            if (offset.y >= SpecificationManager.sharedInstance.collectionViewContentReloadOffset) {
                let reloadOffset: CGPoint = CGPoint(x: 0, y: SpecificationManager.sharedInstance.collectionViewContentReloadOffset)
                collectionView.contentOffset = reloadOffset
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offset: CGPoint = scrollView.contentOffset
        if (offset.y <= SpecificationManager.sharedInstance.collectionViewContentRefreshOffset) {
            print("Should reload content now!")
            suspendCollectionViewInteraction(contentOffset: CGPoint(x: offset.x, y: SpecificationManager.sharedInstance.collectionViewContentReloadOffset))
            
            // Manual refresh.
            refreshModelData(automatic: false)
        }
    }
    
    // MARK: - Superclass Method Overrides

    
    // MARK: - Notifications
    
    override func applicationWillResignActive(notification: NSNotification) {
        super.applicationWillResignActive(notification: notification)
        
        if lecturers != nil {
            DataManager.sharedInstance.saveLecturerData(lecturers: lecturers)
            print("Saving lecturer data ...")
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Extract destination ViewController, cell tapped in question.
        let lecturerProfileViewController: RGSLecturerProfileViewController = segue.destination as! RGSLecturerProfileViewController
        let indexPath: IndexPath = collectionView.indexPath(for: sender as! RGSLecturerCollectionViewCell)!
        
        // Set event to be displayed to that corresponding to the tapped cell.
        let lecturer: Lecturer = lecturers[indexPath.row]
        lecturerProfileViewController.lecturer = lecturer
    }
    
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (true, "Lecturers")
    }
    
    // MARK: - Private Class Methods
    
    func suspendCollectionViewInteraction(contentOffset offset: CGPoint) {
        collectionView.setContentOffset(offset, animated: true)
        collectionView.isUserInteractionEnabled = false
        loadingIndicator.startAnimation()
    }
    
    func resumeContentViewInteraction() {
        loadingIndicator.stopAnimation()
        collectionView.isUserInteractionEnabled = true
        collectionView.setContentOffset(.zero, animated: true)
    }
    
    func refreshModelData(automatic: Bool = true) {
        
        // If popup was dismissed, undo upon manual referesh.
        if (automatic == false) {
            NetworkManager.sharedInstance.userAcknowledgedNetworkError = false
        }
        
        let url: String = NetworkManager.sharedInstance.URLForLecturers()
        NetworkManager.sharedInstance.makeGetRequest(url: url, onCompletion: {(data: Data?, _ : URLResponse?) -> Void in
            let fetched: [Lecturer]? = DataManager.sharedInstance.parseDataToLecturers(data: data)
            sleep(1)
            DispatchQueue.main.async {
                self.lecturers = fetched
                self.resumeContentViewInteraction()
                self.displayWarningPopupIfNeeded(animated: true)
                
                // Try to update images
                self.getLecturerImages()
            }
        })
    }
    
    /// Dispatches a task to update all lecturer images.
    func getLecturerImages() -> Void {
        
        if self.lecturers == nil {
            return
        }
        
        // Start Network Activity Indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        DispatchQueue.global().async {
            var newLecturers: [Lecturer] = []
            
            for lecturer in self.lecturers {
                var newLecturer = lecturer
                
                if let imagePath = lecturer.imagePath {
                    
                    // Build resource URL, prepare URLSession (Should be thread safe to access NetworkManager)
                    let resourceURL = NetworkManager.sharedInstance.URLForResourceWithPath(imagePath)
                    
                    //let request: URLRequest = URLRequest(url: URL(string: resourceURL))
                    let session = URLSession.shared
                    
                    // Perform asynchronous dataTask.
                    let (data, _, _) = session.synchronousDataTask(with: URL(string: resourceURL)!)
                    
                    // Update struct with new data
                    if let imageData = data, let image = UIImage(data: imageData) {
                        newLecturer.image = image
                    }
                }
                
                newLecturers.append(newLecturer)
            }
            
            // Update self.lecturers.
            DispatchQueue.main.async {
                
                // Stop Network Activity Indicator
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.lecturers = newLecturers
            }
        }
    }
    
    // MARK: - Class Method Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBarTheme()
        
        
        // Register Custom UITableViewCell
        let lecturerCollectionViewCellNib: UINib = UINib(nibName: "RGSLecturerCollectionViewCell", bundle: nil)
        collectionView.register(lecturerCollectionViewCellNib, forCellWithReuseIdentifier: lecturerCollectionViewCellIdentifier)
        
        // Attempt to load Lecturers from DataBase
        if let lecturers = DataManager.sharedInstance.loadLecturerData() {
            self.lecturers = lecturers
        }
        // Attempt to refresh Lecturer Model by querying the server.
        self.refreshModelData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Flush Lecturers
        self.lecturers = []
    }

}
