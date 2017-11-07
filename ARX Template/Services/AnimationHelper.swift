//
//  AnimationHelper.swift
//  ARX Template
//
//  Created by Daniel Ho on 11/6/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import Foundation
import SceneKit

class AnimationHelper {
    static let sharedInstance = AnimationHelper()
    
    internal var loadedAnimations: [String: CAAnimation] = Dictionary<String, CAAnimation>()
    
    func animationWithSceneNamed(_ name: String) -> CAAnimation? {
        if let animation = loadedAnimations[name] {
            return animation
        }
        
        if let animation = CAAnimation.animationWithSceneNamed(name) {
            loadedAnimations[name] = animation
            return animation
        }
        
        return nil
    }
    
    
}
