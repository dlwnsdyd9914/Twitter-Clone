//
//  CustomContainerTextField.swift
//  Twitters
//
//  Created by 이준용 on 1/31/25.
//

import UIKit

class CustomContainerTextField: UITextField {

    init(placeholder: String) {
        super.init(frame: .zero)

        let placeholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor : UIColor.white])
        self.attributedPlaceholder = placeholder

        self.font = .boldSystemFont(ofSize: 16)
        self.textColor = .white
        self.autocapitalizationType = .none
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }



}
