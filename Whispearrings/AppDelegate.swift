//
//  AppDelegate.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Whispearrings")
        container.loadPersistentStores { description, error in
            if let error = error {
                print(error)
            }
        }
        return container
    }()
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }

    func preloadData() {
        let managedObjectContext = persistentContainer.viewContext
        
        let queueArray = QueueArray(context: managedObjectContext)
        
        for whisper in whisperData {
            let newWhisper = Whisper(context: managedObjectContext)
            
            newWhisper.id = UUID()
            newWhisper.value = whisper.value
            newWhisper.type = "Default"
            newWhisper.soundFile = whisper.soundFile
            
            queueArray.addToQueue(newWhisper)
        }
        
        let queueSettings = QueueSettings(context: managedObjectContext)
        
        queueSettings.timing = 2
        queueSettings.randomTiming = false
        queueSettings.shufflePlay = false
        queueSettings.repeatPlay = false
                        
        do {
            try managedObjectContext.save()
            print("saved preloaded data!")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let defaults = UserDefaults.standard
        let isPreloaded = defaults.bool(forKey: "isPreloaded")
        if !isPreloaded {
            preloadData()
            defaults.set(true, forKey: "isPreloaded")
        }
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

