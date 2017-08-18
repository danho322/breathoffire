//
//  BreatheViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/9/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class BreatheViewController: UIViewController {
    @IBOutlet weak var breathTimeView: BreathTimerView!
    
    internal var breathTimerService: BreathTimerService?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let parameter0 = BreathParameter(startTime: 0, breathTimeUp: 0.1, breathTimeDown: 0.4, playSound: .none)
        let parameter1 = BreathParameter(startTime: 5, breathTimeUp: 2, breathTimeDown: 2, playSound: .none)
        let parameter2 = BreathParameter(startTime: 13, breathTimeUp: 0.1, breathTimeDown: 0.4, playSound: .none)
        breathTimerService = BreathTimerService(sessionTime: 15, parameterQueue: [parameter0, parameter1, parameter2], delegate: self)
    }

}

extension BreatheViewController: BreathTimerServiceDelegate {
    func breathTimerDidTick(timestamp: TimeInterval, nextParameterTimestamp: TimeInterval, currentParameter: BreathParameter?) {
        breathTimeView.update(timestamp: timestamp, nextParameterTimestamp: nextParameterTimestamp, breathParameter: currentParameter)
    }
    
    func breathTimeDidFinish() {
        breathTimeView.isRunning = false
    }
}
