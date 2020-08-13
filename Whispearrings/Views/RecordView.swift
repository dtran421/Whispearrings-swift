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
        whisperValue = String(UserInput.clearCode)
        hideKeyboard()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct RecordView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var whisperCollection: WhisperCollection
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    @ObservedObject var audioPlayer: AudioPlayer = AudioPlayer()
    
    @ObservedObject var userInput = UserInput()

    @State var hasRecorded: Bool = false
    
    @State var whisper: Whisper!
    
    @State var duration: Double = 0.0
    @State var progress: Double = 0.0
    
    @State var mainTimer: Timer!
    
    @Binding var paused: Bool
    
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
                        .foregroundColor((userInput.whisperValue != "" || hasRecorded) ? Color.black : Color.gray)
                })
                .disabled(userInput.whisperValue == "" && !hasRecorded)
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
                        
                        whisperCollection.fetchWhispers()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }, label: {
                    Text("SAVE")
                        .fontWeight(.bold)
                        .foregroundColor((!hasRecorded || userInput.whisperValue == "") ? Color.gray : Color.black)
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
                    // TODO: Fix slider progress
                    Slider(value: $progress)
                        .padding([.leading, .trailing], 30)
                        .padding(.bottom, -10)
                        .accentColor(.black)
                        .animation(.linear)
                    HStack {
                        Spacer()
                        let tempDuration = ceil(duration)
                        let tempSeconds = Int(tempDuration.truncatingRemainder(dividingBy: 60))
                        let stringSeconds = (tempSeconds < 10 ? "0\(tempSeconds)" : "\(tempSeconds)")
                        Text("\(Int(floor(tempDuration/60))):\(stringSeconds)")
                            .font(.body)
                            .padding(.trailing, 30)
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
        .onAppear() {
            paused = true
            mainTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
                updateProgress()
            })
        }
        .onDisappear() {
            paused = false
        }
        .background(Color(red: 250 / 255, green: 235 / 255, blue: 235 / 255))
    }
}

struct RecordView_Previews: PreviewProvider {
    static var previews: some View {
        RecordView(paused: .constant(false))
    }
}
