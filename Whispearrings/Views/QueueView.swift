//
//  QueueView.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import Combine
import SwiftUI
import CoreData
import AVFoundation

class SettingsTracker {
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

struct QueueView: View {
    @EnvironmentObject var whisperCollection: WhisperCollection

    @ObservedObject var audioPlayer: AudioPlayer = AudioPlayer()
    
    @State var mainTimer: Timer?
    @State var queueTimer: Timer?
    
    @State var showTimingSheet: Bool = false

    @State var timing: Int
    @State var randomTiming: Bool
    @State var shufflePlay: Bool
    @State var repeatPlay: Bool
    
    @State var settingsTracker: SettingsTracker!
    
    @State var duration: Double = 0.0
    @State var progress: Double = 0.0
    
    var timings: Array<String> = ["5 minutes", "15 minutes", "30 minutes", "1 hour", "1.5 hours", "2 hours"]
    
    var times: Dictionary<Int, Double> = [0: 10, 1: 20, 2: 1800, 3: 3600, 4: 5400, 5: 7200]
    
    @State var whisperQueue: WhisperQueue<Whisper>?
        
    func generateQueue(whispers: Array<Whisper>) {
        var tempWhispers = whispers
        if shufflePlay {
            tempWhispers.shuffle()
        }
        
        var tempQueue = WhisperQueue<Whisper>()
        for whisper in tempWhispers {
            tempQueue.enqueue(whisper)
        }
        
        if randomTiming {
            queueTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { queueTimer in
                if !showTimingSheet {
                    if randomTiming {
                        if Int.random(in: 1 ..< 1000) % 10 == 1 {
                            playFromQueue()
                        }
                    } else {
                        playFromQueue()
                    }
                }
            })
        } else {
            queueTimer = Timer.scheduledTimer(withTimeInterval: times[Int(timing)]!, repeats: true, block: { queueTimer in
                if !showTimingSheet {
                    playFromQueue()
                }
            })
        }
        
        whisperQueue = tempQueue
    }
    
    /*
    var dailyPlays: Dictionary<String, DefaultWhisper>! {
        get {
            var times = [String: DefaultWhisper]()
            for i in 0 ..< whisperData.count {
                let temp_times = whisperData[i].times
                for j in 0 ..< temp_times.count {
                    times[temp_times[j]] = whisperData[i]
                }
            }

            return times
        }
    }*/
    
    func playFromQueue() {
        if !audioPlayer.finishedPlaying {
            updateProgress()
        } else {
            if !whisperQueue!.isEmpty {
                let playWhisper = whisperQueue!.dequeue()!
                audioPlayer.playSound(whisper: playWhisper)
                updateProgress()
                
                if repeatPlay {
                    whisperQueue!.enqueue(playWhisper)
                }
            }
        }
    }
    
    @State var currTime: String = ""
        
    func getCurrTime(date: Date) -> String {
        let calendar = Calendar.current
        let formattedDate = calendar.dateComponents([.hour, .minute], from: date)
        
        let hour = String(String(String(formattedDate.hour ?? 0).reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed())
        let minute = String(String(String(formattedDate.minute ?? 0).reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed())
        
        let output = "\(hour):\(minute)"
        //print("main \(output)")
        
        if !audioPlayer.finishedPlaying {
            //checkSoundTimes(currTime: output)
            updateProgress()
        }
        
        return output
    }
    
    /*func checkSoundTimes(currTime: String) {
        for (key, value) in dailyPlays {
            if key == currTime && audioPlayer.currPlaying != value.id {
                print("play!")
                audioPlayer.playSound(whisper: value)
                updateProgress()
            }
        }
    }*/
    
    func updateProgress() {
        progress = (audioPlayer.currentTime / audioPlayer.duration)
        duration = audioPlayer.duration
    }
            
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("queue")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("now playing")
                        .font(.title)
                        .fontWeight(.medium)
                }
                Spacer()
                Button(action: {
                    print("Open whisper sheet")
                    showTimingSheet.toggle()
                }, label: {
                    Image(systemName: "clock")
                        .resizable()
                        .frame(width: 32, height: 32, alignment: .center)
                        .foregroundColor(.black)
                })
                .padding(.top, -30.0)
            }
            .padding(.all)
            
            VStack {
                ScrollView (showsIndicators: false) {
                    ForEach (whisperCollection.queue, id: \.id) { whisper in WhisperCard(whisper: whisper, audioPlayer: audioPlayer, isPlaying: audioPlayer.currPlaying == whisper.id, progress: $progress, duration: $duration)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            if mainTimer == nil {
                mainTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { mainTimer in
                    if audioPlayer.isPlaying {
                        updateProgress()
                    }
                    if repeatPlay && whisperQueue != nil && whisperQueue!.isEmpty {
                        generateQueue(whispers: whisperCollection.queue)
                    }
                })
                generateQueue(whispers: whisperCollection.queue)
                
                settingsTracker = SettingsTracker(timing: timing, randomTiming: randomTiming, shufflePlay: shufflePlay, repeatPlay: repeatPlay)
            }
        }
        .onDisappear {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
                progress = 0.0
            }
        }
        .background(Color(red: 250 / 255, green: 235 / 255, blue: 235 / 255))
        .sheet(isPresented: $showTimingSheet, onDismiss: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate

            let managedObjectContext = appDelegate.persistentContainer.viewContext
                            
            do {
                let temp = try managedObjectContext.fetch(NSFetchRequest<QueueSettings>(entityName: "QueueSettings"))
                
                managedObjectContext.delete(temp[0])
                                
                let newSettings = QueueSettings(context: managedObjectContext)
                
                newSettings.timing = Int16(timing)
                newSettings.randomTiming = randomTiming
                newSettings.shufflePlay = shufflePlay
                newSettings.repeatPlay = repeatPlay
                
                generateQueue(whispers: whisperCollection.queue)
                                
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            
            do {
                try managedObjectContext.save()
                print("saved!")
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
            
            if timing != settingsTracker.initialTiming && !randomTiming {
                queueTimer = Timer.scheduledTimer(withTimeInterval: times[Int(timing)]!, repeats: true, block: { queueTimer in
                    if !showTimingSheet {
                        playFromQueue()
                    }
                })
                print("timing changed!")
            }
            if randomTiming != settingsTracker.initialRandomTiming {
                queueTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { queueTimer in
                    if !showTimingSheet {
                        if randomTiming {
                            if Int.random(in: 1 ..< 1000) % 10 == 1 {
                                playFromQueue()
                            }
                        } else {
                            playFromQueue()
                        }
                    }
                })
                print("random timing changed!")
            }
            if shufflePlay != settingsTracker.initialShufflePlay {
                generateQueue(whispers: whisperCollection.queue)
                print("shuffle play changed!")
            }
            
            settingsTracker.reset(newTiming: timing, newRandomTiming: randomTiming, newShufflePlay: shufflePlay, newRepeatPlay: repeatPlay)
        }) {
            TimingSheet(showTimingSheet: $showTimingSheet, timing: $timing, randomTiming: $randomTiming, shufflePlay: $shufflePlay, repeatPlay: $repeatPlay, timings: timings)
        }
    }
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        QueueView(timing: 2, randomTiming: false, shufflePlay: false, repeatPlay: false)
            .previewLayout(.fixed(width: 400, height: 500)).environmentObject(WhisperCollection())
    }
}
