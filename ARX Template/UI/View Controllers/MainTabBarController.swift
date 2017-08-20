//
//  MainTabBarController.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/19/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import TabPageViewController

class MainTabBarController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        // Replace viewcontrollers set up in storyboard
        var newViewControllers: [UIViewController] = []
        if let viewControllers = viewControllers {
            for viewController in viewControllers {
                if viewController is CommunityViewController {
                    var tabItems: [(UIViewController, String)] = []
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let communityVC = storyboard.instantiateViewController(withIdentifier: "FeedViewControllerIdentifier")
                    tabItems.append((communityVC, "Feed"))
                    let rankingsVC = storyboard.instantiateViewController(withIdentifier: "RankingsViewControllerIdentifier")
                    tabItems.append((rankingsVC, "Rankings"))
                    
                    let tabPageController = TabPageViewController.create()
                    tabPageController.title = "Community"
                    tabPageController.tabItems = tabItems
                    tabPageController.option.currentColor = ThemeManager.sharedInstance.backgroundColor()
                    tabPageController.option.tabBackgroundColor = ThemeManager.sharedInstance.backgroundColor()
                    tabPageController.option.defaultColor = ThemeManager.sharedInstance.labelTitleColor()
                    tabPageController.option.currentColor = ThemeManager.sharedInstance.focusForegroundColor()

                    
                    newViewControllers.append(tabPageController)
                } else {
                    newViewControllers.append(viewController)
                }
            }

        }
        self.viewControllers = newViewControllers
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
