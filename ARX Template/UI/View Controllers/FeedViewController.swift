//
//  FeedViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/13/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

struct FeedConstants {
}
class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    internal var feedItems: [BreathFeedItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        let feedCellNib = UINib(nibName: String(describing: FeedTableViewCell.self), bundle: nil)
        tableView.register(feedCellNib , forCellReuseIdentifier: CellIdentifiers.FeedCellIdentifier)
        
        FirebaseService.sharedInstance.retrieveBreathFeed() { items in
            self.feedItems = items
            self.tableView.reloadData()
        }
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
            cell.update(feedItem: feedItems[indexPath.row])
        }
        return cell
    }
}
