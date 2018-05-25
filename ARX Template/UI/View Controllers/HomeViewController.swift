//
//  HomeViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 1/17/18.
//  Copyright © 2018 Daniel Ho. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import Result

enum SessionType: Int {
    case open = 0
    case solo = 1
    case flowA = 2
    case combat = 3
    case count = 4
    
    func imageName() -> String {
        switch self {
        case .solo:
            return "sessionClosedIcon"
        case .open:
            return "sessionOpenIcon"
        case .flowA:
            return "flowAIcon"
        case .combat:
            return "nervous"
        default:
            return ""
        }
    }
    
    func infoString() -> String {
        switch self {
        case .solo:
            return "Start a focused breathing session on your own. Let breathing bring you focus, clarity, and energy."
        case .open:
            return "Create an open breathing session, where people around the world can join. Set an intention, and utilize the power of focused energy from group intention."
        case .flowA:
            return "Start a yoga flow to warm up the body through breathing and body movements."
        case .combat:
            return "Use combat breathing to calm down your nerves. Helps control nervous shaking."
        default:
            return ""
        }
    }
    
    func sequenceName() -> String? {
        switch self {
        case .flowA:
            return "Yoga Flow A"
        case .combat:
            return "Combat Breathe"
        default:
            return nil
        }
    }
    
    func isComingSoon() -> Bool {
        switch self {
        case .flowA:
            return true
        default:
            return false
        }
    }
}

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
    }
    
    func cell(indexPath: IndexPath, vc: HomeViewController) -> UITableViewCell {
        if self == .motivation {
            if let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.FeedMotivationCellIdentifier) as? FeedMotivationTableViewCell {
                cell.updateQuote(vc.quoteOfDay, hideBreatheButton: true)
                return cell
            }
        } else if self == .liveSessions {
            if let session = vc.liveSessions[safe: indexPath.row],
                let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.LiveSessionCellIdentifier, for: indexPath) as? LiveSessionTableViewCell {
                cell.configure(session)
                return cell
            }
        } else if self == .breathe {
            if let cell = vc.tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.BreatheStartTableViewCellIdentifier, for: indexPath) as? BreatheStartTableViewCell {
                cell.startHandler = { [unowned vc] sessionType, intention, durationSequenceType, arMode in
                    
                    if sessionType.isComingSoon() {
                        vc.showComingSoonAlert()
                    } else {
                        var liveSessionInfo: LiveSessionInfo?
                        var sequence = DataLoader.sharedInstance.sequenceData(sequenceName: durationSequenceType.sequenceName())
                        if sessionType == .open {
                            liveSessionInfo = LiveSessionInfo(type: .create, liveSession: nil, intention: intention)
                        } else if let sequenceName = sessionType.sequenceName() {
                            sequence = DataLoader.sharedInstance.sequenceData(sequenceName: sequenceName)
                        }
                        
                        vc.startARTechnique(sequenceContainer: sequence,
                                            liveSessionInfo: liveSessionInfo,
                                            isAREnabled: arMode)
                    }
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func heightForSectionHeader(vc: HomeViewController) -> CGFloat {
        if self == .liveSessions {
            return vc.liveSessions.count == 0 ? CGFloat.leastNonzeroMagnitude : 30
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
    internal var disposables = CompositeDisposable()
    
    deinit {
        disposables.dispose()
    }
    
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
        
        FirebaseService.sharedInstance.trimExtraFeed()
        
        disposables += NotificationCenter.default.reactive.notifications(forName: Notification.Name.UIKeyboardWillShow).producer.startWithValues({ [weak self] notification in
            self?.tableView.scrollToRow(at: IndexPath(row: 0, section: HomeViewSectionTypes.breathe.rawValue), at: .top, animated: true)
        })
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
    
    func showComingSoonAlert() {
        let alert = UIAlertController(title: "Coming soon",
                                      message: "This feature will be available soon. Stay tuned!",
                                      preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(
            UIAlertAction(title: "Ok",
                          style: UIAlertActionStyle.default,
                          handler: nil
            )
        )
        if let popoverPresentationController = alert.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = self.view.bounds
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Live Session
    
    func startARTechnique(sequenceContainer: AnimationSequenceDataContainer?, liveSessionInfo: LiveSessionInfo? = nil, isAREnabled: Bool) {
        if let arVC = storyboard?.instantiateViewController(withIdentifier: "ARTechniqueIdentifier") as? ARTechniqueViewController,
            let sequenceContainer = sequenceContainer {
            arVC.sequenceToLoad = sequenceContainer
            arVC.isARModeEnabled = isAREnabled
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
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        UIApplication.shared.sendAction(#selector(UIApplication.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let sectionType = HomeViewSectionTypes(rawValue: indexPath.section) {
            if sectionType == .liveSessions, let liveSession = liveSessions[safe: indexPath.row] {
                startARTechnique(sequenceContainer: DataLoader.sharedInstance.sequenceData(sequenceName: liveSession.sequenceName),
                                 liveSessionInfo: LiveSessionInfo(type: .join, liveSession: liveSession, intention: nil), isAREnabled: true)
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
