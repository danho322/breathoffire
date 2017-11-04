//
//  MainTabBarController.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/19/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import ESTabBarController
import FontAwesomeKit
import Instructions

class ExampleIrregularityContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        self.imageView.layer.borderWidth = 3.0
        self.imageView.layer.borderColor = UIColor.init(white: 235 / 255.0, alpha: 1.0).cgColor
        self.imageView.layer.cornerRadius = 35
        self.insets = UIEdgeInsetsMake(-20, 0, 0, 0)
        let transform = CGAffineTransform.identity
        self.imageView.transform = transform
        self.superview?.bringSubview(toFront: self)
        
        textColor = UIColor.clear
        highlightTextColor = UIColor.clear
        iconColor = ThemeManager.sharedInstance.focusForegroundColor()
        highlightIconColor = ThemeManager.sharedInstance.focusColor()

        backdropColor = UIColor.clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ExampleBasicContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = ThemeManager.sharedInstance.backgroundColor()
        highlightTextColor = ThemeManager.sharedInstance.focusColor()
        iconColor = ThemeManager.sharedInstance.backgroundColor()
        highlightIconColor = ThemeManager.sharedInstance.focusColor()
        backdropColor = UIColor.clear
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

enum WalthroughInstructionType: Int {
    case infoButton = 0
    case feedTab = 1
    case breathTab = 2
    case userTab = 3
    case count = 4
    
    func view(vc: MainTabBarController) -> UIView? {
        if let navVC = vc.viewControllers?[0] as? ARXNavigationController {
            let tabVC = navVC.viewControllers[0]
            switch self {
            case .infoButton:
                var infoButton: UIView?
                for subview in navVC.navigationBar.subviews {
                    for subsubview in subview.subviews {
                        if subsubview.isUserInteractionEnabled {
                            infoButton = subsubview
                        }
                    }
                }
                return infoButton
            case .feedTab:
                return vc.viewForTabAtIndex(tabBar: tabVC.tabBarController?.tabBar, index: 0)
            case .breathTab:
                return vc.viewForTabAtIndex(tabBar: tabVC.tabBarController?.tabBar, index: 1)
            case .userTab:
                return vc.viewForTabAtIndex(tabBar: tabVC.tabBarController?.tabBar, index: 2)
            default:
                return nil
            }
        }
        return nil
    }
    
    func hintText() -> String {
        switch self {
        case .infoButton:
            return "Learn more about this app here"
        case .feedTab:
            return "See how people are breathing around the world"
        case .breathTab:
            return "Start your exercise here"
        case .userTab:
            return "Track your statistics"
        default:
            return ""
        }
    }
}

class MainTabBarController: ESTabBarController {
    
    var walkthroughVC: BWWalkthroughViewController?
    let coachMarksController = CoachMarksController()

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        
        hidesBottomBarWhenPushed = true
        
//        tabBar.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        let transparentImage = UIImage(named: "transparent")
        tabBar.shadowImage = transparentImage
        let darkImage = UIImage(named: "background_dark")
        tabBar.backgroundImage = darkImage
        
        coachMarksController.dataSource = self
        coachMarksController.delegate = self
        coachMarksController.overlay.color = ThemeManager.sharedInstance.backgroundColor(alpha: 0.8)

