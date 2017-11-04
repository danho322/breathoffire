//
//  BreathTimerView.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/8/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import SwiftySound

class BreathTimerView: XibView {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var fireContainerImageView: UIImageView!
    @IBOutlet weak var centerImageView: UIImageView!
    
    internal let circlePathLayer = CAShapeLayer()
    internal let circleRadius: CGFloat = 110
    internal var currentBreathParameter: BreathProgramParameter?
    var isRunning = false
    internal var breathCount = 0
    
    var progress: CGFloat {
        get {
            return circlePathLayer.strokeEnd
        }
        set {
            if (newValue > 1) {
                circlePathLayer.strokeEnd = 1
            } else if (newValue < 0) {
                circlePathLayer.strokeEnd = 0
            } else {
                circlePathLayer.strokeEnd = newValue
            }
        }
    }
    
    override func setupUI() {
        guard let view = view as? BreathTimerView else {
            fatalError("view is not of type BreathTimerView")
        }
        
        isUserInteractionEnabled = false
        view.isUserInteractionEnabled = false
        view.fireContainerImageView.layer.cornerRadius = 110
        view.fireContainerImageView.layer.masksToBounds = true
        circlePathLayer.frame = view.fireContainerImageView.frame
        circlePathLayer.lineWidth = 4
        circlePathLayer.fillColor = UIColor.clear.cgColor
        circlePathLayer.strokeColor = UIColor.clear.cgColor // invisible until deemed necessary for a future feature
        view.layer.addSublayer(circlePathLayer)
        
        progress = 0
        
        view.timeLabel.text = BreathTimerService.timeString(time: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let view = view as? BreathTimerView else {
            return
        }
        
        circlePathLayer.frame = CGRect(x: view.fireContainerImageView.frame.origin.x, y: view.fireContainerImageView.frame.origin.y, width: view.fireContainerImageView.frame.size.width, height: view.fireContainerImageView.frame.size.height)
        circlePathLayer.path = circlePath().cgPath
        
        view.centerImageView.layer.cornerRadius = view.centerImageView.frame.size.width / 2
        view.centerImageView.layer.masksToBounds = true
    }
    
    func hideBreathUI(_ isHidden: Bool) {
        guard let view = view as? BreathTimerView else {
            return
        }
        
        view.fireContainerImageView.isHidden = isHidden
        view.timeLabel.isHidden = isHidden
        view.centerImageView.isHidden = isHidden
    }
    
    func updateAlpha(_ alpha: CGFloat) {
        
        guard let view = view as? BreathTimerView else {
            return
        }
        
        view.fireContainerImageView.alpha = alpha
        view.timeLabel.alpha = alpha
        view.centerImageView.alpha = alpha
    }
    
    func circleFrame() -> CGRect {
        var circleFrame = CGRect(x: 0, y: 0, width: 2 * circleRadius, height: 2 * circleRadius)
        circleFrame.origin.x = circlePathLayer.bounds.midX - circleFrame.midX + 0//20
        circleFrame.origin.y = circlePathLayer.bounds.midY - circleFrame.midY + 0//46
        return circleFrame
    }
    
    func circlePath() -> UIBezierPath {
        return UIBezierPath(ovalIn: circleFrame())
    }
    
    func onStart() {
        breathCount = 0
    }
    
    func currentBreathCount() -> Int {
        return breathCount
    }
    
    func updateTimeLabel(_ timeInterval: TimeInterval) {
        guard let view = view as? BreathTimerView else {
            fatalError("view is not of type BreathTimerView")
        }
        
        view.timeLabel.text = BreathTimerService.timeString(time: timeInterval)
    }

    func update(timestamp: TimeInterval, nextParameterTimestamp: TimeInterval, breathParameter: BreathProgramParameter?, sessionTimestamp: TimeInterval? = nil) {
        guard let view = view as? BreathTimerView else {
            fatalError("view is not of type BreathTimerView")
        }

        if let sessionTimestamp = sessionTimestamp {
            view.timeLabel.text = BreathTimerService.timeString(time: sessionTimestamp)
        } else {
            view.timeLabel.text = BreathTimerService.timeString(time: timestamp)
        }
       
        if let currentBreathParameter = currentBreathParameter,
            let breathParameter = breathParameter {
           
            var length = nextParameterTimestamp
            length -= breathParameter.startTime
            
            progress = CGFloat(timestamp - currentBreathParameter.startTime) / CGFloat(length)
            if breathParameter == currentBreathParameter {
                
                print("is same parameter")
                return
            }
            
            progress = timestamp > 0 ? 1 : 0
        }
        // update the animations here
        currentBreathParameter = breathParameter
        isRunning = currentBreathParameter != nil
        doBreathAnimation()
    }
    
    func handleStart() {
        currentBreathParameter = nil
        isRunning = true
    }
    
    func finishTimer() {
        isRunning = false
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveLinear],
                       animations: {
                        self.alpha = 0
                        
        },
                       completion: { finished in
        })
    }
    
    // MARK: - Animations
    
    @objc internal func doBreathAnimation() {
        guard let view = view as? BreathTimerView else {
            fatalError("view is not of type BreathTimerView")
        }
        print("doBreathAnimation, \(currentBreathParameter), \(isRunning)")
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(BreathTimerView.doBreathAnimation), object: nil)
        if let currentBreatheParameter = currentBreathParameter, isRunning {
            print("isRunning: \(self), \(view)")
            let sound = BreathSound(rawValue: currentBreatheParameter.soundID)
            sound?.play()
            
            breathCount += 1
            let fireView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.fireContainerImageView.frame.size.width, height: view.fireContainerImageView.frame.size.height))
            fireView.center = view.fireContainerImageView.center
//            fireView.image = UIImage(named: "FireEmoji")
            fireView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
            fireView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            view.addSubview(fireView)
            UIView.animate(withDuration: currentBreatheParameter.breathTimeUp,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                            fireView.transform = CGAffineTransform.identity
                            fireView.alpha = 0.1
            },
                           completion: { finished in
                            self.breatheInView(fireView)
                            print("schedulign in \(currentBreatheParameter.breathTimeDown)")
                            self.perform(#selector(BreathTimerView.doBreathAnimation), with: nil, afterDelay: currentBreatheParameter.breathTimeDown)
            })
        }
    }
    
    internal func breatheInView(_ view: UIView) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveEaseOut],
                       animations: {
                        view.alpha = 1
                        view.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                        
        },
                       completion: { finished in
                        view.removeFromSuperview()
        })
    }
}
