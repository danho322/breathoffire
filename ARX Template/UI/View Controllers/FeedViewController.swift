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
        view.backgroundColor = ThemeManager.sharedInstance.feedBackgroundColor()
        tableView.backgroundColor = ThemeManager.sharedInstance.feedBackgroundColor()

        tableView.delegate = self
        tableView.dataSource = self
        
        let mapCellNib = UINib(nibName: String(describing: FeedMapTableViewCell.self), bundle: nil)
        tableView.register(mapCellNib, forCellReuseIdentifier: CellIdentifiers.FeedMapCellIdentifier)
        let feedCellNib = UINib(nibName: String(describing: FeedTableViewCell.self), bundle: nil)
        tableView.register(feedCellNib , forCellReuseIdentifier: CellIdentifiers.FeedCellIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseService.sharedInstance.retrieveBreathFeed(allowedUpdates: 2) { items in
            self.feedItems = items
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
        
        self.present(alertMessage, animated: true, completion: nil)
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension FeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return feedItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.FeedMapCellIdentifier, for: indexPath)
            if let cell = cell as? FeedMapTableViewCell {
                let locations = feedItems.filter({ $0.coordinate != nil }).map({ CLLocation(latitude: $0.coordinate!.latitude, longitude: $0.coordinate!.longitude) })
              
                cell.update(locations: locations)
            }
            return cell

        } else {
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
}
