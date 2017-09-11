//
//  InfoViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 9/4/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit
import AVKit
import AVFoundation

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
    
    func videoUrl() -> URL? {
        switch self {
        case .what:
            return Bundle.main.url(forResource: "What", withExtension: "m4v")
        case .who:
            return nil
        case .how:
            return Bundle.main.url(forResource: "How", withExtension: "m4v")
        case .why:
            return Bundle.main.url(forResource: "Why", withExtension: "m4v")
        }
    }
    
    func image() -> UIImage? {
        if let videoUrl = videoUrl() {
            return ARXUtilities.createThumbnailOfVideoFromFileURL(videoUrl)
        }
        return nil
    }
    
    func description() -> String {
        switch self {
        case .what:
            return "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin mi urna, volutpat ac ullamcorper tincidunt, vestibulum eget elit. Maecenas faucibus hendrerit metus sed dignissim. Aliquam iaculis purus eget sapien scelerisque gravida. Mauris quis nulla a quam egestas cursus tincidunt nec turpis. Duis nunc purus, scelerisque non mattis in, eleifend fermentum augue. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nullam ultricies ultricies erat, a porta eros congue a. Donec gravida nisi massa, ullamcorper aliquam ex vehicula nec. Morbi molestie nulla non elit semper tincidunt. Etiam vel ligula sollicitudin, pellentesque ante vitae, ultrices tellus. Duis tempus laoreet velit vel condimentum. Integer ut magna at sem egestas tempor. Nam aliquet nibh in velit varius volutpat. Curabitur interdum accumsan metus, at gravida tellus lobortis sed. Donec molestie aliquet auctor.\n\nUt eget sagittis lorem. Phasellus dictum pellentesque placerat. Vestibulum ultricies lacus sed justo convallis dapibus. Nam lobortis, quam a efficitur luctus, odio massa facilisis turpis, a dapibus enim mauris nec nibh. Cras vulputate, justo sed scelerisque commodo, diam urna rutrum arcu, a blandit nulla neque et ex. Donec ac ipsum pharetra, molestie dolor eget, molestie felis. Aliquam eu laoreet erat, eu varius eros. Quisque elit urna, vehicula eu pulvinar id, malesuada ut nibh. Nam commodo placerat dolor, et tempor metus vehicula ut. Ut sapien dolor, porttitor eget diam ac, condimentum rutrum sem. Quisque pretium risus ex. Cras aliquet venenatis libero non fermentum. Sed ut tortor eleifend, iaculis odio vel, consequat odio. Proin eget turpis sem."
        case .who:
            return "Denny Prokopos was born in San Francisco around 1988. He was interested in Pro Wrestling as a child, and it was looking for Pro Wrestling tapes at a video store that he found out about the UFC. He bought a few tapes of the fighting organization’s first tournaments at the store and as he saw the footage he was amazed by Royce Gracie’s prowess inside the cage. He was so fascinated by the Gracie Jiu Jitsu style that he managed to convince his parents to let him train Jiu Jitsu (who vehemently opposed to it in the beginning). He was 12 years old when he started and his first coach was Charles Gracie.\n\nAs Denny got more involved with Jiu Jitsu, he started preferring the Nogi aspect of the game; this was when he sought out Eddie Bravo for private classes in Nogi. Eddie at the time had already made a name for himself in the Nogi community and was a great believer of the benefits of training without the kimono. Denny ended up leaving his previous instructor and turning his full attention to Eddie Bravo’s way of thought and method, he was around 16 at the time.\n\nIn highschool Denny Prokopos also added wrestling to his resume, competing all throughout secondary School with the exception of the last year due to a bad injury that prevented him from training. He ended up quitting the academic life to focus solely on Jiu Jitsu training and competition, that hard work and dedication paid off with several important victories at a national and international stage, culminating with his black belt award in 2009. In that same year he was part of the American National Team at the FILA Grappling Championship, being coached by Ricardo Liborio in preparation for the tournament (a competition he won), he has also worked extensively with Jake Shields."
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
        let playIcon = FAKMaterialIcons.playCircleIcon(withSize: 50)
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
        if let segmentIndexType = SegmentIndexType(rawValue: segmentedControl.selectedSegmentIndex),
            let url = segmentIndexType.videoUrl() {
            let player = AVPlayer(url: url)
            let playerController = AVPlayerViewController()
            playerController.player = player
            present(playerController, animated: true) {
                player.play()
            }
        }
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
        playButton.isHidden = segmentIndexType.videoUrl() == nil
    }
}
