//
//  RGSBaseViewController.swift
//  SummerSchool
//
//  Created by Charles Randolph on 6/5/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit

class RGSBaseViewController: UIViewController {
    
    // MARK: - Variables & Constants
    
    // MARK: - Outlets
    
    // MARK: - Actions
    
    
    // MARK: - Methods
    
    /// Handler for display of title label: Defaults to false
    func shouldShowTitleLabel() -> (Bool, String?) {
        return (false, nil)
    }
    
    /// Handler for display of return button: Defaults to false
    func shouldShowReturnButton() -> Bool {
        return false
    }
    
    // MARK: - UINavigationItem Configurator
    
    func setNavigationBarTheme() -> Void {
        
        // Extract optional title
        let (withTitle, title) = shouldShowTitleLabel()
        
        // Initialize custom return arrow
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: AppearanceManager.sharedInstance.returnArrowImage, style: .done, target: self, action: #selector(popViewController(_:)))
        
        // Initialize custom settings icon. Set color as it is always displayed.
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(image: AppearanceManager.sharedInstance.settingsNutImage, style: .plain, target: self, action: #selector(pushSettingsController(_:)))
        rightBarButtonItem.tintColor = AppearanceManager.sharedInstance.lightBackgroundGrey
        
        // Configure the return arrow conditionally
        if (shouldShowReturnButton()) {
            leftBarButtonItem.tintColor = AppearanceManager.sharedInstance.lightBackgroundGrey
        } else {
            leftBarButtonItem.tintColor = UIColor.clear
            leftBarButtonItem.isEnabled = false
        }
        
        // Configure the title conditionally
        if (withTitle == true) {
            self.navigationItem.title = title
            self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : AppearanceManager.sharedInstance.lightBackgroundGrey]
        }
        
        // Configure bar colors
        self.navigationController?.navigationBar.barTintColor = AppearanceManager.sharedInstance.rugRed
        
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    // Mark: - UINavigationController Actions
    
    func popViewController(_ sender: UIBarButtonItem?) {
        if (self.navigationController != nil) {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func pushSettingsController(_ sender: UIBarButtonItem?) {
        if (self.navigationController != nil) {
            print("You tapped settings!")
            
            // Temporarily open the Settings page in the Settings application
            UIApplication.shared.open(NSURL(string: UIApplicationOpenSettingsURLString) as! URL, options: [:], completionHandler: nil)
        }
    }
    
    // MARK: - Notifications
    
    /// Handler for when the App resumes execution in this ViewController.
    func applicationWillEnterForeground(notification: NSNotification) {
        
    }
    
    /// Handler for when the App is about to suspend execution.
    func applicationWillResignActive(notification: NSNotification) {
        
    }
    
    // MARK: - Class Method Overrides
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Register to be notified when the user returns to this view.
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground(notification:)), name: .UIApplicationWillEnterForeground, object: app)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Unregister if the user is leaving this view and it won't be the first seen when they do return.
        let app = UIApplication.shared
        NotificationCenter.default.removeObserver(self, name: .UIApplicationWillEnterForeground, object: app)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register to be notified for impending application suspension.
        let app = UIApplication.shared
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive(notification:)), name: .UIApplicationWillResignActive, object: app)
        
    }

}
