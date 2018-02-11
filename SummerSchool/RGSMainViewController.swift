//
//  RGSMainViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/4/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSMainViewController: UITabBarController {
    
    // MARK: - Variables & Constants
    
    /// Overridden StatusBarStyle. Set to light to contrast off red background.
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            return .lightContent
        }
    }
    
    /// The segue identifier for the lockScreen.
    private let lockScreenViewControllerSegueIdentifier: String = "showLockScreenViewController"
    
    
    // MARK: - Actions
    
    /// Unwind Segue Handle
    @IBAction func unwindToMain(_ segue: UIStoryboardSegue) {
        
    }
    
    // MARK: - Public Methods
    
    /// Pushes the LockScreen ViewController on top of the current TabBarController. (Note: It's required to initialize from Storyboard!)
    /// The lockScreenViewController is not expected to live long, so it should be recycled as soon as it is popped.
    func showLockScreenViewController() {
        self.performSegue(withIdentifier: lockScreenViewControllerSegueIdentifier, sender: self)
    }
    
    
    /// Method fires when user returns to this screen in the App.
    func applicationWillEnterForeground(notification: NSNotification) {
        print("Application is entering foreground!")
        if (SecurityManager.sharedInstance.shouldShowLockScreen) {
            print("Should display the lock screen!")
            showLockScreenViewController()
        }
    }
    
    // MARK: - Private Methods
    
    /// Takes a screenshot of the current screen for use with the LockScreen ViewContoller
    private func getScreenShot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, true, 1.0)
        self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
        let screenShot: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenShot
    }
    
    
    // MARK: - Class Method Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: app)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let app = UIApplication.shared
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: app)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("View did appear!")
        if (SecurityManager.sharedInstance.shouldShowLockScreen) {
            print("Should display the lock screen!")
            showLockScreenViewController()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Fetch LockScreen ViewController.
        let lockScreenViewController: RGSLockScreenViewController = segue.destination as! RGSLockScreenViewController
        
        // Set the ScreenShot for the background.
        lockScreenViewController.screenShot = getScreenShot()

    }
 

}
