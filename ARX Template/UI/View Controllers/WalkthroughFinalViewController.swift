//
//  WalkthroughFinalViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 9/12/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class WalkthroughFinalViewController: BWWalkthroughPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTryTap(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let arVC = mainStoryboard.instantiateViewController(withIdentifier: "ARTechniqueIdentifier") as? ARTechniqueViewController {
            // TODO: disable these buttons on first run
            arVC.sequenceToLoad = DataLoader.sharedInstance.sequenceData(sequenceName: "Breath of Fire 1:1")
            arVC.dismissCompletionHandler = { [unowned self] in
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
            }
            self.present(arVC, animated: true, completion: {
                self.dismiss(animated: false, completion: nil)
            })
        }
    }
}
