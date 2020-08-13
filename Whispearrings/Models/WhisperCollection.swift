//
//  WhisperArray.swift
//  Whispearrings
//
//  Created by Duke Tran on 8/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

class WhisperCollection: ObservableObject {
    var managedObjectContext: NSManagedObjectContext
    @Published var whispers: Array<Whisper> = []
    
    @Published var queue: Array<Whisper> = []
    
    @Published var times: Array<Time> = []
    var timesUpdated: Bool = true
    
    init(newManagedObjectContext: NSManagedObjectContext) {
        managedObjectContext = newManagedObjectContext
    }
    
    func fetchWhispers() {
        var output = Array<Whisper>()
        
        do {
            output = try managedObjectContext.fetch(NSFetchRequest<Whisper>(entityName: "Whisper"))
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        whispers = output
    }
    
    func fetchQueue() {
        var output = Array<Whisper>()
        
        do {
            let temp = try managedObjectContext.fetch(NSFetchRequest<QueueArray>(entityName: "QueueArray"))
            
            output = Array(_immutableCocoaArray: temp[0].queue!)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
       
        queue = output
    }
    
    func fetchTimes() {
        var output = Array<Time>()
        
        do {
            output = try managedObjectContext.fetch(NSFetchRequest<Time>(entityName: "Time"))
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        times = output
        
        timesUpdated = false
    }
}
