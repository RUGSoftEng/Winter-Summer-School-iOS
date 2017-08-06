//
//  AppDelegate.swift
//  SummerSchool
//
//  Created by Charles Randolph on 5/19/17.
//  Copyright © 2017 RUG. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Variables & Constants

    var window: UIWindow?

    // MARK: - Application Activity Methods

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Update UserDefault settings displayed in Settings
        UserDefaults.standard.register(defaults: SpecificationManager.sharedInstance.applicationLaunchDefaults)
        
        // Synchronize settings
        UserDefaults.standard.synchronize()
        
        // Force WebCore to initialize (this method is ugly, but explicit initialization is in a private framework).
        do { try _ = NSAttributedString(HTMLString: "", font: nil) } catch { }
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Core Data Stack
    
    
    /// Lazy variable computed with a code block.
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: DataManager.sharedInstance.dataModelIdentifier)
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            
            // If an error occured, disable CoreData activity app-wide. (Will be enabled upon restart)
            if let error = error as NSError? {
                DataManager.sharedInstance.isCoreDataAvailable = false
                
                // Remove following line in production code
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
        })
        
        return container
    }()
    
    /// Attempts to save the managed object context to disk
    func saveContext() {
        let context = persistentContainer.viewContext
        
        // If an error occurs while saving, disable CoreData activity app-wide. (Will be enabled upon restart)
        if (context.hasChanges) {
            do {
                try context.save()
            } catch {
                DataManager.sharedInstance.isCoreDataAvailable = false
                
                // Remove the next two lines in production version
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                
            }
        }
    }

}

