//
//  MainTabBarController.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/19/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import TabPageViewController
import FontAwesomeKit

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

                    
                    let navigationController = ARXNavigationController(rootViewController: tabPageController)
                    tabPageController.title = "Breath of Fire"
                    
                    newViewControllers.append(navigationController)
                } else {
                    newViewControllers.append(viewController)
                }
            }
        }
        self.viewControllers = newViewControllers
        
        if let tabItems = tabBar.items {
            for tabItem in tabItems {
                print(tabItem)
                if tabItem.title == "Breath of Fire" {
//                    tabItem.title = nil
                    let icon = FAKIonIcons.iosWorldIcon(withSize: 25).image(with: CGSize(width: 25, height: 25))
                    tabItem.image = icon
                } else if tabItem.title == "Breathe" {
//                    tabItem.title = nil
                    let icon = FAKIonIcons.flameIcon(withSize: 25).image(with: CGSize(width: 25, height: 25))
                    tabItem.image = icon
                } else if tabItem.title == "Profile" {
//                    tabItem.title = nil
                    let icon = FAKIonIcons.iosPersonIcon(withSize: 25).image(with: CGSize(width: 25, height: 25))
                    tabItem.image = icon
                }
            }
        }
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
