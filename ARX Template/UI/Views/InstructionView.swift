//
//  InstructionView.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/26/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

struct InstructionViewConstants {
    static let AnimationDuration: TimeInterval = 0.3
    static let FadeDuration: TimeInterval = 1
    static let VerticalSpace: CGFloat = 50
    static let AlphaSubtraction: CGFloat = 0.3
    static let MaxInstructions = 3
    static let InsetPadding: CGFloat = 30
    static let FadeInterval: TimeInterval = 3
}

class InstructionView: UIView {
    internal var instructionLabels: [UILabel] = []
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    func addInstruction(text: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        let width = frame.size.width - InstructionViewConstants.InsetPadding * 2
        let newLabel = UILabel(frame: CGRect(x: InstructionViewConstants.InsetPadding, y: frame.size.height, width: width, height: 0))
        newLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        newLabel.textColor = UIColor.white
        newLabel.numberOfLines = 0
        newLabel.lineBreakMode = .byWordWrapping
        newLabel.layer.cornerRadius = 5
        newLabel.layer.masksToBounds = true
        newLabel.text = text
        newLabel.alpha = 0
        let constrainedSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = text.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: newLabel.font], context: nil)
        let toFrame = CGRect(x: InstructionViewConstants.InsetPadding, y: frame.size.height - boundingRect.size.height - InstructionViewConstants.VerticalSpace, width: constrainedSize.width, height: boundingRect.size.height)
        addSubview(newLabel)
        
        UIView.animate(withDuration: InstructionViewConstants.AnimationDuration,
                       animations: {
                        newLabel.frame = toFrame
                        newLabel.alpha = 1
        },
                       completion: { finished in
        })
        
        instructionLabels.insert(newLabel, at: 0)
        var delay: TimeInterval = 0
        var prevLabel: UILabel?
        var i = 0
        for label in instructionLabels {
            if let prevLabel = prevLabel {
                UIView.animate(withDuration: InstructionViewConstants.AnimationDuration,
                               delay: delay,
                               options: [.curveEaseInOut],
                               animations: {
                                label.frame = CGRect(x: label.frame.origin.x,
                                                     y: prevLabel.frame.origin.y - InstructionViewConstants.VerticalSpace - label.frame.size.height,
                                                     width: label.frame.size.width,
                                                     height: label.frame.size.height)
                                label.alpha = label.alpha - InstructionViewConstants.AlphaSubtraction
                },
                               completion: { finished in
                                if i >= InstructionViewConstants.MaxInstructions {
                                    self.removeLast()
                                }
                })
            }
            delay += 0.02
            prevLabel = label
            i += 1
        }
        
        self.perform(#selector(removeLast), with: nil, afterDelay: InstructionViewConstants.FadeInterval)
    }
    
    internal func removeLabelAt(index: Int) {
        if index < instructionLabels.count {
            let label = instructionLabels[index]
            self.instructionLabels.remove(at: index)
            removeLabel(label: label, completion: {
                
            })
        }
    }
    
    internal func removeLabel(label: UILabel, completion: @escaping ()->Void) {
        UIView.animate(withDuration: InstructionViewConstants.FadeDuration,
                       animations: {
                        label.alpha = 0
        },
                       completion: { finished in
                        label.removeFromSuperview()
                        completion()
        })
    }
    
    @objc internal func removeLast() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        if instructionLabels.count > 0 {
            removeLabelAt(index: instructionLabels.count - 1)
            self.perform(#selector(removeLast), with: nil, afterDelay: InstructionViewConstants.FadeInterval)
        }
    }
    
    func removeAllLabels() {
        for label in instructionLabels {
            UIView.animate(withDuration: InstructionViewConstants.AnimationDuration,
                           animations: {
                            label.alpha = 0
                            },
                           completion: { finished in
                            label.removeFromSuperview()
            })
        }
        instructionLabels.removeAll()
    }
}
