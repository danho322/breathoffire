//
//  HomeViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 1/17/18.
//  Copyright © 2018 Daniel Ho. All rights reserved.
//

import UIKit

enum HomeViewSectionTypes: Int {
    case motivation = 0
    case breathe = 1
    case liveSessions = 2
    case count = 3
    
    func rowCount(vc: HomeViewController) -> Int {
        if self == .liveSessions {
            return vc.liveSessions.count
        } else {
            return 1
        }
        return 0
    }
    
    func cell(indexPath: IndexPath, vc: HomeViewController) -> UITableViewCell {
        if self == .motivation {
            if let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.FeedMotivationCellIdentifier) as? FeedMotivationTableViewCell {
                cell.updateQuote(vc.quoteOfDay, hideBreatheButton: true)
                return cell
            }
//        } else if self == .map {
//            if let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.FeedMapCellIdentifier) as? FeedMapTableViewCell {
//                let locations = vc.feedItems.filter({ $0.coordinate != nil }).map({ CLLocation(latitude: $0.coordinate!.latitude, longitude: $0.coordinate!.longitude) })
//                cell.update(locations: locations)
//                return cell
//            }
//        } else if self == .feed {
//            let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.FeedHorizontalScrollViewIdentifier, for: indexPath)
//            if let cell = cell as? FeedHorizontalScrollViewTableViewCell {
//                cell.update(feedItems: vc.feedItems, optionsHandler: { key in
//                    if let item = vc.feedItems.filter({ $0.key == key }).first {
//                        vc.displayFeedOptions(feedItem: item, indexPath: indexPath)
//                    }},
//                            outerScrollView: vc.tableView)
//            }
//            return cell
//        } else {
//            var isRanking = true
//            var textLabel = ""
//            var detailLabel = ""
//            var location: String?
//            if self == .userRanking  {
//                if let user = vc.userRankings[safe: indexPath.row] {
//                    textLabel = user.userName
//                    location = user.city
//                    detailLabel = "\(BreathTimerService.timeString(time: Double(user.timeStreakCount)))"
//                }
//            } else if self == .dayRanking {
//                if let user = vc.dayRankings[safe: indexPath.row] {
//                    textLabel = user.userName
//                    location = user.city
//                    let dayString = user.maxDayStreak == 1 ? "day" : "days"
//                    detailLabel = "\(user.maxDayStreak) \(dayString)"
//                }
//            } else if self == .breathRanking {
//                if let user = vc.breathRankings[safe: indexPath.row] {
//                    textLabel = user.userName
//                    location = user.city
//                    detailLabel = "\(BreathTimerService.timeString(time: Double(user.maxTimeStreak)))"
//                }
        } else if self == .liveSessions {
            if let session = vc.liveSessions[safe: indexPath.row],
                let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.LiveSessionCellIdentifier, for: indexPath) as? LiveSessionTableViewCell{
                cell.configure(session)
                return cell
            }
        } else if self == .breathe {
            if let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.BreatheStartTableViewCellIdentifier, for: indexPath) as? BreatheStartTableViewCell {
                cell.startHandler = { [unowned vc] intention in
                    vc.startARTechnique(sequenceContainer: DataLoader.sharedInstance.moveOfTheDay(),
                                          liveSessionInfo: LiveSessionInfo(type: .create, liveSession: nil, intention: intention))
                }
                return cell
            }
//            if let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.BreatheStartTableViewCellIdentifier, for: indexPath) as? BreatheStartTableViewCell {
//                return cell
//            }
        }
