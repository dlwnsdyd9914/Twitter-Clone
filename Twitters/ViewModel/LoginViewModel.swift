//
//  LoginViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/18/25.
//

import UIKit

class LoginViewModel {
    var email: String? {
        didSet {
            validateFormCheck()
        }
    }
    var password: String? {
        didSet {
            validateFormCheck()
        }
    }

    var onButtonStatus: ((Bool, UIColor) -> Void)?
    var onLoginSuccess: (() -> Void)?
    var onLoginFail: ((Error) -> Void)?

    private(set) var vaildate = false

    func bindTextField(textField: UITextField) {
        guard let attributedPlaceholder = textField.attributedPlaceholder?.string,
              let textFieldType = FieldType(rawValue: attributedPlaceholder) else { return }

        switch textFieldType {
        case .email:
            self.email = textField.text
        case .password:
            self.password = textField.text
        default:
            break
        }
    }

    func validateFormCheck() {
        vaildate = [
            email?.isEmpty == false,
            password?.isEmpty == false
        ].allSatisfy({$0})

        self.onButtonStatus?(vaildate, vaildate ? .enabledColor : .buttonColor)
    }

    func login() {
        guard let email,
              let password else { return }

        AuthService.shared.login(email: email, password: password) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success():
                
                DispatchQueue.main.async { self.onLoginSuccess?()}
            case .failure(let error):
                DispatchQueue.main.async { self.onLoginFail?(error) }
            }
        }
    }
}
