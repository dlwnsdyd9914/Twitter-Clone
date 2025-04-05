//
//  LoginViewController.swift
//  Twitters
//
//  Created by 이준용 on 2/16/25.
//

import UIKit
import SwiftUI
import Then

final class LoginViewController: UIViewController {

    // MARK: - Properties

    // MARK: - View Models

    private var viewModel = LoginViewModel()

    // MARK: - UI Components

    private let logoImageView = UIImageView().then {
        $0.image = .twitterLogo
    }

    private lazy var containerViews: [CustomContainerView]  = {
        let fieldData: [(UIImage, String)] = [
               (UIImage.emailImage, "Email"),
               (UIImage.passwordImage, "Password")
           ]

        let field =  fieldData.map { image, placeholder in
            let textField: CustomTextField = {
                let tf = CustomTextField(placeholder: placeholder)
                if tf.placeholder == "Email" {
                    tf.keyboardType = .emailAddress
                } else {
                    tf.isSecureTextEntry = true
                }
                tf.addTarget(self, action: #selector(handleTextField), for: .editingChanged)
                return tf
            }()
            return CustomContainerView(image: image, textField: textField)
        }
        return field


    }()

    private lazy var loginStackView = UIStackView(arrangedSubviews: containerViews).then { stack in
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 8
    }

    private lazy var loginButton = UIButton(type: .custom).then {
        $0.setTitle("Log In", for: .normal)
        $0.setTitleColor(.twitterBlue, for: .normal)
        $0.backgroundColor = .buttonColor
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.layer.cornerRadius = 6
        $0.addTarget(self, action: #selector(handleLoginButton), for: .touchUpInside)
        $0.isEnabled = false
    }

    private lazy var registerButton = UIButton(type: .custom).then {
        $0.applyAttributedTitle(main: "계정이 없으신가요? ", sub: "가입 하세요!", font: .boldSystemFont(ofSize: 16), textColor: .white)
        $0.addTarget(self, action: #selector(handleRegisterButton), for: .touchUpInside)
    }

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setup()
        configureConstraints()
        bindingViewModel()
    }

    // MARK: - Selectors

    @objc private func handleLoginButton() {
        viewModel.login()
    }

    @objc private func handleRegisterButton() {
        let registerController = RegisterViewController()
        self.navigationController?.pushViewController(registerController, animated: true)
    }

    @objc private func handleTextField(textField: UITextField) {
        viewModel.bindTextField(textField: textField)
    }

    // MARK: - UI Configurations

    private func configureUI() {
        self.view.backgroundColor = .twitterBlue
    }

    private func setup() {
        [logoImageView, loginStackView, loginButton, registerButton].forEach { add in
            self.view.addSubview(add)
        }
    }

    private func configureConstraints() {
        logoImageViewConstraints()
        loginStackViewConstraints()
        loginButtonConstraints()
        registerButtonConstraints()
    }

    private func logoImageViewConstraints() {
        logoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, trailing: nil, bottom: nil, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 150, height: 150, centerX: view.centerXAnchor, centerY: nil)

    }

    private func loginStackViewConstraints() {
        loginStackView.anchor(top: logoImageView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, paddingTop: 40, paddingLeading: 40, paddingTrailing: 40, paddingBottom: 0, width: 0, height: 80, centerX: nil, centerY: nil)
    }

    private func loginButtonConstraints() {
        loginButton.anchor(top: loginStackView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, paddingTop: 8, paddingLeading: 40, paddingTrailing: 40, paddingBottom: 0, width: 0, height: 40, centerX: nil, centerY: nil)
    }

    private func registerButtonConstraints() {
        registerButton.anchor(top: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 30, centerX: nil, centerY: nil)
    }

    // MARK: - Functions

    private func loginSuccess() {
        print("✅ 로그인 성공")
        let mainTabController = MainTabController()
        mainTabController.modalPresentationStyle = .fullScreen
        self.present(mainTabController, animated: true)
    }


    // MARK: - Bind ViewModels

    private func bindingViewModel() {
        viewModel.onLoginFail = { [weak self] error in
            guard let self else { return }

        }

        viewModel.onLoginSuccess = { [weak self] in
            guard let self else { return }
            self.loginSuccess()
        }

        viewModel.onButtonStatus = { [weak self] status, color in
            guard let self else { return }
            self.loginButton.isEnabled = status
            self.loginButton.backgroundColor = color
        }
    }

}

#Preview {
    VCPreView {
        LoginViewController()
    }.edgesIgnoringSafeArea(.all)
}
