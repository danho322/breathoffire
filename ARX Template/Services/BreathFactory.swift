//
//  BreathFactory.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/15/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation
import SwiftySound

enum BreathSound {
    case quickExhale, none
    
    func play() {
        switch self {
        case .quickExhale:
            Sound.play(file: "Breathe.m4a")
        default:
            break
        }
    }
}

class BreathParameter {
    let startTime: TimeInterval
    let breathTimeUp: TimeInterval
    let breathTimeDown: TimeInterval
    let playSound: BreathSound
    
    init(startTime: TimeInterval, breathTimeUp: TimeInterval, breathTimeDown: TimeInterval, playSound: BreathSound) {
        self.startTime = startTime
        self.breathTimeUp = breathTimeUp
        self.breathTimeDown = breathTimeDown
        self.playSound = playSound
    }
}

func ==<T: BreathParameter>(lhs: T, rhs: T) -> Bool {
    return lhs.startTime == rhs.startTime &&
        rhs.breathTimeUp == lhs.breathTimeUp &&
        rhs.breathTimeDown == lhs.breathTimeDown
}

enum BreathProgram: Int {
    case oneOne = 0
    case threeOne = 1
    case fiveTwo = 2
    case tenThree = 3
    case fifteenFour = 4
    case twentyFive = 5
    
    // fake times
    func parameterArray() -> [BreathParameter] {
        switch self {
        case .oneOne:
            let parameter0 = BreathParameter(startTime: 0, breathTimeUp: 0.1, breathTimeDown: 0.4, playSound: .quickExhale)
            let parameter1 = BreathParameter(startTime: 15, breathTimeUp: 2, breathTimeDown: 2, playSound: .none)
            return [parameter0, parameter1]
        case .threeOne:
            let parameter0 = BreathParameter(startTime: 0, breathTimeUp: 0.1, breathTimeDown: 0.4, playSound: .quickExhale)
            let parameter1 = BreathParameter(startTime: 60, breathTimeUp: 2, breathTimeDown: 2, playSound: .none)
            return [parameter0, parameter1]
        case .fiveTwo:
            let parameter0 = BreathParameter(startTime: 0, breathTimeUp: 0.1, breathTimeDown: 0.4, playSound: .quickExhale)
            let parameter1 = BreathParameter(startTime: 60, breathTimeUp: 2, breathTimeDown: 2, playSound: .none)
            return [parameter0, parameter1]
        case .tenThree:
            let parameter0 = BreathParameter(startTime: 0, breathTimeUp: 0.1, breathTimeDown: 0.4, playSound: .quickExhale)
            let parameter1 = BreathParameter(startTime: 60, breathTimeUp: 2, breathTimeDown: 2, playSound: .none)
            return [parameter0, parameter1]
        case .fifteenFour:
            let parameter0 = BreathParameter(startTime: 0, breathTimeUp: 0.1, breathTimeDown: 0.4, playSound: .quickExhale)
            let parameter1 = BreathParameter(startTime: 60, breathTimeUp: 2, breathTimeDown: 2, playSound: .none)
            return [parameter0, parameter1]
        case .twentyFive:
            let parameter0 = BreathParameter(startTime: 0, breathTimeUp: 0.1, breathTimeDown: 0.4, playSound: .quickExhale)
            let parameter1 = BreathParameter(startTime: 60, breathTimeUp: 2, breathTimeDown: 2, playSound: .none)
            return [parameter0, parameter1]
        }
    }
    
    func sessionTime() -> TimeInterval {
        switch self {
        case .oneOne:
            return 120
        case .threeOne:
            return 120
        case .fiveTwo:
            return 120
        case .tenThree:
            return 120
        case .fifteenFour:
            return 120
        case .twentyFive:
            return 120
        }
    }
}

class BreathFactory {
//    Breath of fire timer
//    1 minute breath X 1 minute rest
//    3 minute breath X 1 minute rest
//    5 minute Breath X 2 minute rest
//    10 minute breath X 3 minute rest
//    15 minute breath X 4 minute rest
//    20 minute breath X 5 minute rest
}