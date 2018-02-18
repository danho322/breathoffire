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
    case who = 1
    case how = 2
    case why = 3
    case more = 4
    
    //https://www.doyouyoga.com/10-ways-breath-of-fire-can-take-you-higher/
    
    func title() -> String {
        switch self {
        case .what:
            return "What is Breath of Fire?"
        case .who:
            return "Denny Prokopos"
        case .how:
            return "How to do BOF"
        case .why:
            return "Benefits"
        case .more:
            return "More"
        }
    }
    
    func ctaTitle() -> String? {
        switch self {
        case .more:
            return "Contact us"
        default:
            return nil
        }
    }
    
    func videoUrl() -> URL? {
        return nil
        
        switch self {
        case .what:
            return Bundle.main.url(forResource: "What", withExtension: "m4v")
        case .who:
            return nil
        case .how:
            return Bundle.main.url(forResource: "How", withExtension: "m4v")
        case .why:
            return Bundle.main.url(forResource: "Why", withExtension: "m4v")
        case .more:
            return nil
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
            return "Breath of Fire is a rhythmic breath with equal emphasis on the inhale and exhale, no deeper than sniffing. It’s done by pumping the naval point towards the spine on the exhale and releasing the naval out on the inhale. It’s practiced through the nostrils with mouth and eyes closes. When done correctly, you should feel you can go indefinitely. If done correctly, benefits include focus, energy, calmness, and peace of mind."
        case .who:
            return "Denny Prokopos was born in San Francisco around 1988. He was interested in Pro Wrestling as a child, and it was looking for Pro Wrestling tapes at a video store that he found out about the UFC. He bought a few tapes of the fighting organization’s first tournaments at the store and as he saw the footage he was amazed by Royce Gracie’s prowess inside the cage. He was so fascinated by the Gracie Jiu Jitsu style that he managed to convince his parents to let him train Jiu Jitsu (who vehemently opposed to it in the beginning). He was 12 years old when he started and his first coach was Charles Gracie.\n\nAs Denny got more involved with Jiu Jitsu, he started preferring the Nogi aspect of the game; this was when he sought out Eddie Bravo for private classes in Nogi. Eddie at the time had already made a name for himself in the Nogi community and was a great believer of the benefits of training without the kimono. Denny ended up leaving his previous instructor and turning his full attention to Eddie Bravo’s way of thought and method, he was around 16 at the time.\n\nIn highschool Denny Prokopos also added wrestling to his resume, competing all throughout secondary School with the exception of the last year due to a bad injury that prevented him from training. He ended up quitting the academic life to focus solely on Jiu Jitsu training and competition, that hard work and dedication paid off with several important victories at a national and international stage, culminating with his black belt award in 2009. In that same year he was part of the American National Team at the FILA Grappling Championship, being coached by Ricardo Liborio in preparation for the tournament (a competition he won), he has also worked extensively with Jake Shields."
        case .how:
            return "Sitting up tall, with a straight spine, hands placed on knees in open palm mudra and your eyes closed, start by feeling your belly expand with each inhale and contract with each exhale.\n\nBreath of Fire is powered from the navel point (solar plexus) and the diaphragm is used to pump the navel in and out with each exhale and inhale, respectively\n\nNow that you understand the movements of the diaphragm during breathing, open the mouth and pant like a dog through to understand the diaphragm pattern. Once you have a rhythm, close your mouth and breathe through your nostrils. Now you are doing it!\n\nQuicken the pace of the inhale and exhale, but keep them equal. There is a quick inhale and quick exhale with no pause between them at the rate of approximately 2-3 cycles per second.\n\nBegin practicing for 1-3 minutes at a time. When done correctly, your chest will remain relaxed and slightly lifted and your hands, feet, face and abdomen will also be relaxed."
        case .why:
            return "5-15 minutes will purify your blood and release deposits from the lungs. Breathe deeply because you know who HATES oxygen? Cancer cells!\n\nBOF is a breath that burns away disease and karma. Goodbye bad health and hello clarity of spirit and soul.\n\nIt stimulates the solar plexus to generate heat and release natural energy throughout the body. Who needs coffee as a mid-day pick me up? I’ll take BOF and it’s FREE!\n\nIt strengthens the magnetic field of the body, aka physical aura, to give you greater protection against negative forces. No more absorbing the negative imprints others throw your way. You act from your inner power.\n\nHelps you quickly regain control in a stressful situation by getting you out of your ego and reconnecting to your higher self. Another stress relief tool? How can one ever have enough!\n\nSynchronizes your entire system under one rhythm, thus promoting greater internal harmony and health. AKA you get your mind, body and spirit in sync.\n\nCan help overcome addictions and cleanse you of the bad effects of smoking, drugs, sugar, alcohol and caffeine. Start substituting feelings of cravings with Breath of Fire and start unblocking negative habits.\n\nWhen done powerfully, the pulsating of the diaphragm massages the internal organs, thus improving the digestive system! It’s a natural Metamucil!\n\nIncreases physical endurance when needed in exercise situations. Use in conjunction with exercise and you will be a whole package athlete.\n\nStrengthens and balances your nervous system. In this stressful world, calm nerves are a must!"
        case .more:
            return "Have feedback, comments, suggestions, or complaints? Please let us know!"
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
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["dan@arxapps.com"])
        composeVC.setSubject("Breathe of Fire feedback")
        composeVC.setMessageBody("", isHTML: false)
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
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
}

extension InfoViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult, error: Error?) {
        // Check the result or perform other tasks.
        
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}