//
//            if let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.RankingCellIdentifier, for: indexPath) as? RankingTableViewCell, isRanking {
//                cell.rankingLabel.text = "\(indexPath.row + 1)"
//                cell.userNameLabel.text = textLabel
//                cell.locationLabel.text = location
//                cell.rankingDescriptionLabel.text = detailLabel
//                return cell
//            }
//        }
        return UITableViewCell()
    }
    
    func heightForSectionHeader(vc: HomeViewController) -> CGFloat {
//        if self == .userRanking {
//            return vc.userRankings.count == 0 ? CGFloat.leastNonzeroMagnitude : 30
//        } else if self == .dayRanking {
//            return vc.dayRankings.count == 0 ? CGFloat.leastNonzeroMagnitude : 30
//        } else if self == .breathRanking {
//            return vc.breathRankings.count == 0 ? CGFloat.leastNonzeroMagnitude : 30
        if self == .liveSessions {
            return vc.liveSessions.count == 0 ? CGFloat.leastNonzeroMagnitude : 30
//        } else {
//            return CGFloat.leastNonzeroMagnitude
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func titleForSectionHeader(vc: HomeViewController) -> String? {
        if self == .liveSessions {
            return "Current live sessions"
        } else {
            return nil
        }
    }
}

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    internal var liveSessions: [LiveSession] = []
    internal var cellHeights = [IndexPath:CGFloat]()
    internal var quoteOfDay: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Home"
        // Do any additional setup after loading the view.
        // "the unit thing"
        // actionable immediately
        // possibly live sessions
        // input for intention... persistent?
    
        view.backgroundColor = ThemeManager.sharedInstance.feedBackgroundColor()
        tableView.backgroundColor = UIColor.clear
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let motivationCellNib = UINib(nibName: String(describing: FeedMotivationTableViewCell.self), bundle: nil)
        tableView.register(motivationCellNib, forCellReuseIdentifier: CellIdentifiers.FeedMotivationCellIdentifier)
        let breatheCellNib = UINib(nibName: String(describing: BreatheStartTableViewCell.self), bundle: nil)
        tableView.register(breatheCellNib, forCellReuseIdentifier: CellIdentifiers.BreatheStartTableViewCellIdentifier)
        let liveSessionCellNib = UINib(nibName: String(describing: LiveSessionTableViewCell.self), bundle: nil)
        tableView.register(liveSessionCellNib , forCellReuseIdentifier: CellIdentifiers.LiveSessionCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseService.sharedInstance.retrieveRandomManifestation(completionHandler: { [unowned self] quote in
            self.quoteOfDay = quote
            self.tableView.reloadData()
        })
        
        if let userId = SessionManager.sharedInstance.currentUserData?.userId {
            LiveSessionManager.sharedInstance.currentSessions() { [unowned self] liveSessions in
                self.liveSessions = liveSessions.filter({ $0.creatorUserId != userId })
            }
        }
        
        if let userId = SessionManager.sharedInstance.currentUserData?.userId {
            LiveSessionManager.sharedInstance.currentSessions() { [unowned self] liveSessions in
                self.liveSessions = liveSessions.filter({ $0.creatorUserId != userId })
            }
        }
    }
    
    // MARK: - Live Session
    
    func startARTechnique(sequenceContainer: AnimationSequenceDataContainer?, liveSessionInfo: LiveSessionInfo? = nil) {
        if let arVC = storyboard?.instantiateViewController(withIdentifier: "ARTechniqueIdentifier") as? ARTechniqueViewController,
            let sequenceContainer = sequenceContainer {
            arVC.sequenceToLoad = sequenceContainer
            if let liveSessionInfo = liveSessionInfo {
                arVC.liveSessionInfo = liveSessionInfo
            }
            arVC.dismissCompletionHandler = {
                self.navigationController?.popToRootViewController(animated: true)
                self.tabBarController?.selectedIndex = 0
            }
            self.present(arVC, animated: true, completion: nil)
            
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sectionType = HomeViewSectionTypes(rawValue: indexPath.section) {
            if sectionType == .liveSessions, let liveSession = liveSessions[safe: indexPath.row] {
                startARTechnique(sequenceContainer: DataLoader.sharedInstance.sequenceData(sequenceName: liveSession.sequenceName),
                                 liveSessionInfo: LiveSessionInfo(type: .join, liveSession: liveSession, intention: nil))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let sectionType = HomeViewSectionTypes(rawValue: section) {
            return sectionType.heightForSectionHeader(vc: self)
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let frame = tableView.rectForRow(at: indexPath)
        cellHeights[indexPath] = frame.size.height
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return HomeViewSectionTypes.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionType = HomeViewSectionTypes(rawValue: section) {
            return sectionType.rowCount(vc: self)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let sectionType = HomeViewSectionTypes(rawValue: indexPath.section) {
            return sectionType.cell(indexPath: indexPath, vc: self)
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let sectionType = HomeViewSectionTypes(rawValue: section),
            sectionType.rowCount(vc: self) > 0 {
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
            headerView.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
            let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.size.width - 5, height: 50))
            label.backgroundColor = UIColor.clear
            label.textColor = ThemeManager.sharedInstance.labelTitleColor()
            label.font = ThemeManager.sharedInstance.heavyFont(16)
            label.text = sectionType.titleForSectionHeader(vc: self)
            headerView.addSubview(label)
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath] ?? 110.0
    }
}
