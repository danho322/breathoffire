//
//  RelatedAnimationsView.swift
//  ARX Template
//
//  Created by Daniel Ho on 7/3/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import FontAwesomeKit

protocol RelatedAnimationsViewDelegate {
    func didTapRelatedAnimation(relatedView: RelatedAnimationsView, sequenceName: String)
    func didTapReplay(relatedView: RelatedAnimationsView)
    func didTapShare(relatedView: RelatedAnimationsView)
    func didTapDismiss(relatedView: RelatedAnimationsView)
}

class RelatedAnimationsView: XibView {

    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    @IBOutlet weak var alertContainerView: UIView!
    @IBOutlet weak var lessonCompleteLabel: UILabel!
    @IBOutlet weak var replayButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playCountLabel: UILabel!
    var delegate: RelatedAnimationsViewDelegate?
    
    var relatedAnimations: [String] = []
    
    override func setupUI() {
        guard let view = view as? RelatedAnimationsView else {
            fatalError("view is not of type RelatedAnimationsView")
        }
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute("NSForegroundColorAttributeName", value: UIColor.white)
        view.dismissButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
        
        view.tableView.register(UINib(nibName: "TechniqueTableCell", bundle: nil), forCellReuseIdentifier: "TechniqueCell")
        view.tableView.dataSource = self
        view.tableView.delegate = self
        
        view.playCountLabel.text = "\(StatManager.sharedIntance.playCountToday())\nPlays\nToday"
    }
    
    func set(delegate: RelatedAnimationsViewDelegate) {
        guard let view = view as? RelatedAnimationsView else {
            fatalError("view is not of type RelatedAnimationsView")
        }
        
        view.delegate = delegate
    }
    
    @IBAction func onReplayTap(_ sender: Any) {
        delegate?.didTapReplay(relatedView: self)
    }
    
    @IBAction func onShareTap(_ sender: Any) {
        delegate?.didTapShare(relatedView: self)
    }
    
    @IBAction func onDismissTap(_ sender: Any) {
        delegate?.didTapDismiss(relatedView: self)
    }
    
    func animateIn() {
        guard let view = view as? RelatedAnimationsView else {
            fatalError("view is not of type RelatedAnimationsView")
        }
        
        let offset: CGFloat = 50
        view.alpha = 0
        view.alertContainerView.frame = CGRect(x: frame.origin.x, y: frame.origin.y + offset, width: frame.size.width, height: frame.size.height)
        let alphaAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            view.alpha = 1
            view.alertContainerView.frame = CGRect(x: view.alertContainerView.frame.origin.x, y: view.alertContainerView.frame.origin.y - offset, width: view.alertContainerView.frame.size.width, height: view.alertContainerView.frame.size.height)
        })
        alphaAnimator.startAnimation()
    }
    
    func animateOut() {
        guard let view = view as? RelatedAnimationsView else {
            fatalError("view is not of type RelatedAnimationsView")
        }
        
        let offset: CGFloat = 50
        view.alpha = 1
        let alphaAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            view.alpha = 0
            view.alertContainerView.frame = CGRect(x: view.alertContainerView.frame.origin.x, y: view.alertContainerView.frame.origin.y + offset, width: view.alertContainerView.frame.size.width, height: view.alertContainerView.frame.size.height)
        })
        
        alphaAnimator.addCompletion({ _ in
            self.removeFromSuperview()
        })
        alphaAnimator.startAnimation()
    }
}

// MARK: - UITableViewDataSource
extension RelatedAnimationsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return relatedAnimations.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TechniqueCell", for: indexPath)
        if let cell = cell as? TechniqueTableCell {
            cell.titleLabel.text = relatedAnimations[indexPath.row]
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension RelatedAnimationsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let view = view as? RelatedAnimationsView else {
            fatalError("view is not of type RelatedAnimationsView")
        }
        
        if let animation = DataLoader.sharedInstance.characterAnimation(name: relatedAnimations[indexPath.row]) {
            // return the sequences I belong to?
        }
        
        
        // TODO: return the sequence name
//        view.delegate?.didTapRelatedAnimation(relatedView: self, animation: relatedAnimations[indexPath.row])
    }
}
