//
//  ExplorerController.swift
//  Twitters
//
//  Created by 이준용 on 2/24/25.
//

import UIKit
import Then
import SwiftUI

final class ExplorerController: UIViewController {


    // MARK: - Properties
    private let tableView = UITableView(frame: .zero, style: .plain)


    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - View Models

    private let viewModel = ExplorerViewModel()
    private let userViewModel: UserViewModel

    // MARK: - UI Components

    // MARK: - Life Cycles

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureNavigationBar()
        configureTableView()
        configureSarchController()
        bindingViewModel()
    }

    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Selectors

    // MARK: - UI Configurations
    private func configureUI() {
        self.view.backgroundColor = .brown
    }

    private func configureNavigationBar() {
        let apperacne = UINavigationBarAppearance()
        self.navigationController?.navigationBar.scrollEdgeAppearance = apperacne
        self.navigationItem.title = "Explorer"
    }

    private func configureTableView() {
        self.view.addSubview(tableView)

        self.tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.rowHeight = 60
        self.tableView.separatorStyle = .none


        self.tableView.register(UserCell.self, forCellReuseIdentifier: Cell.userCell)
    }

    private func configureSarchController() {
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false
        searchController.searchResultsUpdater = self
    }

    // MARK: - Functions



    // MARK: - Bind ViewModels

    private func bindingViewModel() {
        viewModel.onFetchUserList = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
        }

        viewModel.onFilterUserList = { [weak self] in
            guard let self else { return }
            self.tableView.reloadData()
        }

        viewModel.fetchList()
    }

}

extension ExplorerController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.inSeaerchMode ? viewModel.filterUserList.count : viewModel.userList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.userCell, for: indexPath) as? UserCell else { return UITableViewCell()}
        cell.selectionStyle = .none
        let userViewModel = UserViewModel(user: viewModel.inSeaerchMode ? viewModel.filterUserList[indexPath.row] : viewModel.userList[indexPath.row])
        cell.viewModel = userViewModel
        return cell
    }
}

extension ExplorerController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userViewModel = UserViewModel(user: viewModel.inSeaerchMode ? viewModel.filterUserList[indexPath.row] : viewModel.userList[indexPath.row])
        let profileController = ProfileController(userViewModel: userViewModel)
        self.navigationController?.pushViewController(profileController, animated: true)
    }
}

extension ExplorerController: UISearchControllerDelegate {
    func didPresentSearchController(_ searchController: UISearchController) {
        viewModel.isActive = searchController.isActive
    }
    func didDismissSearchController(_ searchController: UISearchController) {
        viewModel.isActive = searchController.isActive
    }

}

extension ExplorerController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.bindText(text: searchText)
        if searchText.isEmpty == false {
            viewModel.isActive = true  // ✅ 검색어가 입력되면 다시 활성화
        }

        print("DEBUG: Search text is \(String(describing: viewModel.searchText))")
        self.tableView.reloadData()
    }

}

#Preview {

    let mockUserData = UserViewModel(user: MockUserModel())

    VCPreView {
        UINavigationController(rootViewController: ExplorerController(userViewModel: mockUserData))
    }.edgesIgnoringSafeArea(.all)
}


