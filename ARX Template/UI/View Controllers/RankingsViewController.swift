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
    internal var dayRankings: [UserData] = []
    internal var breathRankings: [UserData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        tableView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()

        tableView.delegate = self
        tableView.dataSource = self
        
//        let RankingsCellNib = UINib(nibName: String(describing: RankingsTableViewCell.self), bundle: nil)
//        tableView.register(RankingsCellNib , forCellReuseIdentifier: CellIdentifiers.RankingsCellIdentifier)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseService.sharedInstance.retrieveCurrentTimeStreaks() { [unowned self] topUsers in
            self.userRankings = topUsers
            self.tableView.reloadData()
        }
        
        FirebaseService.sharedInstance.retrieveMaxAttributes(attribute: UserAttribute.maxDayStreak) { [unowned self] topDayUsers in
            self.dayRankings = topDayUsers
            self.tableView.reloadData()
        }
        
        FirebaseService.sharedInstance.retrieveMaxAttributes(attribute: UserAttribute.maxTimeStreak) { [unowned self] topBreathUsers in
            self.breathRankings = topBreathUsers
            self.tableView.reloadData()
        }
    }
}

extension RankingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Top breath streaks"
        } else if section == 1 {
            return "Max day streaks"
        } else if section == 2 {
            return "Max breath streaks"
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension RankingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return userRankings.count
        } else if section == 1 {
            return dayRankings.count
        } else if section == 2 {
            return breathRankings.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.RankingsCellIdentifier, for: indexPath)
//        if let cell = cell as? RankingsTableViewCell {
//            let item = RankingsItems[indexPath.row]
//            cell.update(RankingsItem: item) { [unowned self] key in
//                self.displayRankingsOptions(RankingsItem: item, indexPath: indexPath)
//            }
//        }
        var textLabel = ""
        var detailLabel = ""
        if indexPath.section == 0 {
            if let user = userRankings[safe: indexPath.row] {
                textLabel = user.userName
                detailLabel = "\(BreathTimerService.timeString(time: Double(user.timeStreakCount))) streak"
            }
        } else if indexPath.section == 1 {
            if let user = dayRankings[safe: indexPath.row] {
                textLabel = user.userName
                detailLabel = "\(user.maxDayStreak) days max"
            }
        } else if indexPath.section == 2 {
            if let user = breathRankings[safe: indexPath.row] {
                textLabel = user.userName
                detailLabel = "\(BreathTimerService.timeString(time: Double(user.maxTimeStreak))) max streak"
            }
        }
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = textLabel
        cell.detailTextLabel?.text = detailLabel
        return cell
    }
}

