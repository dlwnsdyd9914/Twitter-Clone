//
//  ConversationController.swift
//  Twitters
//
//  Created by 이준용 on 2/24/25.
//

import UIKit

final class ConversationController: UIViewController {

    // MARK: - Properties

    // MARK: - View Models

    // MARK: - UI Components

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigatinBar()
        configureUI()
    }

    // MARK: - Selectors

    // MARK: - UI Configurations

    private func configureNavigatinBar() {
        self.navigationItem.title = "Conversation"
    }

    private func configureUI() {
        self.view.backgroundColor = .white
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels


}
