//
//  XibView.swift
//  ARX Template
//
//  Created by Daniel Ho on 6/23/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class XibView: UIView {

    var view: XibView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // This prevents the infinite loop
        if (self.subviews.count == 0) {
            xibSetup()
        }
    }
    
    func xibSetup() {
        view = UIView.fromNib("\(type(of: self))") as! XibView
        view.clipsToBounds = true
        
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        addSubview(view)
        
        setupUI()
    }
    
    func setupUI() {
        // override me
    }
}
