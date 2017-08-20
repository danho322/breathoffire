//
//  FeedViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/13/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import SDWebImage

struct FeedConstants {
}
class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    internal var feedItems: [BreathFeedItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        tableView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()

        tableView.delegate = self
        tableView.dataSource = self
        
        let feedCellNib = UINib(nibName: String(describing: FeedTableViewCell.self), bundle: nil)
        tableView.register(feedCellNib , forCellReuseIdentifier: CellIdentifiers.FeedCellIdentifier)
        
        FirebaseService.sharedInstance.retrieveBreathFeed() { items in
            self.feedItems = items
            self.tableView.reloadData()
        }
    }
    
    func displayFeedOptions(feedItem: BreathFeedItem, indexPath: IndexPath) {

        let alertMessage = UIAlertController(title: NSLocalizedString("Options", comment: "Action sheet title"),
                                             message: nil,
                                             preferredStyle: .actionSheet)
        
        alertMessage.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Ok button title"), style: .destructive, handler: { [unowned self] _ in
            FirebaseService.sharedInstance.deleteFeedItem(feedItem: feedItem)
            self.feedItems.remove(at: indexPath.row)
            self.tableView.reloadData()
        }))
        
        alertMessage.addAction(UIAlertAction(title: NSLocalizedString("Share", comment: "Ok button title"), style: .default, handler: { [unowned self] _ in
            if let cell = self.tableView.cellForRow(at: indexPath) {
                FirebaseService.sharedInstance.retrieveImageAtPath(path: feedItem.imagePath, completion: { image in
                    let objectsToShare = [image]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    
                    activityVC.popoverPresentationController?.sourceView = cell
                    self.present(activityVC, animated: true, completion: nil)
                })
            }
        }))
        
        alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if let cell = tableView.cellForRow(at: indexPath) {
            alertMessage.popoverPresentationController?.sourceView = cell
            alertMessage.popoverPresentationController?.sourceRect = cell.frame
            alertMessage.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        }
        self.present(alertMessage, animated: true, completion: nil)
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension FeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.FeedCellIdentifier, for: indexPath)
        if let cell = cell as? FeedTableViewCell {
            let item = feedItems[indexPath.row]
            cell.update(feedItem: item) { [unowned self] key in
                self.displayFeedOptions(feedItem: item, indexPath: indexPath)
            }
        }
        return cell
    }
}
