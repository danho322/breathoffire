//
//  InfoViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 9/4/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit

enum SegmentIndexType: Int {
    case what = 0
    case who = 1
    case how = 2
    case why = 3
    
    func title() -> String {
        switch self {
        case .what:
            return "Breath of Fire"
        case .who:
            return "Denny Prokopos"
        case .how:
            return "How to use this app"
        case .why:
            return "Benefits"
        }
    }
    
    func image() -> UIImage? {
        switch self {
        case .what:
            let icon = FAKFontAwesome.whatsappIcon(withSize: 50)
            icon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.focusForegroundColor())
            return icon?.image(with: CGSize(width: 50, height: 50))
        case .who:
            let icon = FAKFontAwesome.userIcon(withSize: 50)
            icon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.focusForegroundColor())
            return icon?.image(with: CGSize(width: 50, height: 50))
        case .how:
            let icon = FAKFontAwesome.shirtsinbulkIcon(withSize: 50)
            icon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.focusForegroundColor())
            return icon?.image(with: CGSize(width: 50, height: 50))
        case .why:
            let icon = FAKFontAwesome.questionCircleIcon(withSize: 50)
            icon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.focusForegroundColor())
            return icon?.image(with: CGSize(width: 50, height: 50))
        }
    }
    
    func description() -> String {
        switch self {
        case .what:
            return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin mi urna, volutpat ac ullamcorper tincidunt, vestibulum eget elit. Maecenas faucibus hendrerit metus sed dignissim. Aliquam iaculis purus eget sapien scelerisque gravida. Mauris quis nulla a quam egestas cursus tincidunt nec turpis. Duis nunc purus, scelerisque non mattis in, eleifend fermentum augue. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nullam ultricies ultricies erat, a porta eros congue a. Donec gravida nisi massa, ullamcorper aliquam ex vehicula nec. Morbi molestie nulla non elit semper tincidunt. Etiam vel ligula sollicitudin, pellentesque ante vitae, ultrices tellus. Duis tempus laoreet velit vel condimentum. Integer ut magna at sem egestas tempor. Nam aliquet nibh in velit varius volutpat. Curabitur interdum accumsan metus, at gravida tellus lobortis sed. Donec molestie aliquet auctor.\n\nUt eget sagittis lorem. Phasellus dictum pellentesque placerat. Vestibulum ultricies lacus sed justo convallis dapibus. Nam lobortis, quam a efficitur luctus, odio massa facilisis turpis, a dapibus enim mauris nec nibh. Cras vulputate, justo sed scelerisque commodo, diam urna rutrum arcu, a blandit nulla neque et ex. Donec ac ipsum pharetra, molestie dolor eget, molestie felis. Aliquam eu laoreet erat, eu varius eros. Quisque elit urna, vehicula eu pulvinar id, malesuada ut nibh. Nam commodo placerat dolor, et tempor metus vehicula ut. Ut sapien dolor, porttitor eget diam ac, condimentum rutrum sem. Quisque pretium risus ex. Cras aliquet venenatis libero non fermentum. Sed ut tortor eleifend, iaculis odio vel, consequat odio. Proin eget turpis sem."
        case .who:
            return "Vestibulum in est ac est congue porta. Nunc eu lacinia augue, sit amet porttitor est. Fusce lobortis lorem eu ipsum iaculis commodo. Suspendisse eu metus fermentum, tempor turpis in, sodales dui. Suspendisse facilisis tortor convallis, aliquam velit id, hendrerit nisi. Sed sed neque id tortor aliquam accumsan. Ut fermentum, ipsum vel hendrerit imperdiet, augue turpis iaculis metus, vestibulum maximus lectus mi in elit. Donec lacinia turpis elit, at varius metus molestie eu. Etiam molestie lectus vel dictum efficitur. In scelerisque molestie purus a varius. Etiam non rutrum sem, ac interdum lectus."
        case .how:
            return "Proin id tortor lacus. Quisque finibus ante a aliquam semper. Duis mi urna, tincidunt non tempus et, consectetur at urna. Morbi consequat risus quam, rhoncus placerat mauris sodales at. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Morbi in orci sagittis, consequat neque eu, auctor eros. Cras sit amet ex sapien. Donec a semper erat. Vestibulum rhoncus arcu et rutrum posuere. Maecenas viverra ipsum urna, in consectetur elit convallis a. In erat odio, interdum ut semper eget, sodales sed augue. Sed tincidunt nec velit ut venenatis."
        case .why:
            return "Aliquam pharetra porta est a faucibus. Integer eget purus tincidunt, imperdiet diam viverra, auctor arcu. Vivamus et tincidunt libero, vel suscipit risus. Pellentesque quis erat nec enim dignissim ultricies. Vivamus ultricies rutrum diam auctor sagittis. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Vivamus ultricies ultricies tellus at varius. Donec quis risus vitae magna varius aliquet ac non eros. Vivamus mattis ultricies erat, et ultrices felis molestie in. Maecenas sit amet viverra ligula, ac hendrerit ligula. Integer blandit tempor risus quis luctus."
        }
    }
}

class InfoViewController: UIViewController {
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let playIcon = FAKMaterialIcons.playCircleIcon(withSize: 25)
        playIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        playButton.setAttributedTitle(playIcon?.attributedString(), for: .normal)
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute("NSForegroundColorAttributeName", value: ThemeManager.sharedInstance.focusForegroundColor())
        closeButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
        
        
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        segmentedControl.tintColor = ThemeManager.sharedInstance.focusColor()
        imageView.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        titleLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        titleLabel.font = ThemeManager.sharedInstance.defaultFont(30)
        descriptionLabel.textColor = ThemeManager.sharedInstance.textColor()
        descriptionLabel.font = ThemeManager.sharedInstance.defaultFont(16)
        
        handleSegmentType(segmentIndexType: .what)
    }

    @IBAction func onPlayTap(_ sender: Any) {
    }
    
    @IBAction func onCloseTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSegmentChanged(_ sender: Any) {
        if let sender = sender as? UISegmentedControl,
            let segmentIndexType = SegmentIndexType(rawValue: sender.selectedSegmentIndex) {
            handleSegmentType(segmentIndexType: segmentIndexType)
        }
    }
    
    internal func handleSegmentType(segmentIndexType: SegmentIndexType) {
        titleLabel.text = segmentIndexType.title()
        imageView.image = segmentIndexType.image()
        descriptionLabel.text = segmentIndexType.description()
    }
}
