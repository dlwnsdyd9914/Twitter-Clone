//
//  ProfileCell.swift
//  Twitters
//
//  Created by 이준용 on 2/26/25.
//

import UIKit

class ProfileCell: UICollectionViewCell {

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    private func configureUI() {
        self.backgroundColor = .red
    }
}
