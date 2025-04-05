//
//  NotificationCell.swift
//  Twitters
//
//  Created by 이준용 on 4/1/25.
//

import UIKit
import Then
import SDWebImage
import SnapKit


final class NotificationCell: UITableViewCell {

    var viewModel: NotificationCellViewModel? {
        didSet {
            bindViewModel()
        }
    }

    var didTapProfileImage: ((User) -> Void)?

    private func bindViewModel() {
        guard let viewModel else { return }

        viewModel.onUserFetched = { [weak self] in
            guard let self else { return  }
            profileImageView.sd_setImage(with: URL(string: viewModel.profileImageUrl))
            notificationLabel.text = viewModel.notificationText
            followButton.isHidden = viewModel.shuoldHideFollowButton
        }

        viewModel.onFollowButtonStatusUpadted = { [weak self] check in
            guard let self else { return }
            followButton.setTitle(check, for: .normal)
        }



    }

    private lazy var profileImageView = UIImageView().then {
        $0.backgroundColor = .twitterBlue

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTapped))
        tap.numberOfTapsRequired = 1
        $0.isUserInteractionEnabled = true
        $0.addGestureRecognizer(tap)
    }

    private let notificationLabel = UILabel().then {
        $0.text = "Some test notification message."
        $0.numberOfLines = 2
        $0.font = .systemFont(ofSize: 14)
    }

    private lazy var notificationStack = UIStackView(arrangedSubviews: [profileImageView, notificationLabel]).then {
        $0.axis = .horizontal
        $0.spacing = 8
        $0.alignment = .center
        $0.distribution = .fill
    }

    private lazy var followButton = UIButton(type: .custom).then {
        $0.setTitle("Loading", for: .normal)
        $0.setTitleColor(.twitterBlue, for: .normal)
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.twitterBlue.cgColor
        $0.layer.borderWidth = 2
        $0.addTarget(self, action: #selector(handleFollow), for: .touchUpInside)
    }

    @objc private func handleProfileImageTapped() {
        guard let user = viewModel?.user else { return }
        didTapProfileImage?(user)
    }

    @objc private func handleFollow() {
        viewModel?.followButtonTapped()
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .white
        setup()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    override func layoutSubviews() {
        super.layoutSubviews()


    }

    private func setup() {
        self.contentView.addSubview(notificationStack)
        self.contentView.addSubview(followButton)
    }

    private func configureConstraints() {
        profileImageView.snp.makeConstraints({
            $0.size.equalTo(48)
        })
        layoutIfNeeded()
        profileImageView.layer.cornerRadius = 24
        profileImageView.clipsToBounds = true
        notificationStack.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(contentView).inset(12)
            $0.trailing.equalTo(followButton.snp.leading).inset(12)
        })

        followButton.snp.makeConstraints({
            $0.centerY.equalToSuperview()
            $0.size.equalTo(CGSize(width: 100, height: 32))
            $0.trailing.equalTo(contentView).inset(12)
        })
        followButton.layer.cornerRadius = 32 / 2
        followButton.clipsToBounds = true
    }
}
