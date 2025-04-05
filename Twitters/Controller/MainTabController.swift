//
//  MainTabController.swift
//  Twitters
//
//  Created by 이준용 on 2/24/25.
//

import UIKit
import Firebase
import Then
import SwiftUI

final class MainTabController: UITabBarController {

    // MARK: - Properties

    // MARK: - View Models
    private let viewModel = MainTabViewModel()
    private var userViewModel: UserViewModel?

    // MARK: - UI Components

    private lazy var newTweetButton = UIButton(type: .custom).then {
        $0.setImage(.newTweet.withRenderingMode(.alwaysTemplate), for: .normal)
        $0.backgroundColor = .twitterBlue
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(handleNewTweetButton), for: .touchUpInside)
    }

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureTabbar()
        setup()
        configureConstraints()
        checkingLogin()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        newTweetButton.clipsToBounds = true
        newTweetButton.layer.cornerRadius = newTweetButton.frame.height / 2
    }

    // MARK: - Selectors

    @objc private func handleNewTweetButton() {

        guard let userViewModel else { return }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            let uploadTweetController = UINavigationController(rootViewController: UploadTweetController(userViewModel: userViewModel))
            uploadTweetController.modalPresentationStyle = .fullScreen
            self.present(uploadTweetController, animated: true)

        }
    }

    // MARK: - UI Configurations

    private func configureUI() {
        self.view.backgroundColor = .white
    }

    private func configureTabbar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        self.tabBar.standardAppearance = appearance
        self.tabBar.scrollEdgeAppearance = appearance
    }


    private func constructTabController(image: UIImage, viewController: UIViewController) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.tabBarItem.image = image
        return navigationController
    }

    private func makeTabbar() {

        guard let userViewModel else { return }

        let tabs: [(UIImage, UIViewController)] = [
            (UIImage.feedImage, FeedController(userViewModel: userViewModel)),
            (UIImage.searchImage, ExplorerController(userViewModel: userViewModel)),
            (UIImage.like, NotificationController()),
            (UIImage.emailImage, ConversationController())
        ]

        viewControllers = tabs.map({self.constructTabController(image: $0, viewController: $1)})
    }

    private func setup() {
        self.view.addSubview(newTweetButton)
    }

    private func configureConstraints() {
        newTweetButton.anchor(top: nil, leading: nil, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 16, paddingBottom: 64, width: 64, height: 64, centerX: nil, centerY: nil)
    }


    // MARK: - Functions

    private func checkingLogin() {
        if Auth.auth().currentUser != nil {
            print("✅로그인 상태!")
            bindingViewModel()
        } else {
            print("❗️로그아웃 상태!")
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let loginViewController = UINavigationController(rootViewController: LoginViewController())
                loginViewController.modalPresentationStyle = .fullScreen
                self.present(loginViewController, animated: true)
            }
        }
    }

    // MARK: - Bind ViewModels

    private func bindingViewModel() {
        viewModel.onFetchUser = { [weak self] user in
            guard let self else { return }

            DispatchQueue.main.async {
                self.userViewModel = UserViewModel(user: user)
                print("✅ UserViewModel 업데이트 됨: \(String(describing: self.userViewModel?.getUser()))")

                if self.viewControllers?.isEmpty ?? true {
                    self.makeTabbar()
                }
            }
        }

        viewModel.fetchUser()
    }


}

#Preview {
    VCPreView {
        MainTabController()
    }.edgesIgnoringSafeArea(.all)
}
