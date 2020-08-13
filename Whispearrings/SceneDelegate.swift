//
//  SceneDelegate.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData

class SettingsTracker: ObservableObject {
    var initialTiming: Int
    var initialRandomTiming: Bool
    var initialShufflePlay: Bool
    var initialRepeatPlay: Bool
    
    init(timing: Int, randomTiming: Bool, shufflePlay: Bool, repeatPlay: Bool) {
        initialTiming = timing
        initialRandomTiming = randomTiming
        initialShufflePlay = shufflePlay
        initialRepeatPlay = repeatPlay
    }
    
    func reset(newTiming: Int, newRandomTiming: Bool, newShufflePlay: Bool, newRepeatPlay: Bool) {
        initialTiming = newTiming
        initialRandomTiming = newRandomTiming
        initialShufflePlay = newShufflePlay
        initialRepeatPlay = newRepeatPlay
    }
}

class SelectedWhisper: ObservableObject {
    var whisper: Whisper
    
    var intervalMode: Bool = false
    var specificMode: Bool = false
    var timeInterval: Int = 0
    var specificTime: Date = Date()
    
    init(whisperCollection: WhisperCollection) {
        whisper = whisperCollection.whispers[0]
        
        let temp = whisper.times as! Set<Time>
        if !temp.isEmpty {
            let time = temp.first!
            
            intervalMode = time.intervalMode
            specificMode = time.specificMode
            timeInterval = Int(time.timeInterval)
            specificTime = time.specificTime
        }
    }
    
    func selectWhisper(newWhisper: Whisper) {
        whisper = newWhisper
        
        let temp = whisper.times as! Set<Time>
        if !temp.isEmpty {
            let time = temp.first!
            
            intervalMode = time.intervalMode
            specificMode = time.specificMode
            timeInterval = Int(time.timeInterval)
            specificTime = time.specificTime
        } else {
            intervalMode = false
            specificMode = false
            timeInterval = 0
            specificTime = Date()
        }
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    var whisperCollection = WhisperCollection()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        whisperCollection.fetchWhispers(managedObjectContext: managedObjectContext)
        whisperCollection.fetchQueue(managedObjectContext: managedObjectContext)
        whisperCollection.fetchTimes(managedObjectContext: managedObjectContext)
        
        var settings: QueueSettings!
            
        do {
            let output = try managedObjectContext.fetch(NSFetchRequest<QueueSettings>(entityName: "QueueSettings"))
            
            settings = output[0]
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }

        let settingsTracker = SettingsTracker(timing: Int(settings.timing), randomTiming: settings.randomTiming, shufflePlay: settings.shufflePlay, repeatPlay: settings.repeatPlay)
        
        let selectedWhisper = SelectedWhisper(whisperCollection: whisperCollection)
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(settingsTracker: settingsTracker, timing: Int(settings.timing), randomTiming: settings.randomTiming, shufflePlay: settings.shufflePlay, repeatPlay: settings.repeatPlay)
                .environment(\.managedObjectContext, managedObjectContext)
                .environmentObject(whisperCollection)
                .environmentObject(selectedWhisper)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: contentView)
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

