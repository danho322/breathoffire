//
//  AudioDetectionService.swift
//  ARX Template
//
//  Created by Daniel Ho on 1/11/18.
//  Copyright © 2018 Daniel Ho. All rights reserved.
//

import Foundation
import AVFoundation

class AudioDetectionService: NSObject {
    static let sharedInstance = AudioDetectionService()
    
    var audioRecorder:AVAudioRecorder!
    var audioPlayer:AVAudioPlayer!
    var shouldAnalyze: Bool = false
    
    let recordSettings: [String : AnyObject] = [AVSampleRateKey : NSNumber(value: Float(16000)),
                                                AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),
                                                AVNumberOfChannelsKey : NSNumber(value: 1),
                                                AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.low.rawValue))]

    
    override init() {
        super.init()
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioRecorder = AVAudioRecorder(url: directoryURL()!, settings: recordSettings)
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
        } catch {}
    }
    
    // MARK: - BPM
    
    func getCurrentBPM() {
        stop()
        record()
        
        perform(#selector(stopAndAnalyze), with: nil, afterDelay: 5)
    }
    
    @objc func stopAndAnalyze() {
        shouldAnalyze = true
        
        stop()
    }
    
    // MARK: - AVFoundation
    
    func record() {
        if !audioRecorder.isRecording {
            let audioSession = AVAudioSession.sharedInstance()
            do {
                try audioSession.setActive(true)
                audioRecorder.record()
            } catch {}
        }
    }
    
    func play() {
        if !audioRecorder.isRecording {
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: audioRecorder.url)
                print("Playing audio: \(audioPlayer.play())")
            } catch {
                print("caught an error")
            }
        }
    }
    
    func stop() {
        audioRecorder.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setActive(false)
        } catch {}
    }
    
    // MARK: - Internal
    
    func directoryURL() -> URL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
        let soundURL = documentDirectory.appendingPathComponent("recordedAudio.m4a")
        return soundURL
    }
}

extension AudioDetectionService: AVAudioRecorderDelegate {
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("audio recorder error: \(error)")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("audio recorder did finish successfully: \(flag)")
        if flag {
            let fileManager = FileManager.default
            print("exists? \(fileManager.fileExists(atPath: recorder.url.path))")
            
            
            
            
        }
        if shouldAnalyze {
//            play()
            let ret = BPMAnalyzer.core.getBpmFrom(recorder.url, completion: {[weak self] (bpm) in
                print("CURENT BPM \(bpm)")
            })
            print("superpower: \(ret)")
        }
        shouldAnalyze = false
    }
}
