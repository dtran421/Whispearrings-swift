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
    @Published var whispers: Array<Whisper> = []
    
    @Published var queue: Array<Whisper> = []
    
    func fetchWhispers() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        var output = Array<Whisper>()
        
        do {
            output = try managedObjectContext.fetch(NSFetchRequest<Whisper>(entityName: "Whisper"))
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        whispers = output
    }
    
    func fetchQueue() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        let managedObjectContext = appDelegate.persistentContainer.viewContext
        
        var output = Array<Whisper>()
        
        do {
            let temp = try managedObjectContext.fetch(NSFetchRequest<QueueArray>(entityName: "QueueArray"))
            
            output = Array(_immutableCocoaArray: temp[0].queue!)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
       
        queue = output
    }
}
