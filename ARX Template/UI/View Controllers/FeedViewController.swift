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

enum FeedViewSectionTypes: Int {
    case motivation = 0
    case map = 1
    case feed = 2
    case userRanking = 3
    case breathRanking = 4
    case dayRanking = 5
    case count = 6
    
    func rowCount(vc: FeedViewController) -> Int {
        if self == .feed {
            return min(1, vc.feedItems.count)
        } else if self == .userRanking {
            return vc.userRankings.count
        } else if self == .dayRanking {
            return vc.dayRankings.count
        } else if self == .breathRanking {
            return vc.breathRankings.count
        } else {
            return 1
        }
    }
    
    func cell(indexPath: IndexPath, vc: FeedViewController) -> UITableViewCell {
        if self == .motivation {
            if let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.FeedMotivationCellIdentifier) as? FeedMotivationTableViewCell {
                cell.breatheHandler = { [unowned vc] in
                    if let arVC = vc.storyboard?.instantiateViewController(withIdentifier: "ARTechniqueIdentifier") as? ARTechniqueViewController,
                        let motdSequenceContainer = DataLoader.sharedInstance.moveOfTheDay() {
                        arVC.sequenceToLoad = motdSequenceContainer
                        //                arVC.isARModeEnabled = false
                        arVC.dismissCompletionHandler = {
                            vc.navigationController?.popToRootViewController(animated: true)
                            vc.tabBarController?.selectedIndex = 0
                        }
                        vc.present(arVC, animated: true, completion: nil)
                    }
                }
                return cell
            }
        } else if self == .map {
            if let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.FeedMapCellIdentifier) as? FeedMapTableViewCell {
                let locations = vc.feedItems.filter({ $0.coordinate != nil }).map({ CLLocation(latitude: $0.coordinate!.latitude, longitude: $0.coordinate!.longitude) })
                cell.update(locations: locations)
                return cell
            }
        } else if self == .feed {
            let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.FeedHorizontalScrollViewIdentifier, for: indexPath)
            if let cell = cell as? FeedHorizontalScrollViewTableViewCell {
                cell.update(feedItems: vc.feedItems, optionsHandler: { key in
                    if let item = vc.feedItems.filter({ $0.key == key }).first {
                        vc.displayFeedOptions(feedItem: item, indexPath: indexPath)
                    }
                })
            }
            return cell
        } else {
            var textLabel = ""
            var detailLabel = ""
            var location: String?
            if self == .userRanking  {
                if let user = vc.userRankings[safe: indexPath.row] {
                    textLabel = user.userName
                    location = user.city
                    detailLabel = "\(BreathTimerService.timeString(time: Double(user.timeStreakCount)))"
                }
            } else if self == .dayRanking {
                if let user = vc.dayRankings[safe: indexPath.row] {
                    textLabel = user.userName
                    location = user.city
                    let dayString = user.maxDayStreak == 1 ? "day" : "days"
                    detailLabel = "\(user.maxDayStreak) \(dayString)"
                }
            } else if self == .breathRanking {
                if let user = vc.breathRankings[safe: indexPath.row] {
                    textLabel = user.userName
                    location = user.city
                    detailLabel = "\(BreathTimerService.timeString(time: Double(user.maxTimeStreak)))"
                }
            }
            
            if let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.RankingCellIdentifier, for: indexPath) as? RankingTableViewCell {
                cell.rankingLabel.text = "\(indexPath.row + 1)"
                cell.userNameLabel.text = textLabel
                cell.locationLabel.text = location
                cell.rankingDescriptionLabel.text = detailLabel
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func heightForSectionHeader(vc: FeedViewController) -> CGFloat {
        if self == .userRanking {
            return vc.userRankings.count == 0 ? CGFloat.leastNonzeroMagnitude : 30
        } else if self == .dayRanking {
            return vc.dayRankings.count == 0 ? CGFloat.leastNonzeroMagnitude : 30
        } else if self == .breathRanking {
            return vc.breathRankings.count == 0 ? CGFloat.leastNonzeroMagnitude : 30
        } else {
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func titleForSectionHeader(vc: FeedViewController) -> String? {
        if self == .userRanking {
            return "Top breath streaks"
        } else if self == .dayRanking {
            return "Max day streaks"
        } else if self == .breathRanking {
            return "Max breath streaks"
        } else {
            return nil
        }
    }
}

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    internal var feedItems: [BreathFeedItem] = []
    internal var userRankings: [UserData] = []
    internal var dayRankings: [UserData] = []
    internal var breathRankings: [UserData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = ThemeManager.sharedInstance.feedBackgroundColor()
        tableView.backgroundColor = ThemeManager.sharedInstance.feedBackgroundColor()

        tableView.delegate = self
        tableView.dataSource = self
        
        let motivationCellNib = UINib(nibName: String(describing: FeedMotivationTableViewCell.self), bundle: nil)
        tableView.register(motivationCellNib, forCellReuseIdentifier: CellIdentifiers.FeedMotivationCellIdentifier)
        let mapCellNib = UINib(nibName: String(describing: FeedMapTableViewCell.self), bundle: nil)
        tableView.register(mapCellNib, forCellReuseIdentifier: CellIdentifiers.FeedMapCellIdentifier)
        let feedCellNib = UINib(nibName: String(describing: FeedTableViewCell.self), bundle: nil)
        tableView.register(feedCellNib , forCellReuseIdentifier: CellIdentifiers.FeedCellIdentifier)
        let feedHorizontalCellNib = UINib(nibName: String(describing: FeedHorizontalScrollViewTableViewCell.self), bundle: nil)
        tableView.register(feedHorizontalCellNib , forCellReuseIdentifier: CellIdentifiers.FeedHorizontalScrollViewIdentifier)
        let RankingsCellNib = UINib(nibName: String(describing: RankingTableViewCell.self), bundle: nil)
        tableView.register(RankingsCellNib , forCellReuseIdentifier: CellIdentifiers.RankingCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseService.sharedInstance.retrieveBreathFeed(allowedUpdates: 2) { items in
            self.feedItems = items
            self.tableView.reloadData()
        }
        
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
    
    class func createGifDataFrom(imagePathArray: [String], completion: @escaping (Data)->Void) {
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            var index = 0
            var imageCount = 0
            let imageTotal = imagePathArray.count
            var imageDict: [Int: UIImage] = Dictionary<Int, UIImage>()
            for imagePath in imagePathArray {
                let thisIndex = index
                FirebaseService.sharedInstance.retrieveDataAtPath(path: imagePath, completion: { imageData in
                    if let image = UIImage(data: imageData) {
                        imageDict[thisIndex] = image
                        imageCount += 1
                        if imageCount == imageTotal {
                            let imageArray = imageDict.sorted(by: { $0.key < $1.key}).map({ $0.value })
                            ARXUtilities.createGIF(with: imageArray, frameDelay: GifConstants.FrameDelay, callback: { data, error in
                                if let data = data {
                                    DispatchQueue.main.async(execute: {
                                        completion(data)
                                    })
                                }
                            })
                        }
                    }
                })
                index += 1
            }
        })
    }
    
    func displayFeedOptions(feedItem: BreathFeedItem, indexPath: IndexPath) {

        let alertMessage = UIAlertController(title: NSLocalizedString("Options", comment: "Action sheet title"),
                                             message: nil,
                                             preferredStyle: .actionSheet)

        if SessionManager.sharedInstance.isCurrentUser(userId: feedItem.userId) {
            alertMessage.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: "Ok button title"), style: .destructive, handler: { [unowned self] _ in
                FirebaseService.sharedInstance.deleteFeedItem(feedItem: feedItem)
                self.feedItems.remove(at: indexPath.row)
                self.tableView.reloadData()
            }))
        } else {
            alertMessage.addAction(UIAlertAction(title: NSLocalizedString("Report Inappropriate", comment: "Ok button title"), style: .destructive, handler: { [unowned self] _ in
                self.handleMarkInappropriate(feedItem: feedItem, row: indexPath.row)
            }))

        }
        
        alertMessage.addAction(UIAlertAction(title: NSLocalizedString("Share", comment: "Ok button title"), style: .default, handler: { [unowned self] _ in
            if let cell = self.tableView.cellForRow(at: indexPath) {
                FeedViewController.createGifDataFrom(imagePathArray: feedItem.imagePathArray, completion: { data in
                    let objectsToShare = [data]
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
        if let popoverPresentationController = alertMessage.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        self.present(alertMessage, animated: true, completion: nil)
    }
    
    func handleMarkInappropriate(feedItem: BreathFeedItem, row: Int) {
        let alertMessage = UIAlertController(title: NSLocalizedString("Are you sure?", comment: "Action sheet title"),
                                             message: "Marking this item as inappropriate will remove it from the feed until further review.",
                                             preferredStyle: .alert)

        alertMessage.addAction(UIAlertAction(title: NSLocalizedString("Yes, I understand", comment: "Ok button title"), style: .destructive, handler: { [unowned self] _ in
            FirebaseService.sharedInstance.markInappropriate(feedItem: feedItem)
            self.feedItems.remove(at: row)
            self.tableView.reloadData()
        }))
        alertMessage.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        if let popoverPresentationController = alertMessage.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        self.present(alertMessage, animated: true, completion: nil)
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let sectionType = FeedViewSectionTypes(rawValue: section) {
            return sectionType.heightForSectionHeader(vc: self)
        }
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionType = FeedViewSectionTypes(rawValue: section) {
            return sectionType.titleForSectionHeader(vc: self)
        }
        return nil
    }
}

extension FeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return FeedViewSectionTypes.count.rawValue
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sectionType = FeedViewSectionTypes(rawValue: section) {
            return sectionType.rowCount(vc: self)
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let sectionType = FeedViewSectionTypes(rawValue: indexPath.section) {
            return sectionType.cell(indexPath: indexPath, vc: self)
        }
        return UITableViewCell()
    }
}
