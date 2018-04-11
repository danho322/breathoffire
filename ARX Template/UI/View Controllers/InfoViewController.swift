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
import MessageUI

enum SegmentIndexType: Int {
    case what = 0
    case how = 1
    case why = 2
    case more = 3
    
    //https://www.doyouyoga.com/10-ways-breath-of-fire-can-take-you-higher/
    
    func title() -> String {
        switch self {
        case .what:
            return "What is Breath of Fire?"
        case .how:
            return "How do I use this app?"
        case .why:
            return "What are the benefits?"
        case .more:
            return "More"
        }
    }
    
    func ctaTitle() -> String? {
        switch self {
        case .how:
            return "Show me how"
        case .more:
            return "Contact us"
        default:
            return nil
        }
    }
    
    func videoUrl() -> URL? {
        return nil
        
//        switch self {
//        case .what:
//            return Bundle.main.url(forResource: "What", withExtension: "m4v")
//        case .how:
//            return Bundle.main.url(forResource: "How", withExtension: "m4v")
//        case .why:
//            return Bundle.main.url(forResource: "Why", withExtension: "m4v")
//        case .more:
//            return nil
//        }
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
            return "One of the names for the main breathing technique is called Breath of Fire. It is used for many different reasons, including meditation, relaxation, recovery, and focus.\n\nBreath of Fire is a rhythmic breath with equal emphasis on the inhale and exhale, no deeper than sniffing. It’s done by pumping the naval point towards the spine on the exhale and releasing the naval out on the inhale. It’s practiced through the nostrils with mouth and eyes closes. When done correctly, you should feel you can go indefinitely. If done correctly, benefits include focus, energy, calmness, and peace of mind.\n\nSitting up tall, with a straight spine, hands placed on knees in open palm mudra and your eyes closed, start by feeling your belly expand with each inhale and contract with each exhale.\n\nBreath of Fire is powered from the navel point (solar plexus) and the diaphragm is used to pump the navel in and out with each exhale and inhale, respectively\n\nNow that you understand the movements of the diaphragm during breathing, open the mouth and pant like a dog through to understand the diaphragm pattern. Once you have a rhythm, close your mouth and breathe through your nostrils. Now you are doing it!\n\nQuicken the pace of the inhale and exhale, but keep them equal. There is a quick inhale and quick exhale with no pause between them at the rate of approximately 2-3 cycles per second.\n\nBegin practicing for 1-3 minutes at a time. When done correctly, your chest will remain relaxed and slightly lifted and your hands, feet, face and abdomen will also be relaxed."
        case .how:
            return "Through using this app, you will be able to place a virtual Teacher who will guide you through the program using your phone's camera. \n\nThere are three modes of breathing: focused breathing session, open breathing session, and yoga flow breathing session."
        case .why:
            return "5-15 minutes will purify your blood and release deposits from the lungs. Breathe deeply because you know who HATES oxygen? Cancer cells!\n\nBOF is a breath that burns away disease and karma. Goodbye bad health and hello clarity of spirit and soul.\n\nIt stimulates the solar plexus to generate heat and release natural energy throughout the body. Who needs coffee as a mid-day pick me up? I’ll take BOF and it’s FREE!\n\nIt strengthens the magnetic field of the body, aka physical aura, to give you greater protection against negative forces. No more absorbing the negative imprints others throw your way. You act from your inner power.\n\nHelps you quickly regain control in a stressful situation by getting you out of your ego and reconnecting to your higher self. Another stress relief tool? How can one ever have enough!\n\nSynchronizes your entire system under one rhythm, thus promoting greater internal harmony and health. AKA you get your mind, body and spirit in sync.\n\nCan help overcome addictions and cleanse you of the bad effects of smoking, drugs, sugar, alcohol and caffeine. Start substituting feelings of cravings with Breath of Fire and start unblocking negative habits.\n\nWhen done powerfully, the pulsating of the diaphragm massages the internal organs, thus improving the digestive system! It’s a natural Metamucil!\n\nIncreases physical endurance when needed in exercise situations. Use in conjunction with exercise and you will be a whole package athlete.\n\nStrengthens and balances your nervous system. In this stressful world, calm nerves are a must!"
        case .more:
            return "This breathing program is put together and taught by Denny Prokopos, 10th Planet jiujitsu black belt and multiple time world champion.\n\nHe has used these breathing techniques to prepare and compete at the highest level, as well as taught it to other high level competitors in jiujitsu and MMA. Most importantly, he teaches these techniques to his everyday students in San Francisco.\n\nHave feedback, comments, suggestions, or complaints? Please let us know!"
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
    @IBOutlet weak var ctaButton: UIButton!
    var walkthroughVC: BWWalkthroughViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let playIcon = FAKMaterialIcons.playCircleIcon(withSize: 50)
        playIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        playButton.setAttributedTitle(playIcon?.attributedString(), for: .normal)
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.focusColor())
        closeButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
        
        ctaButton.backgroundColor = UIColor.clear
        ctaButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(14)
//        ctaButton.setTitle("", for: .normal)
        ctaButton.setTitleColor(ThemeManager.sharedInstance.focusColor(), for: .normal)
        
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
    
    @IBAction func onButtonTap(_ sender: Any) {
        if let type = SegmentIndexType(rawValue: segmentedControl.selectedSegmentIndex) {
            switch type {
            case .how:
                displayWalkthrough()
            case .more:
                let composeVC = MFMailComposeViewController()
                composeVC.mailComposeDelegate = self
                
                // Configure the fields of the interface.
                composeVC.setToRecipients(["dan@arxapps.com"])
                composeVC.setSubject("Breathe of Fire feedback")
                composeVC.setMessageBody("", isHTML: false)
                
                // Present the view controller modally.
                self.present(composeVC, animated: true, completion: nil)
            default:
                break
            }
        }
    }
    
    internal func handleSegmentType(segmentIndexType: SegmentIndexType) {
        titleLabel.text = segmentIndexType.title()
        imageView.image = segmentIndexType.image()
        descriptionLabel.text = segmentIndexType.description()
        playButton.isHidden = segmentIndexType.videoUrl() == nil
        let ctaTitle = segmentIndexType.ctaTitle()
        ctaButton.isHidden = ctaTitle == nil
        ctaButton.setTitle(ctaTitle, for: .normal)
    }
    
    func displayWalkthrough() {
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "walk") as! BWWalkthroughViewController
        let page_zero = stb.instantiateViewController(withIdentifier: "walk0")
        let page_one = stb.instantiateViewController(withIdentifier: "walk1")
        let page_two = stb.instantiateViewController(withIdentifier: "walk2")
        let page_three = stb.instantiateViewController(withIdentifier: "arwalk0")
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.add(viewController:page_zero)
        walkthrough.add(viewController:page_one)
        walkthrough.add(viewController:page_two)
        walkthrough.add(viewController:page_three)
        walkthroughVC = walkthrough
        present(walkthrough, animated: true, completion: nil)
    }
}

extension InfoViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}

extension InfoViewController: BWWalkthroughViewControllerDelegate {
    func walkthroughCloseButtonPressed() {
        SessionManager.sharedInstance.onTutorialShow(type: .Walkthrough)
        
        walkthroughVC?.dismiss(animated: true, completion: nil)
    }
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
        print("now at \(pageNumber)")
        walkthroughVC?.closeButton?.isHidden = pageNumber != 3
    }
}

