//
//  RegisterViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/17/25.
//

import UIKit

class RegisterViewModel {
    var email: String? {
        didSet {
            validateForm()
        }
    }
    var password: String? {
        didSet {
            validateForm()
        }
    }
    var username: String? {
        didSet {
            validateForm()
        }
    }
    var fullname: String? {
        didSet {
            validateForm()
        }
    }
    var profileImage: UIImage? {
        didSet {
            onProfileImage?(profileImage)
            isSelected = (profileImage?.size != .zero)
            validateForm()
        }
    }
    var isSelected: Bool = false

    var onProfileImage: ((UIImage?) -> Void)?
    var onStatusButton: ((Bool, UIColor) -> Void)?
    var onRegisterSuccess: (() -> Void)?
    var onRegisterFail: ((Error) -> Void)?

    private var validate = false

    func bindingTextField(textField: UITextField) {
        guard let placeholder = textField.attributedPlaceholder?.string,
              let placeholderType = FieldType(rawValue: placeholder) else { return }

        switch placeholderType {
        case .email:
            self.email = textField.text
        case .password:
            self.password = textField.text
        case .username:
            self.username = textField.text
        case .fullname:
            self.fullname = textField.text
        }
    }

    func bindProfileImage(profileImage: UIImage) {
        self.profileImage = profileImage
    }

    func validateForm() {
        validate = [
            email?.isEmpty == false,
            password?.isEmpty == false,
            username?.isEmpty == false,
            fullname?.isEmpty == false,
            isSelected
        ].allSatisfy({$0})

        onStatusButton?(validate, validate ? .enabledColor : .buttonColor)
    }

    func register() {
        guard let email, let password, let username, let fullname, let profileImage else { return }

        AuthService.shared.createUser(email: email, password: password, profileImage: profileImage, username: username, fullname: fullname) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success():
                DispatchQueue.main.async { self.onRegisterSuccess?() } // UI 업데이트는 메인 스레드에서
            case .failure(let error):
                DispatchQueue.main.async { self.onRegisterFail?(error) } // UI 업데이트는 메인 스레드에서
            }
        }
    }

}
