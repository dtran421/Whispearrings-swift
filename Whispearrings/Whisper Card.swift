//
//  Whisper Card.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/3/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI
import UIKit
import AVFoundation

var player: AVAudioPlayer!

struct Whisper_Card: View {
    var whisper: Whisper!
        
    @State var currTime : String = ""
    
    @State var isLoaded: Bool = false
    
    @State var dailyPlays: Dictionary<String, Bool>!
    
    func loadTimes() {
        self.dailyPlays = Dictionary(uniqueKeysWithValues: zip(whisper.times, Array(repeating: false, count: whisper.times.count)))
        self.isLoaded = true
    }
    
    func getCurrTime(date: Date) -> String {
        if !self.isLoaded {self.loadTimes()}
        
        let calendar = Calendar.current
        let formattedDate = calendar.dateComponents([.hour, .minute], from: date)
        let output = "\(formattedDate.hour ?? 00):\(formattedDate.minute ?? 00)"
        self.checkSoundTimes(dailyPlays: &self.dailyPlays, currTime: output)
        return output
    }
    
    func checkSoundTimes(dailyPlays: inout Dictionary<String, Bool>, currTime: String) {
        for i in 0 ..< whisper.times.count {
            if whisper.times[i] == currTime && !dailyPlays[whisper.times[i]]! {
                print("play!")
                dailyPlays[whisper.times[i]] = true
                self.playSound()
            }
        }
    }
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    func playSound() {
        if let player = player, player.isPlaying {
            player.stop()
        } else {
            let urlPath = Bundle.main.path(forResource: "To live is the rarest", ofType: "mp3")
            
            do {
                try AVAudioSession.sharedInstance().setMode(.default)
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
                guard let urlPath = urlPath else {
                    return
                }
                
                player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPath))
                player.delegate = (player as! AVAudioPlayerDelegate)
                
                guard let player = player else {
                    return
                }
                
                player.play()
            } catch {
                print("Something went wrong!");
            }
        }
    }
    
    mutating func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        dailyPlays["test"] = true
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    self.playSound()
                }) {
                    Image("first")
                }
                Text(whisper.value)
                Spacer()
                Text(currTime).onReceive(timer) { input in self.currTime = "\(self.getCurrTime(date: input))"
                }.hidden()
            }
            .padding(.leading)
        }
    }
}

struct Whisper_Card_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Whisper_Card(whisper: whisperData[0])
            Whisper_Card(whisper: whisperData[1])
        }
        .previewLayout(.fixed(width: 300, height: 70))
    }
}
