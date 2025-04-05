//
//  UserCell.swift
//  Twitters
//
//  Created by 이준용 on 2/28/25.
//

import UIKit
import Then
import SDWebImage
class UserCell: UITableViewCell {

    var viewModel: UserViewModel? {
        didSet {
            bindingViewModel()
        }
    }


    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.clipsToBounds = true
    }

    private let usernameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 14)
        $0.text = "Username"
    }

    private let fullnameLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 14)
        $0.text = "Fullname"
    }

    private lazy var labelStack = UIStackView(arrangedSubviews: [usernameLabel, fullnameLabel]).then {
        $0.axis = .vertical
        $0.spacing = 2
        $0.distribution = .fillEqually
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
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }

    private func setup() {
        self.addSubview(profileImageView)
        self.addSubview(labelStack)
    }

    private func configureConstraints() {
        profileImageViewConstraints()
        labelStackConstraints()
    }

    private func profileImageViewConstraints() {
        profileImageView.anchor(top: nil, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 0, paddingLeading: 16, paddingTrailing: 0, paddingBottom: 0, width: 32, height: 32, centerX: nil, centerY: centerYAnchor)
    }

    private func labelStackConstraints() {
        labelStack.anchor(top: nil, leading: profileImageView.trailingAnchor, trailing: nil, bottom: nil, paddingTop: 0, paddingLeading: 12, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: centerYAnchor)
    }

    private func bindingViewModel() {
        guard let viewModel else { return }
        profileImageView.sd_setImage(with: viewModel.profileImageUrl)
        usernameLabel.text = viewModel.username
        fullnameLabel.text = viewModel.fullname
    }

}
