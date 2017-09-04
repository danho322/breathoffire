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
    
    var walkthroughVC: BWWalkthroughViewController?
    
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
                    
                    let icon = FAKIonIcons.informationCircledIcon(withSize: 25).image(with: CGSize(width: 25, height: 25))
                    tabPageController.navigationItem.rightBarButtonItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(onHelpTap))
                    
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

    @objc func onHelpTap() {
//        if let helpVC = self.storyboard?.instantiateViewController(withIdentifier: "HelpViewControllerIdentifier") {
//            navigationController?.pushViewController(helpVC, animated: true)
//            //                optionsVC.titleLabel.text = selectLabel.text
//        }
        
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "walk") as! BWWalkthroughViewController
        let page_zero = stb.instantiateViewController(withIdentifier: "walk0")
        let page_one = stb.instantiateViewController(withIdentifier: "walk1")
        let page_two = stb.instantiateViewController(withIdentifier: "walk2")
        let page_three = stb.instantiateViewController(withIdentifier: "walk3")

        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.add(viewController:page_zero)
        walkthrough.add(viewController:page_one)
        walkthrough.add(viewController:page_two)
        walkthrough.add(viewController:page_three)
        walkthroughVC = walkthrough
        self.present(walkthrough, animated: true, completion: nil)
    }
}

extension MainTabBarController: BWWalkthroughViewControllerDelegate {
    func walkthroughCloseButtonPressed() {
        walkthroughVC?.dismiss(animated: true, completion: nil)
    }
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
        print("now at \(pageNumber)")
        walkthroughVC?.closeButton?.isHidden = pageNumber != 3
    }
}
