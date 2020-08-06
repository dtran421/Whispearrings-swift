//
//  AudioPlayer.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/8/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI
import Foundation
import Combine
import AVFoundation

class AudioPlayer: NSObject, ObservableObject, AVAudioPlayerDelegate {
    
    let objectWillChange = PassthroughSubject<AudioPlayer, Never>()
    
    var audioPlayer: AVAudioPlayer!

    var isPlaying = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var currPlaying: UUID? {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    var currentTime: Double {
        get {
            guard audioPlayer != nil else {
                return 0.0
            }
            return audioPlayer.currentTime
        }
        set {
            audioPlayer.currentTime = newValue
        }
    }
    
    var duration: Double {
        get {
            guard audioPlayer != nil else {
                return 0.0
            }
            return audioPlayer.duration
        }
    }
    
    var finishedPlaying: Bool = true
    
    func playSound(whisper: Whisper) {
        if whisper.type == "Default" {
            let urlPath = Bundle.main.path(forResource: whisper.soundFile, ofType: "mp3")
            
            do {
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
                guard let urlPath = urlPath else {
                    return
                }
                
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: urlPath))
                audioPlayer.delegate = self
                
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
                isPlaying = true
                currPlaying = whisper.id
                finishedPlaying = false
                
                print("playing...")
            } catch {
                print("Something went wrong with playing default whisper!");
            }
        } else {
            do {
                try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
                
                audioPlayer = try AVAudioPlayer(contentsOf: URL(string: whisper.soundFile!)!)
                audioPlayer.delegate = self
                
                audioPlayer.prepareToPlay()
                audioPlayer.play()
                
                isPlaying = true
                currPlaying = whisper.id
                finishedPlaying = false
                
                print("playing...")
            } catch let error as NSError {
                print("Something went wrong with playing recording! \(error), \(error.userInfo)");
            }
        }
    }
    
    func playRecording(audio: URL) {
        let playbackSession = AVAudioSession.sharedInstance()
        
        do {
            try playbackSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing over the device's speakers failed")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audio)
            audioPlayer.delegate = self

            audioPlayer.prepareToPlay()
            audioPlayer.play()
            
            isPlaying = true
            finishedPlaying = false
            
            print("playing recording...")
        } catch {
            print("Playback failed.")
        }
    }
    
    func stop() {
        audioPlayer.stop()
        finishedPlaying = true
        isPlaying = false
        currentTime = 0.0
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            finishedPlaying = true
            currPlaying = nil
            isPlaying = false
            currentTime = 0.0
        }
    }
}
