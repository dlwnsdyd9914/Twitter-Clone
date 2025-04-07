//
//  ProfileHeader.swift
//  Twitters
//
//  Created by 이준용 on 2/26/25.
//

import UIKit
import Then
import SwiftUI
import SDWebImage

class ProfileHeader: UICollectionReusableView {

    var viewModel: ProfileHeaderViewModel? {
        didSet {
            viewModelBinding()
        }
    }

    private let filterBar = ProfileFilterView()

    weak var delegate: ProfileFilterViewDelegate? {
            didSet {
                filterBar.delegate = delegate // ✅ delegate 연결 전달
            }
        }

    private lazy var backButton = UIButton(type: .custom).then {
        $0.setImage(.backImage.withRenderingMode(.alwaysOriginal), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(handleBackButton), for: .touchUpInside)
    }

    private let containerView = UIView().then {
        $0.backgroundColor = .twitterBlue
    }

    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .lightGray
        $0.layer.borderColor = UIColor.white.cgColor
        $0.layer.borderWidth = 4
    }

    private lazy var editFollowButton = UIButton(type: .custom).then {
        $0.setTitle("Loding", for: .normal)
        $0.layer.borderColor = UIColor.twitterBlue.cgColor
        $0.layer.borderWidth = 1.25
        $0.setTitleColor(.twitterBlue, for: .normal)
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        $0.addTarget(self, action: #selector(handleEditFollowButton), for: .touchUpInside)
    }

    private let fullnameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.text = "Fullname"
    }

    private let usernameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.text = "Username"
        $0.textColor = .lightGray
    }

    private let bioLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
        $0.text = "TestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestTestT"

        $0.lineBreakMode = .byWordWrapping
    }

    private lazy var userDetailStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel, bioLabel]).then {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.spacing = 4
    }



    private lazy var followingLabel = UILabel().then {
        $0.text = "0 following"

        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowing))
        followTap.numberOfTapsRequired = 1
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(followTap)
    }

    private lazy var follwerLabel = UILabel().then {
        $0.text = "0 follwers"

        let followTap = UITapGestureRecognizer(target: self, action: #selector(handleFollwer))
        followTap.numberOfTapsRequired = 1
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(followTap)
    }

    private lazy var followStack = UIStackView(arrangedSubviews: [followingLabel, follwerLabel]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.distribution = .fillEqually
    }

    var onEditProfileButtonTap: (() -> Void)?



    @objc private func handleBackButton() {
        viewModel?.handleBackButton()
    }

    @objc private func handleEditFollowButton() {
        guard let viewModel else { return }
        viewModel.handleEditFollowButton()
    }

    @objc private func handleFollowing() {
        guard let viewModel else { return }

        viewModel.handleFollowing()
    }

    @objc private func handleFollwer() {
        guard let viewModel else { return }

        viewModel.handleFollower()
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        filterBar.delegate = self
        self.backgroundColor = .white
        setup()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }



    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        editFollowButton.clipsToBounds = true
        editFollowButton.layer.cornerRadius = editFollowButton.frame.height / 2



        
    }



    private func setup() {
        [backButton, containerView, profileImageView, editFollowButton, userDetailStack, filterBar, followStack].forEach { add in
            self.addSubview(add)
        }
        bringSubviewToFront(backButton)
    }

    private func configureConstraints() {
        backButtonConstraints()
        containerViewConstraints()
        profileImageViewConstraints()
        editFollowButtonConstraints()
        userDetailStackConstraints()
        filterBarConstraints()

        followStackConstraints()
    }

    private func backButtonConstraints() {
        backButton.anchor(top: topAnchor, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 42, paddingLeading: 16, paddingTrailing: 0, paddingBottom: 0, width: 30, height: 30, centerX: nil, centerY: nil)
    }

    private func containerViewConstraints() {
        containerView.anchor(top: topAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: nil, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 108, centerX: nil, centerY: nil)
    }

    private func profileImageViewConstraints() {
        profileImageView.anchor(top: containerView.bottomAnchor, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: -24, paddingLeading: 8, paddingTrailing: 0, paddingBottom: 0, width: 80, height: 80, centerX: nil, centerY: nil)
    }

    private func editFollowButtonConstraints() {
        editFollowButton.anchor(top: containerView.bottomAnchor, leading: nil, trailing: trailingAnchor, bottom: nil, paddingTop: 12, paddingLeading: 0, paddingTrailing: 12, paddingBottom: 0, width: 100, height: 36, centerX:  nil, centerY: nil)
    }

    private func userDetailStackConstraints() {
        userDetailStack.anchor(top: profileImageView.bottomAnchor, leading: leadingAnchor, trailing: trailingAnchor, bottom: followStack.topAnchor, paddingTop: 8, paddingLeading: 12, paddingTrailing: 12, paddingBottom: 8, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    private func filterBarConstraints() {
        filterBar.anchor(top: nil, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 50, centerX: nil, centerY: nil)
    }

//    private func underLineViewConstraints() {
//        underLineView.anchor(top: nil, leading: leadingAnchor, trailing: nil, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: frame.width / 3, height: 2, centerX: nil, centerY: nil)
//    }

    private func followStackConstraints() {
        followStack.anchor(top: userDetailStack.bottomAnchor, leading: leadingAnchor, trailing: nil, bottom: filterBar.topAnchor, paddingTop: 8, paddingLeading: 12, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)
    }

    private func updateFollowButton(status: String) {
        self.editFollowButton.setTitle(status, for: .normal)
    }


    private func viewModelBinding() {
        guard let viewModel else { return }
        followingLabel.attributedText = viewModel.followingString
        follwerLabel.attributedText = viewModel.followerString
        usernameLabel.text = viewModel.username
        fullnameLabel.text = viewModel.fullname
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        editFollowButton.setTitle(viewModel.actionButtonTitle, for: .normal)


        viewModel.onFollowStateChagned = {[weak self] status in
            guard let self else { return }
            self.updateFollowButton(status: status)
        }

        viewModel.onFollowStatusCheck = {[weak self] check in
            guard let self else { return }

            if viewModel.getUser().isCurrentUser {
                self.editFollowButton.setTitle("Edit Profile", for: .normal)
            } else {
                self.updateFollowButton(status: check)
            }
        }

        viewModel.onFollowLabelStatus = {[weak self] in
            guard let self else { return }

            self.followingLabel.attributedText = viewModel.followingString
            self.follwerLabel.attributedText = viewModel.followerString
        }

        viewModel.onEditProfile = {[weak self] in
            guard let self else { return }
            self.onEditProfileButtonTap?()
        }

        viewModel.checkingFollow()
        viewModel.getFollowCount()


    }
}


extension ProfileHeader: ProfileFilterViewDelegate {
    func filterView(view: ProfileFilterView, didSelect filter: FilterOption) {
        
    }
    
    func filterView(view: ProfileFilterView, indexPath: Int) {
    }
    

}