        // Replace viewcontrollers set up in storyboard
        var newViewControllers: [UIViewController] = []
        if let viewControllers = viewControllers {
            for viewController in viewControllers {
                if viewController is CommunityViewController {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let communityVC = storyboard.instantiateViewController(withIdentifier: "FeedViewControllerIdentifier")
                    
                    let navigationController = ARXNavigationController(rootViewController: communityVC)
                    communityVC.title = "Breath of Fire"
                    navigationController.delegate = self
                    
                    let icon = FAKIonIcons.informationCircledIcon(withSize: 25).image(with: CGSize(width: 25, height: 25))
                    communityVC.navigationItem.rightBarButtonItem = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(onHelpTap))
                    
                    
                    let tabIcon = FAKIonIcons.iosWorldIcon(withSize: 25).image(with: CGSize(width: 25, height: 25))
                    navigationController.tabBarItem = ESTabBarItem.init(ExampleBasicContentView(), title: "Breath of Fire", image: tabIcon, selectedImage: tabIcon)
                    
                    newViewControllers.append(navigationController)
                } else {
                    if let viewController = viewController as? UINavigationController {
                        viewController.delegate = self
                    }
                    
                    if let tabTitle = viewController.tabBarItem.title {
                        if tabTitle == "Breathe" {
                            let icon = FAKIonIcons.flameIcon(withSize: 70)
                            let flameImage = icon?.image(with: CGSize(width: 70, height: 70))
                            viewController.tabBarItem = ESTabBarItem.init(ExampleIrregularityContentView(), title: "", image: flameImage, selectedImage: flameImage)
                        } else if tabTitle == "Profile" {
                            let icon = FAKIonIcons.iosPersonIcon(withSize: 25)
                            let userImage = icon?.image(with: CGSize(width: 25, height: 25))
                            viewController.tabBarItem = ESTabBarItem.init(ExampleBasicContentView(), title: "Profile", image: userImage, selectedImage: userImage)
                            
                        }
                    }
                    
                    
                    newViewControllers.append(viewController)
                }
            }
        }
        
        self.viewControllers = newViewControllers
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            [weak self] in
            if SessionManager.sharedInstance.shouldShowTutorial(type: .Walkthrough) {
                self?.displayWalkthrough()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // note: viewDidLoad is called twice for some reason, not sure if there are two instances of it
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.coachMarksController.stop(immediately: true)
        SessionManager.sharedInstance.onTutorialShow(type: .Walkthrough)
    }
    
    func displayWalkthrough() {
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
        present(walkthrough, animated: true, completion: nil)
    }

    @objc func onHelpTap() {
        if let helpVC = storyboard?.instantiateViewController(withIdentifier: "InfoViewIdentifier") {
            present(helpVC, animated: true, completion: nil)
            //                optionsVC.titleLabel.text = selectLabel.text
        }
    }
    
    func viewForTabAtIndex(tabBar: UIView?, index: Int) -> UIView? {
        var i = 0
        if let tabBar = tabBar {
            for view in tabBar.subviews {
                if view.isUserInteractionEnabled {
                    if i == index {
                        if let imageView = view.subviews.filter({$0 is UIImageView}).first {
                            return imageView
                        }
                        return view
                    }
                    i += 1
                }
            }
        }
        return nil
    }
}

extension MainTabBarController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let isFirst =  navigationController.viewControllers.index(of: viewController) == 0
        tabBar.isHidden = !isFirst
    }
}

extension MainTabBarController: BWWalkthroughViewControllerDelegate {
    func walkthroughCloseButtonPressed() {
        walkthroughVC?.dismiss(animated: true, completion: nil)
        
        coachMarksController.start(on: self)
    }
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
        print("now at \(pageNumber)")
        walkthroughVC?.closeButton?.isHidden = pageNumber != 3
    }
}



extension MainTabBarController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return WalthroughInstructionType.count.rawValue
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController,
                              coachMarkAt index: Int) -> CoachMark {
        return coachMarksController.helper.makeCoachMark(for: WalthroughInstructionType(rawValue: index)?.view(vc: self))
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: CoachMarkBodyView, arrowView: CoachMarkArrowView?) {
        let coachViews = coachMarksController.helper.makeDefaultCoachViews(withArrow: true, arrowOrientation: coachMark.arrowOrientation)
        
        let hintText = WalthroughInstructionType(rawValue: index)?.hintText()
        coachViews.bodyView.hintLabel.text = hintText
        coachViews.bodyView.nextLabel.text = "Ok"
        
        return (bodyView: coachViews.bodyView, arrowView: coachViews.arrowView)
    }
}
