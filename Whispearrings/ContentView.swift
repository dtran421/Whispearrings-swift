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
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var whisperCollection: WhisperCollection
    
    @ObservedObject var audioPlayer: AudioPlayer = AudioPlayer()
    @ObservedObject var audioRecorder: AudioRecorder = AudioRecorder()
    
    @State var mainTimer: Timer?
    @State var queueTimer: Timer?
    
    @State var paused: Bool = false
    
    @State var customTimes: Array<Time> = []
    @State var timeToWhisper: Dictionary<Time, Whisper> = [Time: Whisper]()
    @State var timeToTime: Dictionary<Time, String> = [Time: String]()
    
    @State var intervalChecked: String = ""
    @State var intervalCurrTime: String = ""
    
    func generateTimes() {
        for time in whisperCollection.times {
            if time.intervalMode {
                Timer.scheduledTimer(withTimeInterval: Double(time.timeInterval + 1) * 60, repeats: true, block: { _ in
                    if !paused {
                        playQueue.enqueue(time.whisper!)
                    }
                })
            } else if time.specificMode {
                customTimes.append(time)
                timeToTime[time] = DateFormatter.localizedString(from: time.specificTime, dateStyle: .none, timeStyle: .short)
                timeToWhisper[time] = time.whisper
            }
        }
    }
    
    @State var whisperQueue: WhisperQueue<Whisper> = WhisperQueue<Whisper>()
    
    func generateQueue() {
        var tempWhispers = whisperCollection.queue
        if shufflePlay {
            tempWhispers.shuffle()
        }
        
        var tempQueue = WhisperQueue<Whisper>()
        for whisper in tempWhispers {
            tempQueue.enqueue(whisper)
        }
        
        if randomTiming {
            queueTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { queueTimer in
                // TODO: Check randomness for desired time (max. 2 hours)
                if !paused && Int.random(in: 1 ..< 1000) % 10 == 1 && !whisperQueue.isEmpty {
                    playQueue.enqueue((whisperQueue.dequeue())!)
                }
            })
        } else {
            queueTimer = Timer.scheduledTimer(withTimeInterval: times[Int(timing)]!, repeats: true, block: { queueTimer in
                if !paused && !whisperQueue.isEmpty {
                    playQueue.enqueue(whisperQueue.dequeue()!)
                }
            })
        }
        
        whisperQueue = tempQueue
    }
    
    @State var playQueue: WhisperQueue<Whisper> = WhisperQueue<Whisper>()
    @State var mainChecked: String = ""
    @State var mainCurrTime: String = ""
    
    func playFromQueue() {
        if !audioPlayer.finishedPlaying {
            updateProgress()
        } else {
            if !playQueue.isEmpty {
                audioPlayer.playSound(whisper: playQueue.dequeue()!)
                updateProgress()
            }
        }
    }
    
    var timings: Array<String> = ["5 minutes", "15 minutes", "30 minutes", "1 hour", "1.5 hours", "2 hours"]
    
    // TODO: change 0 and 1 indexes to correct times
    var times: Dictionary<Int, Double> = [0: 10, 1: 20, 2: 1800, 3: 3600, 4: 5400, 5: 7200]
    
    @State var duration: Double = 0.0
    @State var progress: Double = 0.0
    
    func updateProgress() {
        progress = (audioPlayer.currentTime / audioPlayer.duration)
        duration = audioPlayer.duration
    }
        
    @State var showQueueTiming: Bool = false
        
    @ObservedObject var settingsTracker: SettingsTracker
    
    @State var timing: Int
    @State var randomTiming: Bool
    @State var shufflePlay: Bool
    @State var repeatPlay: Bool
    
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            VStack {
                if showQueueTiming {
                    QueueTimingView(showQueueTiming: $showQueueTiming, timing: $timing, randomTiming: $randomTiming, shufflePlay: $shufflePlay, repeatPlay: $repeatPlay, timings: timings)
                        .onDisappear() {
                            if shufflePlay != settingsTracker.initialShufflePlay {
                                generateQueue()
                                print("shuffle play changed!")
                            }
                            if randomTiming != settingsTracker.initialRandomTiming && randomTiming {
                                queueTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { queueTimer in
                                    if !paused && Int.random(in: 1 ..< 1000) % 10 == 1 && !whisperQueue.isEmpty {
                                        playQueue.enqueue(whisperQueue.dequeue()!)
                                    }
                                })
                                print("random timing changed!")
                            } else if timing != settingsTracker.initialTiming && !randomTiming {
                                queueTimer = Timer.scheduledTimer(withTimeInterval: times[Int(timing)]!, repeats: true, block: { queueTimer in
                                    if !paused && !whisperQueue.isEmpty {
                                        playQueue.enqueue(whisperQueue.dequeue()!)
                                    }
                                })
                                print("timing changed!")
                            }
                            
                            settingsTracker.reset(newTiming: timing, newRandomTiming: randomTiming, newShufflePlay: shufflePlay, newRepeatPlay: repeatPlay)
                        }
                } else {
                    QueueView(showQueueTiming: $showQueueTiming, timing: timing, randomTiming: randomTiming, shufflePlay: shufflePlay, repeatPlay: repeatPlay, duration: $duration, progress: $progress, timings: timings)
                        .environment(\.managedObjectContext, managedObjectContext)
                        .environmentObject(audioPlayer)
                }
            }
                .tabItem {
                    VStack {
                        Image(systemName: "music.note.list")
                        Text("Queue")
                    }
                }
                .tag(0)
            LibraryView()
                .environment(\.managedObjectContext, managedObjectContext)
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
            RecordView(paused: $paused)
                .environment(\.managedObjectContext, managedObjectContext)
                .environmentObject(whisperCollection)
                .environmentObject(audioRecorder)
                .tabItem {
                    VStack {
                        Image(systemName: "mic.fill")
                        Text("Record")
                    }
                }
                .tag(3)
        }
        .accentColor(.purple)
        .onAppear {
            if mainTimer == nil {
                mainTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { mainTimer in
                    updateProgress()
                    
                    if repeatPlay && whisperQueue.isEmpty {
                        generateQueue()
                    }
                    
                    if !whisperCollection.timesUpdated {
                        generateTimes()
                        whisperCollection.timesUpdated = true
                    }
                    
                    mainCurrTime = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short)
                    if mainCurrTime != mainChecked {
                        for time in customTimes {
                            if !paused && mainCurrTime == timeToTime[time] {
                                playQueue.enqueue(timeToWhisper[time]!)
                            }
                        }
                    }
                    mainChecked = mainCurrTime
                    
                    if !paused && !playQueue.isEmpty && !audioPlayer.isPlaying {
                        audioPlayer.playSound(whisper: playQueue.dequeue()!)
                    }
                })
                generateQueue()
            }
            paused = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                
        ContentView(settingsTracker: SettingsTracker(timing: 0, randomTiming: false, shufflePlay: false, repeatPlay: false), timing: 0, randomTiming: false, shufflePlay: false, repeatPlay: false).environment(\.managedObjectContext, context).environmentObject(WhisperCollection(newManagedObjectContext: context))
    }
}
