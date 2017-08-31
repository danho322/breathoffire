//
//  BreathTimerService.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/8/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation
import SwiftySound

protocol BreathTimerServiceDelegate {
    func breathTimerDidTick(timestamp: TimeInterval, nextParameterTimestamp: TimeInterval, currentParameter: BreathParameter?)
    func breathTimeDidFinish()
}

class BreathTimerService: NSObject {
    let delegate: BreathTimerServiceDelegate!
    let breathProgram: BreathProgram!
    
    internal var timer: Timer?
    internal var currentTime: TimeInterval = 0
    internal var timeInterval: TimeInterval = 1

    init(breathProgram: BreathProgram, delegate: BreathTimerServiceDelegate) {
        self.breathProgram = breathProgram
        self.delegate = delegate
        super.init()
    
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self,   selector: (#selector(BreathTimerService.updateTimer)), userInfo: nil, repeats: true)
        scheduleSounds()
    }
    
    func scheduleSounds() {
        for soundContainer in breathProgram.soundArray() {
            self.perform(#selector(BreathTimerService.fireSound(soundName:)), with: soundContainer.sound.rawValue, afterDelay: soundContainer.timestamp - currentTime)
        }
    }
    
    @objc func fireSound(soundName: String) {
        Sound.play(file: soundName)
    }
    
    func pause() {
        timer?.invalidate()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    func resume() {
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self,   selector: (#selector(BreathTimerService.updateTimer)), userInfo: nil, repeats: true)
        scheduleSounds()
    }
    
    func stop() {
        timer?.invalidate()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        delegate.breathTimeDidFinish()
    }
    
    @objc func updateTimer() {
        currentTime += timeInterval
        
        let sessionTime = breathProgram.sessionTime()
        let parameterQueue = breathProgram.parameterArray()
        if currentTime >= sessionTime {
            timer?.invalidate()
            Sound.play(file: "gong.m4a")
            delegate.breathTimeDidFinish()
        }
        
        // latest parameter with startime before current time
        let currentParameter = parameterQueue
            .filter({ [unowned self] parameter in
                return parameter.startTime <= self.currentTime
            })
            .sorted(by: { p1, p2 in
                return p1.startTime < p2.startTime
            })
            .last
        
        var nextTimestamp: TimeInterval = sessionTime
        let nextParameter = parameterQueue
            .filter({ [unowned self] parameter in
                return parameter.startTime > self.currentTime
            })
            .sorted(by: { p1, p2 in
                return p1.startTime < p2.startTime
            })
            .first
        if let nextParameter = nextParameter {
            nextTimestamp = nextParameter.startTime
        }

        delegate.breathTimerDidTick(timestamp: currentTime, nextParameterTimestamp: nextTimestamp, currentParameter: currentParameter)
    }
    
    class func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}
