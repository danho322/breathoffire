//
//  LoginView.swift
//  ARX Template
//
//  Created by Daniel Ho on 8/11/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit

class LoginView: XibView {
    @IBOutlet weak var userNameContainer: UIView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordContainer: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    var completionHandler: (()->Void)?
    
    internal var isSignInState: Bool = false
    internal var initialCenterY: CGFloat?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setupUI() {
        guard let view = view as? LoginView else {
            fatalError("view is not of type LoginView")
        }
        
        view.userNameTextField.delegate = self
        view.emailTextField.delegate = self
        view.passwordTextField.delegate = self
        
        view.backgroundColor = ThemeManager.sharedInstance.backgroundColor()
        view.userNameContainer.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        view.emailContainer.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        view.passwordContainer.backgroundColor = ThemeManager.sharedInstance.foregroundColor()
        
        view.userNameTextField.backgroundColor = UIColor.clear
        view.emailTextField.backgroundColor = UIColor.clear
        view.passwordTextField.backgroundColor = UIColor.clear
        
        view.userNameTextField.textColor = UIColor.white
        view.emailTextField.textColor = UIColor.white
        view.passwordTextField.textColor = UIColor.white
        
        view.userNameTextField.textColor = UIColor.white
        view.emailTextField.textColor = UIColor.white
        view.passwordTextField.textColor = UIColor.white
        
        view.titleLabel.textColor = UIColor.white
        view.titleLabel.font = ThemeManager.sharedInstance.defaultFont(16)
        view.userNameTextField.font = ThemeManager.sharedInstance.defaultFont(16)
        view.emailTextField.font = ThemeManager.sharedInstance.defaultFont(16)
        view.passwordTextField.font = ThemeManager.sharedInstance.defaultFont(16)
        
        view.submitButton.backgroundColor = ThemeManager.sharedInstance.focusColor()
        view.submitButton.setTitleColor(ThemeManager.sharedInstance.focusForegroundColor(), for: .normal)
        
        view.signinButton.setTitleColor(ThemeManager.sharedInstance.focusColor(), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(LoginView.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginView.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        guard let view = view as? LoginView else {
            fatalError("view is not of type LoginView")
        }
        
        if initialCenterY == nil {
            initialCenterY = center.y
        } else {
            return
        }
        
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo?[UIKeyboardFrameEndUserInfoKey]
        
        if let keyboardFrame = keyboardFrame {
            if let frame = (keyboardFrame as AnyObject).cgRectValue {
                
                let offset = (Sizes.ScreenHeight - (view.signinButton.frame.origin.y + view.signinButton.frame.size.height)) - frame.size.height
                
                
                center = CGPoint(x: center.x, y: initialCenterY! - offset)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        center = CGPoint(x: center.x, y: initialCenterY ?? 0)
    }

    @IBAction func onDismissTap(_ sender: Any) {
        // Can't dismiss from here since we're on the child view! :(
        dismiss()
    }
    
    @IBAction func onSubmitTap(_ sender: Any) {
        if !isSignInState {
            SessionManager.sharedInstance.createUser(userName: userNameTextField.text, email: emailTextField.text, password: passwordTextField.text, handler: { success, errorMessage in
                if !success {
                    self.titleLabel.text = errorMessage
                } else {
                    self.dismiss()
                    self.completionHandler?()
                }
            })
        } else {
            SessionManager.sharedInstance.signIn(email: emailTextField.text, password: passwordTextField.text, handler: { success, errorMessage in
                if !success {
                    self.titleLabel.text = errorMessage
                } else {
                    self.dismiss()
                    self.completionHandler?()
                }
            })
        }
    }
    
    @IBAction func onSigninTap(_ sender: Any) {
        isSignInState = true
        userNameContainer.alpha = 0
        titleLabel.text = "Sign In"
    }
    
    func animateIn() {
        guard let view = view as? LoginView else {
            fatalError("view is not of type LoginView")
        }
        
        let offset: CGFloat = 50
        view.alpha = 0
        view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y + offset, width: view.frame.size.width, height: view.frame.size.height)
        let alphaAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            view.alpha = 1
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - offset, width: view.frame.size.width, height: view.frame.size.height)
        })
        alphaAnimator.startAnimation()
    }
    
    func animateOut() {
        guard let view = view as? LoginView else {
            fatalError("view is not of type LoginView")
        }
        
        let offset: CGFloat = -50
        let alphaAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeInOut, animations: {
            view.alpha = 0
            view.frame = CGRect(x: view.frame.origin.x, y: view.frame.origin.y - offset, width: view.frame.size.width, height: view.frame.size.height)
        })
        alphaAnimator.addCompletion({ position in
            self.removeFromSuperview()
        })
        alphaAnimator.startAnimation()
    }
    
    func dismiss() {  
        var viewToDismiss: LoginView = self
        if let superview = self.superview as? LoginView {
            viewToDismiss = superview
        }
        
        viewToDismiss.animateOut()
        viewToDismiss.completionHandler?()
    }
}

extension LoginView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}
