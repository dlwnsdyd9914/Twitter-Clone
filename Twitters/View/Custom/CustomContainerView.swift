//
//  CustomContainerView.swift
//  Twitters
//
//  Created by 이준용 on 2/16/25.
//

import UIKit

final class CustomContainerView: UIView {

    init(image: UIImage, textField: UITextField) {
        super.init(frame: .zero)


        let imageView = UIImageView()
        imageView.image = image
        imageView.tintColor = .white

        let dividierView = UIView()
        dividierView.backgroundColor = .white

        self.addSubview(imageView)
        self.addSubview(textField)
        self.addSubview(dividierView)

        imageView.anchor(top: nil, leading: leadingAnchor, trailing: nil, bottom: nil, paddingTop: 0, paddingLeading: 8, paddingTrailing: 0, paddingBottom: 0, width: 24, height: 24, centerX: nil, centerY: centerYAnchor)
        textField.anchor(top: nil, leading: imageView.trailingAnchor, trailing: trailingAnchor, bottom: nil, paddingTop: 0, paddingLeading: 8, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: centerYAnchor)
        dividierView.anchor(top: nil, leading: leadingAnchor, trailing: trailingAnchor, bottom: bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 1, centerX: nil, centerY: nil)

    }


    required init?(coder: NSCoder) {
        fatalError("")
    }
}
