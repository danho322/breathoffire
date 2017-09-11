//
//  LoginViewController.swift
//  ARX Template
//
//  Created by Daniel Ho on 9/6/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import SwiftLCS
import ReactiveSwift
import FontAwesomeKit

enum AuthViewState {
    case login, register
    
    func cellArray() -> [AuthCellType] {
        switch self {
        case .login:
            return [.Headline("Login to your account"),
                    .Error,
                    .EmailTextField,
                    .PasswordTextField,
                    .SubmitButton("Login"),
                    .Separator,
                    .Subtitle("Don't have an account?"),
                    .ToggleState("Sign up")]
        case .register:
            return [.Headline("Create an account"),
                    .Subtitle("With an account you can store and share your sessions with the community."),
                    .Error,
                    .EmailTextField,
                    .PasswordTextField,
                    .NameTextField,
                    .ZipTextField,
                    .SubmitButton("Register"),
                    .Separator,
                    .Subtitle("Have an account?"),
                    .ToggleState("Log in")]
        }
    }
}

enum AuthCellType {
    case Headline(String)
    case Error
    case EmailTextField
    case NameTextField
    case PasswordTextField
    case ZipTextField
    case SubmitButton(String)
    case ToggleState(String)
    case Separator
    case Subtitle(String)
    
    func identifier() -> String {
        switch self {
        case .Headline:
            return "Headline"
        case .Error:
            return "Error"
        case .EmailTextField:
            return "EmailTextField"
        case .NameTextField:
            return "NameTextField"
        case .PasswordTextField:
            return "PasswordTextField"
        case .ZipTextField:
            return "ZipTextField"
        case .SubmitButton:
            return "SubmitButton"
        case .ToggleState:
            return "ToggleState"
        case .Separator:
            return "Separator"
        case .Subtitle:
            return "Subtitle"
        }
    }
}

extension AuthCellType: Equatable {
}

func ==(lhs: AuthCellType, rhs: AuthCellType) -> Bool {
    switch (lhs, rhs) {
    case (let .Headline(string1), let .Headline(string2)):
        return string1 == string2
    case (let .SubmitButton(string1), let .SubmitButton(string2)):
        return string1 == string2
    case (let .ToggleState(string1), let .ToggleState(string2)):
        return string1 == string2
    case (let .Subtitle(string1), let .Subtitle(string2)):
        return string1 == string2
    default:
        return lhs.identifier() == rhs.identifier()
    }
}


class HeadlineTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        titleLabel.font = ThemeManager.sharedInstance.heavyFont(22)
        titleLabel.textAlignment = .center
        titleLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
    }
}

class ErrorTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        titleLabel.font = ThemeManager.sharedInstance.heavyFont(16)
        titleLabel.textAlignment = .center
        titleLabel.textColor = ThemeManager.sharedInstance.errorTextColor()
    }
}

class EmailTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        textField.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        textField.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        textField.font = ThemeManager.sharedInstance.defaultFont(14)
        textField.text = "Enter your email address"
    }
}

class PasswordTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        textField.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        textField.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        textField.font = ThemeManager.sharedInstance.defaultFont(14)
        textField.text = "Enter a password (5 character minimum)"
    }
}

class NameTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        textField.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        textField.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        textField.font = ThemeManager.sharedInstance.defaultFont(14)
        textField.text = "Enter a username (optional)"
    }
}

class ZipTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        textField.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        textField.textColor = ThemeManager.sharedInstance.focusForegroundColor()
        textField.font = ThemeManager.sharedInstance.defaultFont(14)
        textField.text = "Enter your zip code (optional)"
    }
}

class SubtitleTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        titleLabel.font = ThemeManager.sharedInstance.defaultFont(12)
        titleLabel.textAlignment = .center
        titleLabel.textColor = ThemeManager.sharedInstance.focusForegroundColor()
    }
}

class SubmitTableViewCell: UITableViewCell {
    @IBOutlet weak var submitButton: UIButton!
    
