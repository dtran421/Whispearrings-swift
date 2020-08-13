//
//  AudioRecorder.swift
//  Whispearrings
//
//  Created by Duke Tran on 7/23/20.
//  Copyright © 2020 Whispearrings. All rights reserved.
//

import SwiftUI
import Foundation
import AVFoundation
import Combine

class AudioRecorder: ObservableObject {
    
    let objectWillChange = PassthroughSubject<AudioRecorder, Never>()
    
    var audioRecorder: AVAudioRecorder!
    
    var soundFile = ""
    var soundURL: URL!

    var recording = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    func startRecording() {
        let recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
        } catch {
            print("Failed to set up recording session")
        }
        
        let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-YY_'at'_HH:mm:ss"
                
        soundFile = "\(dateFormatter.string(from: Date())).m4a"
        soundURL = documentPath.appendingPathComponent(soundFile)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: soundURL, settings: settings)
            audioRecorder.record()

            recording = true
        } catch {
            print("Could not start recording")
        }
    }
    
    func stopRecording() {
        audioRecorder.stop()
        recording = false
    }
    
    func deleteRecording(urlToDelete: URL) {
        do {
           try FileManager.default.removeItem(at: urlToDelete)
        } catch {
            print("File could not be deleted!")
        }
    }
}
