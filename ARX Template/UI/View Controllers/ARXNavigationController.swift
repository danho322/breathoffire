//
//  ARXNavigationController.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/20/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class ARXNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedStringKey.font: ThemeManager.sharedInstance.defaultFont(30),
            NSAttributedStringKey.foregroundColor: ThemeManager.sharedInstance.focusForegroundColor()
        ]
        navigationBar.barStyle = .black
        navigationBar.tintColor = ThemeManager.sharedInstance.focusForegroundColor()
//        navigationBa
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
