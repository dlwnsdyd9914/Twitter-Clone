//
//  ExplorerCell.swift
//  Twitters
//
//  Created by 이준용 on 2/28/25.
//

import UIKit
import Then

final class ExplorerCell: UITableViewCell {

    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.clipsToBounds = true
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        configureUI()
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    private func configureUI() {
        self.backgroundColor = .white
    }

    private func setup() {
        addSubview(profileImageView)
    }

}
