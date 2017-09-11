//
//  LoginViewModel.swift
//  ARX Template
//
//  Created by Daniel Ho on 9/6/17.
//  Copyright © 2017 Daniel Ho. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result
import CoreLocation

class LoginViewModel: ARXViewModel {
    // Input
    let nameInput: MutableProperty<String?> = MutableProperty(nil)
    let emailInput: MutableProperty<String?> = MutableProperty(nil)
    let passwordInput: MutableProperty<String?> = MutableProperty(nil)
    let zipInput: MutableProperty<String?> = MutableProperty(nil)
    
    // Output
    let errorStringOutput: MutableProperty<String?> = MutableProperty(nil)
    
    // Actions
    //    let switchRegisterAction: Action<(), Void, NoError>
    //    let switchRegisterCocoaAction: CocoaAction
    
    internal var disposables = CompositeDisposable()
    
//    override init(services: ViewModelServicesProtocol) {
//        //        switchRegisterAction = Action() { () -> SignalProducer<Void, NoError> in
//        //            return SignalProducer(value: ())
//        //        }
//        //        switchRegisterCocoaAction = CocoaAction(switchRegisterAction, input: ())
//
//        super.init(services: services)
//        FIRAuth.auth()?.addAuthStateDidChangeListener() { [unowned self] auth, user in
//            if let user = user {
//                print("user: \(user): \(auth)")
//                self.navigateToMap()
//            }
//        }
//    }
    
    func bindCell(cell: UITableViewCell?, type: AuthCellType, state: AuthViewState) {
        switch type {
        case .NameTextField:
            if let cell = cell as? NameTableViewCell {
                disposables += nameInput <~ cell.textField.reactive.continuousTextValues
            }
            break
        case .EmailTextField:
            if let cell = cell as? EmailTableViewCell {
                disposables += emailInput <~ cell.textField.reactive.continuousTextValues
            }
            break
        case .PasswordTextField:
            if let cell = cell as? PasswordTableViewCell {
                disposables += passwordInput <~ cell.textField.reactive.continuousTextValues
            }
            break
        case .ZipTextField:
            if let cell = cell as? ZipTableViewCell {
                disposables += zipInput <~ cell.textField.reactive.continuousTextValues
            }
            break
        case .Error:
            if let cell = cell as? ErrorTableViewCell {
                disposables += cell.titleLabel.reactive.text <~ errorStringOutput
            }
        default:
            break
        }
    }
    
    func executeLogin(successHandler: @escaping ()->Void) {
      SessionManager.sharedInstance.signIn(email: emailInput.value, password: passwordInput.value, handler: { success, errorMessage in
                if !success {
                    self.errorStringOutput.value = errorMessage
                } else {
                    successHandler()
        }
            })
    }
    
    func executeSignup(successHandler: @escaping ()->Void) {
        if let zip = zipInput.value {
            if zip.characters.count > 3 {
                CLGeocoder().geocodeAddressString(zip) { [unowned self] (placemarks, error) in
                    if let placemarks = placemarks, placemarks.count > 0 {
                        self.executeSignUp(placemark: placemarks[0], successHandler: successHandler)
                    } else {
                        self.errorStringOutput.value = error?.localizedDescription
                    }
                }
                return
            }
        }
        
        executeSignUp(successHandler: successHandler)
    }
    
    func executeSignUp(placemark: CLPlacemark? = nil, successHandler: @escaping ()->Void) {
        SessionManager.sharedInstance.createUser(userName: nameInput.value,
                                                 email: emailInput.value,
                                                 password: passwordInput.value,
                                                 city: placemark?.name,
                                                 coordinate: placemark?.location?.coordinate,
                                                 handler: { success, errorMessage in
                                                    if !success {
                                                        self.errorStringOutput.value = errorMessage
                                                    } else {
                                                        successHandler()
                                                    }
        })
    }

}
