//
//  RecordView.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/23/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI

class UserInput: ObservableObject {
    static let clearCode = String.Element(Unicode.Scalar(7))
    @Published var whisperValue = ""

    func clear() {
        self.whisperValue = String(Self.clearCode)
    }
}

struct RecordView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var whisperCollection: WhisperCollection
    
    @ObservedObject var audioRecorder: AudioRecorder = AudioRecorder()
    @ObservedObject var audioPlayer: AudioPlayer = AudioPlayer()
    
    @ObservedObject var userInput = UserInput()

    @State var hasRecorded: Bool = false
    
    @State var whisper: Whisper!
    
    @State var duration: Double = 0.0
    @State var progress: Double = 0.0
    
    @State var mainTimer: Timer?
    
    func updateProgress() {
        progress = (audioPlayer.currentTime / audioPlayer.duration)
        duration = audioPlayer.duration
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    userInput.clear()
                    if hasRecorded {
                        hasRecorded = false
                        audioRecorder.deleteRecording(urlToDelete: audioRecorder.soundURL)
                    }
                }, label: {
                    Text("CANCEL")
                        .foregroundColor(userInput.whisperValue == "" ? Color.gray : Color.black)
                })
                .disabled(userInput.whisperValue == "")
                Spacer()
                Button(action: {
                    whisper = Whisper(context: managedObjectContext)
                    
                    whisper.id = UUID()
                    whisper.value = userInput.whisperValue
                    whisper.type = "User"
                    whisper.soundFile = audioRecorder.soundURL!.absoluteString
                    
                    do {
                        try managedObjectContext.save()
                        print("saved!")
                        
                        userInput.clear()
                        hasRecorded = false
                        
                        whisperCollection.fetchWhispers(managedObjectContext: managedObjectContext)
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }, label: {
                    Text("SAVE")
                        .fontWeight(.bold)
                        .foregroundColor(!hasRecorded || userInput.whisperValue == "" ? Color.gray : Color.black)
                })
                .disabled(!hasRecorded || userInput.whisperValue == "")
            }
            .padding([.horizontal, .top])
            Text("record")
                .font(.largeTitle)
                .fontWeight(.semibold)
            Text("new whisper")
                .font(.largeTitle)
            VStack {
                Circle()
                    .fill(Color.gray)
                    .padding(.top)
                    .opacity(0.25)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Text("my whisper")
                            .font(.callout)
                            .padding([.top, .horizontal])
                            .multilineTextAlignment(.center)
                        , alignment: .center)
                HStack {
                    TextField("Whisper", text: $userInput.whisperValue)
                        .onReceive(userInput.whisperValue.publisher) { newValue in
                            if newValue == UserInput.clearCode {
                                userInput.whisperValue = ""
                            }
                        }
                        .padding()
                        .multilineTextAlignment(.center)
                        .accentColor(.pink)
                        .font(.title)
                }
                Spacer()
                if hasRecorded {
                    Slider(value: self.$progress)
                        .padding([.leading, .bottom, .trailing], 20.0)
                        .accentColor(.black)
                    HStack {
                        Spacer()
                        let tempDuration = ceil(duration)
                        let tempSeconds = Int(tempDuration.truncatingRemainder(dividingBy: 60))
                        let stringSeconds = (tempSeconds < 10 ? "0\(tempSeconds)" : "\(tempSeconds)")
                        Text("\(Int(floor(tempDuration/60))):\(stringSeconds)")
                            .font(.caption)
                    }
                    if !audioPlayer.isPlaying {
                        Button(action: {
                            audioPlayer.playRecording(audio: audioRecorder.soundURL)
                        }) {
                            Image(systemName: "play.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75, height: 75)
                                .clipped()
                                .foregroundColor(.pink)
                                .opacity(0.60)
                                .padding(.bottom, 40)
                        }
                    } else {
                        Button(action: {
                            audioPlayer.stop()
                        }) {
                            Image(systemName: "stop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 75, height: 75)
                                .clipped()
                                .foregroundColor(.pink)
                                .opacity(0.60)
                                .padding(.bottom, 40)
                        }
                    }
                }
            }
            .background(Color.white)
            Spacer()
            if !audioRecorder.recording {
                Button(action: {
                    if hasRecorded {
                        audioRecorder.deleteRecording(urlToDelete: audioRecorder.soundURL)
                    }
                
                    audioRecorder.startRecording()
                    
                    mainTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { mainTimer in
                            updateProgress()
                    })
                    
                    print("Start recording")
                }) {
                    Image(systemName: "smallcircle.fill.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 75, height: 75)
                        .clipped()
                        .foregroundColor(.pink)
                        .opacity(0.60)
                        .padding(.bottom, 40)
                }
                .padding(.top)
            } else {
                Button(action: {
                    audioRecorder.stopRecording()
                    self.hasRecorded = true
                    print("Stop recording")
                }) {
                    Image(systemName: "stop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 75, height: 75)
                        .clipped()
                        .foregroundColor(.pink)
                        .opacity(0.60)
                        .padding(.bottom, 40)
                }
                .padding(.top)
            }
        }
        .background(Color(red: 250 / 255, green: 235 / 255, blue: 235 / 255))
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView()
    }
}
