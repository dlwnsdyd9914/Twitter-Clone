//
//  UploadTweetController.swift
//  Twitters
//
//  Created by 이준용 on 2/24/25.
//

import UIKit
import Then
import SwiftUI
class UploadTweetController: UIViewController {

    // MARK: - Properties

    // MARK: - View Models
    private var userViewModel: UserViewModel
    var viewModel = UploadTweetViewModel(configuration: .tweet)

    // MARK: - UI Components

    private lazy var cancleButton = UIButton(type: .custom).then {
        $0.setTitle("Cancle", for: .normal)
        $0.setTitleColor(.twitterBlue, for: .normal)
        $0.titleLabel?.font = .systemFont(ofSize: 14)
        $0.addTarget(self, action: #selector(handleCancleButton), for: .touchUpInside)
    }

    private lazy var uploadTweetButton = UIButton(type: .custom).then {
        $0.setTitle(viewModel.actionButtonTitle, for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        $0.backgroundColor = .twitterBlue
        $0.addTarget(self, action: #selector(handleUploadTweet), for: .touchUpInside)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let profileImageView = UIImageView().then { imageView in
        imageView.backgroundColor = .lightGray
    }

    private lazy var captionTextView = CustomTextView().then {
        $0.backgroundColor = .white
    }

    private let replyLable = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "Reply"
        $0.textColor = .lightGray
    }


    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        captionTextView.delegate = self
        configureUI()
        navigationBarSetting()
        configureNavigationBar()
        setup()
        configureConstraints()
        configureProfileImageView()
        bindingViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        uploadTweetButton.clipsToBounds = true
        uploadTweetButton.layer.cornerRadius = uploadTweetButton.frame.height / 2
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }

    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Selectors

    @objc private func handleCancleButton() {
        self.dismiss(animated: true)
    }

    @objc private func handleUploadTweet() {
        viewModel.uploadtweet()
    }

    // MARK: - UI Configurations
    private func configureUI() {
        self.view.backgroundColor = .white
    }

    private func configureNavigationBar() {

        NSLayoutConstraint.activate([
            uploadTweetButton.widthAnchor.constraint(equalToConstant: 64),
            uploadTweetButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: cancleButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: uploadTweetButton)
    }

    private func setup() {
        self.view.addSubview(profileImageView)
        self.view.addSubview(captionTextView)
        self.view.addSubview(replyLable)
    }

    private func configureConstraints() {
        profileImageView.anchor(top: replyLable.bottomAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, paddingTop: 16, paddingLeading: 16, paddingTrailing: 0, paddingBottom: 0, width: 48, height: 48, centerX: nil, centerY: nil)
        captionTextView.anchor(top: nil, leading: profileImageView.trailingAnchor, trailing: view.trailingAnchor, bottom: nil, paddingTop: 16, paddingLeading: 16, paddingTrailing: 16, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: profileImageView.centerYAnchor)
        replyLable.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, trailing: nil, bottom: nil, paddingTop: 16, paddingLeading: 16, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    private func configureProfileImageView() {
        profileImageView.sd_setImage(with: self.userViewModel.profileImageUrl)
    }



    // MARK: - Functions

    private func tweetUploadSuccess() {
        self.dismiss(animated: true)
    }

    // MARK: - Bind ViewModels
    private func bindingViewModel() {
        viewModel.onTweetUploadSuccess = { [weak self] in
            guard let self else { return }
            self.tweetUploadSuccess()
        }

        replyLable.isHidden = !viewModel.shouldShowReplyLabel
        replyLable.text = viewModel.replyText
    }



}

extension UploadTweetController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.bindCaption(caption: textView.text)
    }
}

#Preview {

    let mockUserModel = UserViewModel(user: MockUserModel())

    VCPreView {
        UINavigationController(rootViewController: UploadTweetController(userViewModel: mockUserModel))
    }.edgesIgnoringSafeArea(.all)
}
