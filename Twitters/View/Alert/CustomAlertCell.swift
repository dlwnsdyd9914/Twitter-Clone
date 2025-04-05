//
//  CustomAlertCell.swift
//  Twitters
//
//  Created by 이준용 on 3/27/25.
//

import UIKit
import Then

class CustomAlertCell: UITableViewCell {

    func configure(with option: ActionSheetOptions) {
        titleLabel.text = option.description
    }

    private let optionImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
        $0.image = .twitterLogoBlue
    }

    private let titleLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 18)
        $0.text = "Test Option"
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = .white
        setup()
        configureConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }
 
    private func setup() {
        [optionImageView, titleLabel].forEach({contentView.addSubview($0)})
    }

    private func configureConstraints() {
        optionImageView.anchor(top: nil, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 0, paddingLeading: 8, paddingTrailing: 0, paddingBottom: 0, width: 36, height: 36, centerX: nil, centerY: centerYAnchor)
        titleLabel.anchor(top: nil, leading: optionImageView.trailingAnchor, trailing: nil, bottom: nil, paddingTop: 0, paddingLeading: 12, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: centerYAnchor)
    }

}
