//
//  CustomTextField.swift
//  Twitters
//
//  Created by 이준용 on 2/16/25.
//

import UIKit

final class CustomTextField: UITextField {

    init(placeholder: String) {
        super.init(frame: .zero)

        let attributedPlaceholer = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        self.attributedPlaceholder = attributedPlaceholer
        self.font = .boldSystemFont(ofSize: 16)
        self.textColor = .white
        self.autocapitalizationType = .none
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }


}
