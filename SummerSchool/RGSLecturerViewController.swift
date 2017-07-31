//
//  RGSLecturerViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSLecturerViewController: RGSBaseViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Actions
    
    // MARK: - UICollectionViewDelegate/DataSource Methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (lecturers == nil) ? 0 : lecturers.count
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
    
    // MARK: - Superclass Method Overrides
    
    override func shouldShowTitleLabel() -> (Bool, String?) {
        return (true, "Lecturers")
    }
    
    // MARK: - Private Class Methods
    
    func refreshModelData() {
        let url: String = NetworkManager.sharedInstance.URLForLecturers()
        NetworkManager.sharedInstance.makeGetRequest(url: url, onCompletion: {(data: Data?) -> Void in
            let fetched: [Lecturer]? = DataManager.sharedInstance.parseDataToLecturers(data: data)
            DispatchQueue.main.async {
                self.lecturers = fetched
                
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
        print("Updating images...")
        
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
            print("Lecturers available from memory!")
            self.lecturers = lecturers
        } else {
            print("Fetching lecturers")
            refreshModelData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Flush Lecturers
        self.lecturers = []
    }

}
