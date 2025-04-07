//
//  EditProfileController.swift
//  Twitters
//
//  Created by 이준용 on 4/7/25.
//

import UIKit

final class EditProfileController: UIViewController {

    // MARK: - Properties

    // MARK: - View Models

    // MARK: - UI Components

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }

    // MARK: - Selectors

    // MARK: - UI Configurations

    private func configureNavigationBar() {
        self.navigationItem.title = "Edit Profile"
    }

    private func configureUI() {
        self.view.backgroundColor = .white
    }


    // MARK: - Functions

    // MARK: - Bind ViewModels



}
