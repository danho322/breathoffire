//
//  UIViewProtocols.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/4/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

protocol AnimateInable {
    func animateIn()
    func animateOut()
}

extension AnimateInable where Self: UIView {
    func animateIn() {
        let offset: CGFloat = 50
        alpha = 0
        frame = CGRect(x: frame.origin.x, y: frame.origin.y + offset, width: frame.size.width, height: frame.size.height)
        let alphaAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
            self.alpha = 1
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y - offset, width: self.frame.size.width, height: self.frame.size.height)
        })
        alphaAnimator.startAnimation()
    }
    
    func animateOut() {
        let offset: CGFloat = 50
        alpha = 0
        let alphaAnimator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut, animations: {
            self.alpha = 1
            self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y + offset, width: self.frame.size.width, height: self.frame.size.height)
        })
        
        alphaAnimator.addCompletion({ _ in
            self.removeFromSuperview()
        })
        alphaAnimator.startAnimation()
    }
}
