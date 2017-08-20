//
//  RankingsViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/13/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import SDWebImage

struct RankingsConstants {
}
class RankingsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    internal var userRankings: [UserData] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        tableView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()

        tableView.delegate = self
        tableView.dataSource = self
        
//        let RankingsCellNib = UINib(nibName: String(describing: RankingsTableViewCell.self), bundle: nil)
//        tableView.register(RankingsCellNib , forCellReuseIdentifier: CellIdentifiers.RankingsCellIdentifier)
        
        FirebaseService.sharedInstance.retrieveTopBreathStreaks() { topUsers in
            self.userRankings = topUsers
            self.tableView.reloadData()
        }
    }
}

extension RankingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension RankingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userRankings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.RankingsCellIdentifier, for: indexPath)
//        if let cell = cell as? RankingsTableViewCell {
//            let item = RankingsItems[indexPath.row]
//            cell.update(RankingsItem: item) { [unowned self] key in
//                self.displayRankingsOptions(RankingsItem: item, indexPath: indexPath)
//            }
//        }
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let user = userRankings[indexPath.row]
        cell.textLabel?.text = user.userName
        cell.detailTextLabel?.text = "\(user.breathStreakCount)"
        return cell
    }
}

