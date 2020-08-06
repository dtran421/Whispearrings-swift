//
//  ContentView.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var whisperCollection: WhisperCollection
    
    var queueSettings: QueueSettings {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate

            let managedObjectContext = appDelegate.persistentContainer.viewContext
            
            var output = [QueueSettings]()
                
            do {
                output = try managedObjectContext.fetch(NSFetchRequest<QueueSettings>(entityName: "QueueSettings"))
                
                return output[0]
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            return QueueSettings()
        }
    }
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            QueueView(timing: Int(queueSettings.timing), randomTiming: queueSettings.randomTiming, shufflePlay: queueSettings.shufflePlay, repeatPlay: queueSettings.repeatPlay)
                .tabItem {
                    VStack {
                        Image(systemName: "music.note.list")
                        Text("Queue")
                    }
                }
                .tag(0)
            LibraryView()
                .tabItem {
                    VStack {
                        Image(systemName: "headphones")
                        Text("Library")
                    }
                }
                .tag(1)
            Text("Explore Page Coming Soon...")
                .font(.title)
                .padding(.horizontal)
                .tabItem {
                    VStack {
                        Image(systemName: "magnifyingglass")
                        Text("Explore")
                    }
                }
                .tag(2)
            RecordView()
                .tabItem {
                    VStack {
                        Image(systemName: "mic.fill")
                        Text("Record")
                    }
                }
                .tag(3)
        }
        .accentColor(.purple)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
        ContentView().environment(\.managedObjectContext, context).environmentObject(WhisperCollection())
    }
}
