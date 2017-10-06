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
        
        let RankingsCellNib = UINib(nibName: String(describing: RankingTableViewCell.self), bundle: nil)
        tableView.register(RankingsCellNib , forCellReuseIdentifier: CellIdentifiers.RankingCellIdentifier)
        
        
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && userRankings.count == 0 {
            return CGFloat.leastNonzeroMagnitude
        } else if section == 1 && dayRankings.count == 0 {
            return CGFloat.leastNonzeroMagnitude
        } else if section == 2 && breathRankings.count == 0 {
            return CGFloat.leastNonzeroMagnitude
        }
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 && userRankings.count != 0 {
            return "Top breath streaks"
        } else if section == 1 && dayRankings.count != 0 {
            return "Max day streaks"
        } else if section == 2 && breathRankings.count != 0 {
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
        var textLabel = ""
        var detailLabel = ""
        var location: String?
        if indexPath.section == 0 {
            if let user = userRankings[safe: indexPath.row] {
                textLabel = user.userName
                location = user.city
                detailLabel = "\(BreathTimerService.timeString(time: Double(user.timeStreakCount))) streak"
            }
        } else if indexPath.section == 1 {
            if let user = dayRankings[safe: indexPath.row] {
                textLabel = user.userName
                location = user.city
                detailLabel = "\(user.maxDayStreak) days max"
            }
        } else if indexPath.section == 2 {
            if let user = breathRankings[safe: indexPath.row] {
                textLabel = user.userName
                location = user.city
                detailLabel = "\(BreathTimerService.timeString(time: Double(user.maxTimeStreak))) max streak"
            }
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.RankingCellIdentifier, for: indexPath)
        if let cell = cell as? RankingTableViewCell {
            cell.rankingLabel.text = "\(indexPath.row + 1)"
            cell.userNameLabel.text = textLabel
            cell.locationLabel.text = location
            cell.rankingDescriptionLabel.text = detailLabel
            
        }
        return cell
    }
}