    override func awakeFromNib() {
        submitButton.backgroundColor = ThemeManager.sharedInstance.focusColor()
        submitButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        submitButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(14)
    }
}

class ToggleTableViewCell: UITableViewCell {
    @IBOutlet weak var submitButton: UIButton!
    
    override func awakeFromNib() {
        submitButton.backgroundColor = UIColor.clear
        submitButton.setTitleColor(ThemeManager.sharedInstance.focusColor(), for: .normal)
        submitButton.titleLabel?.font = ThemeManager.sharedInstance.heavyFont(14)
    }
}

class LoginViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!

    var viewModel: LoginViewModel?
    
    internal var currentState: AuthViewState = .login
    internal var disposables = CompositeDisposable()
    
    deinit {
        disposables.dispose()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentState = .login
        
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor.clear
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        
        let backIcon = FAKMaterialIcons.closeIcon(withSize: 25)
        backIcon?.addAttribute(NSAttributedStringKey.foregroundColor.rawValue, value: ThemeManager.sharedInstance.iconColor())
        backButton.setAttributedTitle(backIcon?.attributedString(), for: .normal)
        
        viewModel?.errorStringOutput.producer.startWithValues({ [unowned self] _ in
            self.tableView.reloadData()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo?[UIKeyboardFrameEndUserInfoKey]
        
        if let keyboardFrame = keyboardFrame {
            if let frame = (keyboardFrame as AnyObject).cgRectValue {
                tableViewBottomConstraint.constant = frame.size.height
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        tableViewBottomConstraint.constant = 0
    }
    
    // MARK: - Handlers
    
    @objc func onToggleTap() {
        var newState = AuthViewState.register
        if (currentState == .register) {
            newState = .login
        }
        transitionToViewState(newState)
    }
    
    @objc func onSubmitTap() {
        if (currentState == .register) {
            viewModel?.executeSignup() { [unowned self] in
                self.dismiss()
            }
        } else if (currentState == .login) {
            viewModel?.executeLogin() { [unowned self] in
                self.dismiss()
            }
        }
    }
    
    @IBAction func onBackTap(_ sender: Any) {
        dismiss()
    }
    
    // MARK: - State changes
    
    func transitionToViewState(_ newState: AuthViewState) {
        let diff = currentState.cellArray().diff(newState.cellArray())
        currentState = newState
        
        let addedIndexes = diff.addedIndexes.map({ IndexPath(row: $0, section: 0) })
        let removedIndexes = diff.removedIndexes.map({ IndexPath(row: $0, section: 0) })
        
        tableView?.beginUpdates()
        tableView?.insertRows(at: addedIndexes,
                              with: .fade)
        tableView?.deleteRows(at: removedIndexes,
                              with: .fade)
        tableView?.endUpdates()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //        var newState = AuthViewState.Login
        //        if (currentState == .Login) {
        //            newState = .Register
        //        }
        //        transitionToViewState(newState)
    }
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentState.cellArray().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCellEnum = currentState.cellArray()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: currentCellEnum.identifier())
        switch currentCellEnum {
        case .Headline(let title):
            if let cell = cell as? HeadlineTableViewCell {
                cell.titleLabel.text = title
            }
        case .Subtitle(let title):
            if let cell = cell as? SubtitleTableViewCell {
                cell.titleLabel.text = title
            }
        case .SubmitButton(let title):
            if let cell = cell as? SubmitTableViewCell {
                cell.submitButton.setTitle(title, for: .normal)
                cell.submitButton.addTarget(self, action: #selector(onSubmitTap), for: .touchUpInside)
                
                
            }
        case .ToggleState(let title):
            if let cell = cell as? ToggleTableViewCell {
                cell.submitButton.setTitle(title, for: .normal)
                cell.submitButton.addTarget(self, action: #selector(onToggleTap), for: .touchUpInside)
                
            }
        default:
            break
        }
        
        cell?.backgroundColor = UIColor.clear
        viewModel?.bindCell(cell: cell, type: currentCellEnum, state: currentState)
        
        return cell ?? UITableViewCell()
    }
}
