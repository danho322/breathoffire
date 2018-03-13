//
//  InstructionService.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/25/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation
import AVFoundation

protocol InstructionServiceDelegate {
    func didUpdateInstruction(instruction: AnimationInstructionData, index: Int?)
}

class InstructionService: NSObject {
    internal var instructionDataArray: [AnimationInstructionData] = []
    internal var startTime = Date()
    internal var pauseTime = Date()
    internal var currentSpeed: Double = 1
    internal let synth = AVSpeechSynthesizer()
    
    var delegate: InstructionServiceDelegate!
    
    init(delegate: InstructionServiceDelegate) {
        self.delegate = delegate
        super.init()
    }
    
    init(instructionDataArray: [AnimationInstructionData], delegate: InstructionServiceDelegate) {
        self.instructionDataArray = instructionDataArray
        self.delegate = delegate
        super.init()
    }
    
    func updateInstructions(instructionDataArray: [AnimationInstructionData]) {
        self.instructionDataArray = instructionDataArray
    }
    
    func start(speed: Double = 1, timeOffset: TimeInterval = 0) {
        // todo: add those ^^
        startTime = Date()
        currentSpeed = speed
        for instruction in instructionDataArray {
            self.perform(#selector(fireInstruction(instruction:)), with: instruction, afterDelay: (instruction.timestamp / 1000) / currentSpeed)
        }
    }
    
    func stop() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    func pause() {
        pauseTime = Date()
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    func resume() {
        let offset = pauseTime.timeIntervalSince(startTime) * currentSpeed
        for instruction in instructionDataArray {
            let delay = (instruction.timestamp - offset) / currentSpeed
            if (delay > 0) {
                self.perform(#selector(fireInstruction(instruction:)), with: instruction, afterDelay: delay)
            }
        }
    }
    
    @objc func fireInstruction(instruction: Any) {
        if let instruction = instruction as? AnimationInstructionData {
            
            let index = instructionDataArray.index(where: { $0.timestamp == instruction.timestamp && $0.text == instruction.text })
            
            delegate.didUpdateInstruction(instruction: instruction, index: index)
            
            if let soundID = instruction.soundID, let breathSound = BreathSound(rawValue: soundID) {
                breathSound.play()
            }
            
//            let myUtterance = AVSpeechUtterance(string: instruction.text)
//            myUtterance.rate = 0.4
//            synth.speak(myUtterance)
        }
    }
}
