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
        self.startARTechnique(sequenceContainer: DataLoader.sharedInstance.moveOfTheDay(),
                              liveSessionInfo: LiveSessionInfo(type: .create, liveSession: nil, intention: "My first session"))
    }
    
    func startARTechnique(sequenceContainer: AnimationSequenceDataContainer?, liveSessionInfo: LiveSessionInfo? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let arVC = storyboard.instantiateViewController(withIdentifier: "ARTechniqueIdentifier") as? ARTechniqueViewController,
            let sequenceContainer = sequenceContainer {
            arVC.sequenceToLoad = sequenceContainer
            if let liveSessionInfo = liveSessionInfo {
                arVC.liveSessionInfo = liveSessionInfo
            }
            arVC.dismissCompletionHandler = {
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
            }
            
            if let presentingVC = self.presentingViewController {
                self.dismiss(animated: true, completion: {
                    presentingVC.present(arVC, animated: true, completion: nil)
                })
            }
        }
    }
}
