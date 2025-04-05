//
//  RegisterViewController.swift
//  Twitters
//
//  Created by 이준용 on 2/17/25.
//

import UIKit
import Then
import SwiftUI

final class RegisterViewController: UIViewController {

    // MARK: - Properties

    // MARK: - View Models

    private var viewModel = RegisterViewModel()

    // MARK: - UI Components

    private lazy var addProfileButton = UIButton(type: .custom).then {
        $0.setImage(.plusPhoto.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(handleAddProfileButton), for: .touchUpInside)
    }

    private lazy var fieldDataView: [CustomContainerView] = {
        let fieldData: [(UIImage, FieldType)] = [
            (UIImage.emailImage, .email),
            (UIImage.passwordImage, .password),
            (UIImage.nameFieldImage, .username),
            (UIImage.nameFieldImage, .fullname)
        ]

        return fieldData.map { image, fieldType in
            let signTextField: CustomTextField = {
                let textField = CustomTextField(placeholder: fieldType.rawValue)
                switch fieldType {
                case .email:
                    textField.keyboardType = .emailAddress
                case .password:
                    textField.isSecureTextEntry = true
                default:
                    break
                }
                textField.addTarget(self, action: #selector(handleTextField), for: .editingChanged)
                return textField
            }()
            return CustomContainerView(image: image, textField: signTextField)
        }
    }()

    private lazy var signStackView = UIStackView(arrangedSubviews: fieldDataView).then {
        $0.axis = .vertical
        $0.spacing = 8
        $0.alignment = .fill
        $0.distribution = .fillEqually
    }

    private lazy var signButton = UIButton(type: .custom).then {
        $0.setTitle("Sign In", for: .normal)
        $0.setTitleColor(.twitterBlue, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 16)
        $0.backgroundColor = .buttonColor
        $0.isEnabled = false
        $0.addTarget(self, action: #selector(handleSignButton), for: .touchUpInside)
        $0.layer.cornerRadius = 8
    }

    private lazy var loginButton = UIButton(type: .custom).then {
        $0.addTarget(self, action: #selector(handleLoginButton), for: .touchUpInside)
        $0.applyAttributedTitle(main: "계정이 있으신가요? ", sub: "로그인 하세요!", font: .boldSystemFont(ofSize: 16), textColor: .white)
    }


    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        ocnfigureUI()
        setup()
        configureConstraints()
        bindingViewModel()
    }


    // MARK: - Selectors

    @objc private func handleSignButton() {
        viewModel.register()
    }

    @objc private func handleLoginButton() {
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func handleAddProfileButton() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true)
    }

    @objc private func handleTextField(textField: UITextField) {
        viewModel.bindingTextField(textField: textField)
    }

    // MARK: - UI Configurations

    private func configureNavigationBar() {
        self.navigationController?.navigationBar.isHidden = true
    }

    private func ocnfigureUI() {
        self.view.backgroundColor = .twitterBlue
    }

    private func setup() {
        [addProfileButton, signStackView, signButton, loginButton].forEach({view.addSubview($0)})
    }

    private func configureConstraints() {
        addProfileButtonConstraints()
        signStackViewConstraints()
        signButtonConstraints()
        loginButtonConstraints()
    }

    private func addProfileButtonConstraints() {
        addProfileButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: nil, trailing: nil, bottom: nil, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 150, height: 150, centerX: view.centerXAnchor, centerY: nil)
    }

    private func signStackViewConstraints() {
        signStackView.anchor(top: addProfileButton.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, paddingTop: 40, paddingLeading: 40, paddingTrailing: 40, paddingBottom: 0, width: 0, height: 160, centerX: nil, centerY: nil)
    }

    private func signButtonConstraints() {
        signButton.anchor(top: signStackView.bottomAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: nil, paddingTop: 8, paddingLeading: 40, paddingTrailing: 40, paddingBottom: 0, width: 0, height: 40, centerX: nil, centerY: nil)
    }

    private func loginButtonConstraints() {
        loginButton.anchor(top: nil, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 39, centerX: view.centerXAnchor, centerY: nil)
    }

    // MARK: - Functions

    private func registerSuccess() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: - Bind ViewModels

    private func bindingViewModel() {
        viewModel.onProfileImage = { [weak self] profileImage in
            guard let self else { return }
            self.addProfileButton.setImage(profileImage, for: .normal)
            self.addProfileButton.clipsToBounds = true
            self.addProfileButton.layer.cornerRadius = addProfileButton.frame.height / 2
        }

        viewModel.onStatusButton = { [weak self] status, color in
            guard let self else { return }
            self.signButton.isEnabled = status
            self.signButton.backgroundColor = color
        }

        viewModel.onRegisterSuccess = { [weak self] in
            guard let self else { return }
        }

        viewModel.onRegisterFail = { [weak self] error in
            guard let self else { return }
        }
    }


}

extension RegisterViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[.editedImage] as? UIImage else { return }

        viewModel.bindProfileImage(profileImage: profileImage)

        self.dismiss(animated: true)
    }
}

extension RegisterViewController:
    UINavigationControllerDelegate {

}

#Preview {
    VCPreView {
        RegisterViewController()
    }.edgesIgnoringSafeArea(.all)
}
