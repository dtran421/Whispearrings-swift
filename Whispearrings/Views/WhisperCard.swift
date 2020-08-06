//
//  WhisperCard.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI
import AVFoundation

struct WhisperCard: View {
    var whisper: Whisper!
    
    var audioPlayer: AudioPlayer
    
    var isPlaying: Bool
    
    func updateProgress() {
        progress = (audioPlayer.currentTime / audioPlayer.duration)
        duration = audioPlayer.duration
    }
    
    @Binding var progress: Double
    @Binding var duration: Double
    
    @State private var offset = CGFloat.zero
    
    let DRAG_MAX = CGFloat(-125)
    let DRAG_THRESHOLD = CGFloat(-50)
                            
    var body: some View {
        ZStack {
            HStack() {
                Spacer()
                Button(action: {}, label: {
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
                    if isPlaying {
                        VStack {
                            HStack {
                                Text(whisper.value!)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            Spacer()
                            Slider(value: self.$progress)
                                .accentColor(.black)
                            HStack {
                                Spacer()
                                let tempDuration = ceil(duration)
                                let tempSeconds = Int(tempDuration.truncatingRemainder(dividingBy: 60))
                                let stringSeconds = (tempSeconds < 10 ? "0\(tempSeconds)" : "\(tempSeconds)")
                                Text("\(Int(floor(tempDuration/60))):\(stringSeconds)")
                                    .font(.caption)
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "clock")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                        }
                    } else {
                        VStack {
                            HStack {
                                Text(whisper.value!)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                Image(systemName: "clock")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                            }
                        }
                    }
                    Spacer()
                    /*NavigationLink(destination: WhisperDetail(whisper: whisper)) {
                    }*/
                }
                .padding([.top, .leading, .bottom])
                .background(Color.white)
            }
            .offset(x: offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
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
                                offset += width * 0.5
                            }
                        }
                    }

                    .onEnded { gesture in
                        if offset > DRAG_THRESHOLD {
                            offset = 0
                        } else {
                            offset = DRAG_MAX
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
