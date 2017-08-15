//
//  BreathTimerService.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/8/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation

enum BreathState {
    case start, pause
}

class BreathParameter {
    let startTime: TimeInterval
    let breathTimeUp: TimeInterval
    let breathTimeDown: TimeInterval
    
    init(startTime: TimeInterval, breathTimeUp: TimeInterval, breathTimeDown: TimeInterval) {
        self.startTime = startTime
        self.breathTimeUp = breathTimeUp
        self.breathTimeDown = breathTimeDown
    }
}

func ==<T: BreathParameter>(lhs: T, rhs: T) -> Bool {
    return lhs.startTime == rhs.startTime &&
        rhs.breathTimeUp == lhs.breathTimeUp &&
        rhs.breathTimeDown == lhs.breathTimeDown
}

protocol BreathTimerServiceDelegate {
    func breathTimerDidTick(timestamp: TimeInterval, nextParameterTimestamp: TimeInterval, currentParameter: BreathParameter?)
    func breathTimeDidFinish()
}

class BreathTimerService: NSObject {
    let sessionTime: TimeInterval!
    let delegate: BreathTimerServiceDelegate!
    let parameterQueue: [BreathParameter]!

    internal var timer: Timer?
    internal var currentTime: TimeInterval = 0
    internal var timeInterval: TimeInterval = 1

    init(sessionTime: TimeInterval, parameterQueue: [BreathParameter], delegate: BreathTimerServiceDelegate) {
        self.sessionTime = sessionTime
        self.parameterQueue = parameterQueue
        self.delegate = delegate
        super.init()
    
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self,   selector: (#selector(BreathTimerService.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        currentTime += timeInterval
        
        if currentTime >= sessionTime {
            timer?.invalidate()
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
//        print("\(currentParameter?.timestamp) / \(nextTimestamp)")

        delegate.breathTimerDidTick(timestamp: currentTime, nextParameterTimestamp: nextTimestamp, currentParameter: currentParameter)
    }
    
    class func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}
