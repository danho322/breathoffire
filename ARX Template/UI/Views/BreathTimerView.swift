//
//  BreathTimerView.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/8/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class BreathTimerView: XibView {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var fireContainerImageView: UIImageView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    
    internal let circlePathLayer = CAShapeLayer()
    internal let circleRadius: CGFloat = 110
    var isRunning = false
    internal var currentBreathParameter: BreathParameter?
    
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
        circlePathLayer.strokeColor = UIColor.orange.cgColor
        view.layer.addSublayer(circlePathLayer)
        
        progress = 0
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let view = view as? BreathTimerView else {
            return
        }
        
        circlePathLayer.frame = CGRect(x: view.fireContainerImageView.frame.origin.x, y: view.fireContainerImageView.frame.origin.y, width: view.fireContainerImageView.frame.size.width, height: view.fireContainerImageView.frame.size.height)
        circlePathLayer.path = circlePath().cgPath
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

    func update(timestamp: TimeInterval, nextParameterTimestamp: TimeInterval, breathParameter: BreathParameter?) {
        guard let view = view as? BreathTimerView else {
            fatalError("view is not of type BreathTimerView")
        }
        print("update \(timestamp) \(nextParameterTimestamp) \(breathParameter?.startTime)")
        view.timeLabel.text = BreathTimerService.timeString(time: timestamp)
       
        if let currentBreathParameter = currentBreathParameter,
            let breathParameter = breathParameter {
           
            var length = nextParameterTimestamp
            length -= breathParameter.startTime
            
            print("\(timestamp) - \(currentBreathParameter.startTime) / \(length)")
            progress = CGFloat(timestamp - currentBreathParameter.startTime) / CGFloat(length)
            if breathParameter == currentBreathParameter {
                return
            }
            
            progress = timestamp > 0 ? 1 : 0
        }
        // update the animations here
        currentBreathParameter = breathParameter
        isRunning = currentBreathParameter != nil
        doBreathAnimation()
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
    
    @IBAction func onPauseTap(_ sender: Any) {
    }
    
    @IBAction func onEndTap(_ sender: Any) {
    }
    
    // MARK: - Animations
    
    @objc internal func doBreathAnimation() {
        guard let view = view as? BreathTimerView else {
            fatalError("view is not of type BreathTimerView")
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(BreathTimerView.doBreathAnimation), object: nil)
        print("do breath")
        if let currentBreatheParameter = currentBreathParameter, isRunning {
            let fireView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.fireContainerImageView.frame.size.width, height: view.fireContainerImageView.frame.size.height))
            fireView.center = view.fireContainerImageView.center
            fireView.image = UIImage(named: "FireEmoji")
            fireView.backgroundColor = UIColor.clear
            fireView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            view.addSubview(fireView)
            UIView.animate(withDuration: currentBreatheParameter.breathTimeUp,
                           delay: 0,
                           options: [.curveLinear],
                           animations: {
                            fireView.transform = CGAffineTransform.identity
                
            },
                           completion: { finished in
                            self.fadeOutView(fireView)
                            self.perform(#selector(BreathTimerView.doBreathAnimation), with: nil, afterDelay: currentBreatheParameter.breathTimeDown)
            })
        }
    }
    
    internal func fadeOutView(_ view: UIView) {
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       options: [.curveLinear],
                       animations: {
                        view.alpha = 0
                        view.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
                        
        },
                       completion: { finished in
                        view.removeFromSuperview()
        })
    }
}
