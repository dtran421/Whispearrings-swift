//
//  CustomTimingSheet.swift
//  Whispearrings
//
//  Created by Duke Tran on 8/9/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI
import CoreData

struct CustomTimingSheet: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var audioPlayer: AudioPlayer
    @EnvironmentObject var whisperCollection: WhisperCollection
    
    var whisper: Whisper
        
    var isPlaying: Bool
    
    @Binding var showTimingSheet: Bool
    
    @Binding var progress: Double
    @Binding var duration: Double
    
    func updateProgress() {
        progress = (audioPlayer.currentTime / audioPlayer.duration)
        duration = audioPlayer.duration
    }
    
    @State var intervalActive: Bool
    @State var specificActive: Bool
    @State var timeInterval: Int
    @State var specificTime: Date
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    showTimingSheet.toggle()
                }, label: {
                    Text("CANCEL")
                        .accentColor(.black)
                })
                Spacer()
                Button(action: {
                    let tempTimes = whisper.times as! Set<Time>
                    if !tempTimes.isEmpty {
                        let tempTime = tempTimes.first!
                        
                        whisper.removeFromTimes(tempTime)
                            
                        managedObjectContext.delete(tempTime)
                    }
                                        
                    if intervalActive || specificActive {
                        let newTime = Time(context: managedObjectContext)

                        newTime.intervalMode = intervalActive
                        newTime.specificMode = specificActive
                        newTime.timeInterval = intervalActive ? Int16(timeInterval) : 0
                        newTime.specificTime = specificActive ? specificTime : Date()
                        
                        whisper.addToTimes(newTime)
                    }
                                        
                    do {
                        try managedObjectContext.save()
                        print("saved new time setting!")
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    whisperCollection.fetchTimes()
                    
                    showTimingSheet.toggle()
                }, label: {
                    Text("SAVE")
                        .fontWeight(.bold)
                        .accentColor(.black)
                })
            }
            .padding([.leading, .trailing])
            .padding(.top, 20)
            Image(systemName: "clock")
                .resizable()
                .frame(width: 35, height: 35)
                .padding(.top, -30)
            Text("whisper this:")
                .font(.title)
                .padding(.bottom, 20)
            Spacer()
            HStack {
                if whisper.type == "Default" {
                    Image("default")
                        .resizable()
                        .frame(width: 100, height: 100)
                } else {
                    Circle()
                        .fill(Color.gray)
                        .opacity(0.25)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Text("my whisper")
                                .font(.callout))
                }
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .padding(.trailing, 10.0)
                    .onTapGesture() {
                        if audioPlayer.isPlaying {
                            audioPlayer.stop()
                        }
                        if audioPlayer.currPlaying != whisper.id {
                            audioPlayer.playSound(whisper: whisper)
                            updateProgress()
                        } else {
                            audioPlayer.currPlaying = nil
                        }
                    }
                VStack {
                    HStack {
                        Text(whisper.value!)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    Spacer()
                    if isPlaying {
                        Slider(value: self.$progress)
                            .accentColor(.black)
                            .animation(.linear)
                        HStack {
                            Spacer()
                            let tempDuration = ceil(duration)
                            let tempSeconds = Int(tempDuration.truncatingRemainder(dividingBy: 60))
                            let stringSeconds = (tempSeconds < 10 ? "0\(tempSeconds)" : "\(tempSeconds)")
                            Text("\(Int(floor(tempDuration/60))):\(stringSeconds)")
                                .font(.caption)
                        }
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Image(systemName: "clock.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .foregroundColor(.red)
                            .opacity(0.50)
                    }
                    .padding(.trailing, 10)
                }
            }
            .padding([.top, .leading, .bottom])
            .background(Color.white)
            HStack {
                Button(action: {
                    intervalActive.toggle()
                    if intervalActive {
                        specificActive = false
                    }
                }, label: {
                    Image(systemName: intervalActive ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                })
                .padding(.leading, 35)
                Spacer()
                HStack {
                    Text("every")
                        .font(.headline)
                        .fontWeight(.medium)
                    Picker(selection: $timeInterval, label: Text("")) {
                        ForEach (1 ..< 60) { minute in
                            Text("\(minute)").tag(minute)
                        }
                    }
                    .frame(width: 50, height: 175)
                    .clipped()
                    Text("minutes")
                        .font(.headline)
                        .fontWeight(.medium)
                }
                Spacer()
            }
            ZStack {
                Divider()
                    .frame(height: 4)
                    .background(Color.red)
                    .opacity(0.10)
                Text("OR")
                    .font(.title)
            }
            HStack {
                Button(action: {
                    specificActive.toggle()
                    if specificActive {
                        intervalActive = false
                    }
                }, label: {
                    Image(systemName: specificActive ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                })
                .padding(.horizontal, 35)
                Text("at specific time:")
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
            }
            DatePicker(selection: $specificTime, displayedComponents: .hourAndMinute) {}
                .labelsHidden()
                .frame(height: 175)
            //Spacer()
        }
        .background(Color(red: 250 / 255, green: 235 / 255, blue: 235 / 255))
        .frame(maxHeight: .infinity)
    }
}

struct CustomTimingSheet_Previews: PreviewProvider {
    static var previews: some View {
        /*CustomTimingSheet(whisper: Whisper(), audioPlayer: AudioPlayer(), isPlaying: false, progress: .constant(0.0), duration: .constant(0.0))*/
        Text("test")
    }
}
