//
//  VCPreView.swift
//  Twitt
//
//  Created by 이준용 on 11/14/24.
//

import UIKit
import SwiftUI

struct VCPreView<T: UIViewController>: UIViewControllerRepresentable {
    let viewController: T

    init(_ builder: @escaping () -> T) {
        self.viewController = builder()
    }

    func makeUIViewController(context: Context) -> T {
        return viewController
    }

    func updateUIViewController(_ uiViewController: T, context: Context) {
        // 업데이트가 필요한 경우 추가 작업 수행
    }
}


