//
//  WhisperCard.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI
import AVFoundation
import CoreData

struct WhisperCard: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var whisperCollection: WhisperCollection
    @EnvironmentObject var selectedWhisper: SelectedWhisper
    @EnvironmentObject var audioPlayer: AudioPlayer

    var whisper: Whisper!
    
    var currPlaying: Bool
        
    @Binding var showTimingSheet: Bool
            
    @Binding var progress: Double
    @Binding var duration: Double
    
    func updateProgress() {
        progress = (audioPlayer.currentTime / audioPlayer.duration)
        duration = audioPlayer.duration
    }
    
    @State private var offset = CGFloat.zero
    
    let DRAG_MAX = CGFloat(-125)
    let DRAG_THRESHOLD = CGFloat(-50)
                            
    var body: some View {
        ZStack {
            HStack() {
                Spacer()
                Button(action: {
                    do {
                        let temp = try managedObjectContext.fetch(NSFetchRequest<QueueArray>(entityName: "QueueArray"))
                        
                        temp[0].removeFromQueue(whisper)
                                        
                    } catch let error as NSError {
                        print("Could not fetch. \(error), \(error.userInfo)")
                    }
                    
                    do {
                        try managedObjectContext.save()
                        print("saved new queue!")
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                    
                    whisperCollection.fetchQueue()
                    
                    offset = CGFloat.zero
                }, label: {
                    Text("Remove from Queue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 5)
                })
                .frame(maxWidth: abs(DRAG_MAX), maxHeight: .infinity)
                .background(Color.red)
            }
            .frame(maxHeight: .infinity)
            VStack(alignment: .leading) {
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
                    Image(systemName: currPlaying ? "stop.fill" : "play.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .padding(.trailing, 10.0)
                        .onTapGesture {
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
                        if currPlaying {
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
                            Image(systemName: "clock")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .onTapGesture {
                                    showTimingSheet.toggle()
                                    selectedWhisper.selectWhisper(newWhisper: whisper)
                                }
                        }
                    }
                    Spacer()
                }
                .padding([.top, .leading, .bottom])
                .background(Color.white)
            }
            .offset(x: offset)
            .gesture(
                DragGesture(minimumDistance: CGFloat(25))
                    .onChanged { gesture in
                        withAnimation(.easeOut) {
                            let width = gesture.translation.width
                            if width < 0 {
                                if offset + width < DRAG_MAX {
                                    offset = DRAG_MAX
                                } else {
                                    offset = width
                                }
                            } else {
                                if offset + width > 0 {
                                    offset = 0
                                } else {
                                    offset += (width / 5)
                                }
                            }
                        }
                    }

                    .onEnded { gesture in
                        withAnimation(.easeOut) {
                            if offset > DRAG_THRESHOLD {
                                offset = 0
                            } else {
                                offset = DRAG_MAX
                            }
                        }
                    }
            )
        }
    }
}

struct WhisperCard_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            /*WhisperCard(whisper: whisperData[0], currPlaying: true, progress: .constant(0.0),  duration: .constant(0.0))
            WhisperCard(whisper: whisperData[1], currPlaying: false, progress: .constant(0.0), duration: .constant(0.0))*/
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
