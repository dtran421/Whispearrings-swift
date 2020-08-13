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

struct QueueView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var whisperCollection: WhisperCollection
    @EnvironmentObject var selectedWhisper: SelectedWhisper
    @EnvironmentObject var audioPlayer: AudioPlayer
        
    @Binding var showQueueTiming: Bool
    @State var showTimingSheet: Bool = false
    
    @State var timing: Int
    @State var randomTiming: Bool
    @State var shufflePlay: Bool
    @State var repeatPlay: Bool
    
    @Binding var duration: Double
    @Binding var progress: Double
    
    var timings: Array<String>
    
    @State var currTime: String = ""
        
    func getCurrTime(date: Date) -> String {
        let calendar = Calendar.current
        let formattedDate = calendar.dateComponents([.hour, .minute], from: date)
        
        let hour = String(String(String(formattedDate.hour ?? 0).reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed())
        let minute = String(String(String(formattedDate.minute ?? 0).reversed()).padding(toLength: 2, withPad: "0", startingAt: 0).reversed())
        
        let output = "\(hour):\(minute)"
        
        if !audioPlayer.finishedPlaying {
            updateProgress()
        }
        
        return output
    }
    
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
                    print("Show queue timing view")
                    showQueueTiming.toggle()
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
                    ForEach (whisperCollection.queue, id: \.id) { whisper in WhisperCard(whisper: whisper, currPlaying: audioPlayer.currPlaying == whisper.id, showTimingSheet: $showTimingSheet, progress: $progress, duration: $duration)
                            .environment(\.managedObjectContext, managedObjectContext)
                    }
                    Spacer()
                }
            }
        }
        .onDisappear {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
                audioPlayer.currPlaying = nil
                progress = 0.0
            }
        }
        .background(Color(red: 250 / 255, green: 235 / 255, blue: 235 / 255))
        .sheet(isPresented: $showTimingSheet, content: {
            CustomTimingSheet(whisper: selectedWhisper.whisper, isPlaying: audioPlayer.currPlaying == selectedWhisper.whisper.id, showTimingSheet: $showTimingSheet, progress: $progress, duration: $duration, intervalActive: selectedWhisper.intervalMode, specificActive: selectedWhisper.specificMode, timeInterval: Int(selectedWhisper.timeInterval), specificTime: selectedWhisper.specificTime)
                .environment(\.managedObjectContext, managedObjectContext)
                .environmentObject(audioPlayer)
                .environmentObject(whisperCollection)
        })
    }
}

struct QueueView_Previews: PreviewProvider {
    static var previews: some View {
        /*QueueView(showQueueTiming: .constant(false), selectedWhisper: Whisper(), timing: 2, randomTiming: false, shufflePlay: false, repeatPlay: false, duration: .constant(0.0), progress: .constant(0.0), timings: ["5 minutes", "15 minutes", "30 minutes", "1 hour", "1.5 hours", "2 hours"])
            .previewLayout(.fixed(width: 400, height: 500)).environmentObject(WhisperCollection()).environmentObject(Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: {_ in }))*/
        Text("test")
    }
}
