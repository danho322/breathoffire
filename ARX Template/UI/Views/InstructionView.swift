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
    static let VerticalSpace: CGFloat = 90
    static let AlphaSubtraction: CGFloat = 0.3
    static let MaxInstructions = 3
    static let InsetPadding: CGFloat = 30
    static let FadeInterval: TimeInterval = 3
}

class InstructionView: UIView {
    internal var instructionViews: [UIView] = []
    
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }
    
    func addInstruction(text: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        let width = frame.size.width - InstructionViewConstants.InsetPadding * 2
        let newLabel = UILabel(frame: CGRect(x: 10, y: 10, width: width - 20, height: 0))
        newLabel.backgroundColor = .clear
        newLabel.textColor = .white
        newLabel.numberOfLines = 0
        newLabel.lineBreakMode = .byWordWrapping
        newLabel.text = text
        let constrainedSize = CGSize(width: newLabel.frame.size.width, height: CGFloat.greatestFiniteMagnitude)
        let boundingRect = text.boundingRect(with: constrainedSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedStringKey.font: newLabel.font], context: nil)
        newLabel.frame = CGRect(x: newLabel.frame.origin.x, y: newLabel.frame.origin.y, width: newLabel.frame.size.width, height: boundingRect.size.height)
        let toFrame = CGRect(x: InstructionViewConstants.InsetPadding, y: frame.size.height - boundingRect.size.height - InstructionViewConstants.VerticalSpace, width: boundingRect.size.width, height: boundingRect.size.height)
        
        let fromFrame = CGRect(x: InstructionViewConstants.InsetPadding, y: frame.size.height, width: toFrame.size.width + 20, height: 0)
        let bgFrame = CGRect(x: toFrame.origin.x, y: toFrame.origin.y, width: toFrame.size.width + 20, height: toFrame.size.height + 20)
        let bgColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        let bgView = UIView(frame: fromFrame)
        bgView.backgroundColor = bgColor
        bgView.layer.cornerRadius = 5
        bgView.layer.masksToBounds = true
        bgView.alpha = 0
        bgView.addSubview(newLabel)

        addSubview(bgView)
        
        UIView.animate(withDuration: InstructionViewConstants.AnimationDuration,
                       animations: {
                        bgView.frame = bgFrame
                        bgView.alpha = 1
        },
                       completion: { finished in
        })
        
        instructionViews.insert(bgView, at: 0)
        var delay: TimeInterval = 0
        var prevLabel: UIView?
        var i = 0
        for label in instructionViews {
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
        if index < instructionViews.count {
            let label = instructionViews[index]
            self.instructionViews.remove(at: index)
            removeLabel(label: label, completion: {
                
            })
        }
    }
    
    internal func removeLabel(label: UIView, completion: @escaping ()->Void) {
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
        if instructionViews.count > 0 {
            removeLabelAt(index: instructionViews.count - 1)
            self.perform(#selector(removeLast), with: nil, afterDelay: InstructionViewConstants.FadeInterval)
        }
    }
    
    func removeAllLabels() {
        for label in instructionViews {
            UIView.animate(withDuration: InstructionViewConstants.AnimationDuration,
                           animations: {
                            label.alpha = 0
                            },
                           completion: { finished in
                            label.removeFromSuperview()
            })
        }
        instructionViews.removeAll()
    }
}
