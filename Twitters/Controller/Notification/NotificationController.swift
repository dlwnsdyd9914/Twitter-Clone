//
//  NotificationController.swift
//  Twitters
//
//  Created by 이준용 on 2/24/25.
//

import UIKit
import SwiftUI
import Then
import SnapKit

final class NotificationController: UIViewController {

    // MARK: - Properties
    let refershControl = UIRefreshControl()

    // MARK: - View Models

    private let viewModel = NotificationViewModel()

    // MARK: - UI Components

    private let tableView = UITableView(frame: .zero, style: .plain)

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureTableView()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false

        self.navigationController?.navigationBar.barStyle = .default

    }



    // MARK: - Selectors

    @objc private func handleRefresh() {
        print("DEBUG: Wants to refresh..")

        

        viewModel.fetchNotificationAll()

        refershControl.endRefreshing()

    }

    // MARK: - UI Configurations

    private func configureNavigationBar() {
        self.navigationItem.title = "Notification"
    }

    private func configureUI() {
        self.view.backgroundColor = .white
        tableView.refreshControl = refershControl
        refershControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
    }

    private func configureTableView() {
        self.view.addSubview(tableView)

        self.tableView.snp.makeConstraints({
            $0.edges.equalToSuperview()
        })
        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.rowHeight = 60
        self.tableView.separatorStyle = .none

        self.tableView.register(NotificationCell.self, forCellReuseIdentifier: Cell.notificationCell)
    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

    private func bindViewModel() {
        viewModel.onFetchNotification = {[weak self] in
            guard let self else { return }
            self.tableView.reloadData()
        }
    }


}

extension NotificationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notification.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Cell.notificationCell, for: indexPath) as? NotificationCell else {
            return UITableViewCell()
        }
        viewModel.indexPathRow = indexPath.row
        cell.selectionStyle = .none
        cell.viewModel = NotificationCellViewModel(notification: viewModel.notification[indexPath.row])

        cell.didTapProfileImage = {[weak self] user in
            guard let self else { return }
            let userViewModel = UserViewModel(user: user)

            DispatchQueue.main.async {
                let profileController = ProfileController(userViewModel: userViewModel)
                self.navigationController?.pushViewController(profileController, animated: true)
            }
        }
        return cell
    }
}

extension NotificationController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = viewModel.notification[indexPath.row]
        guard let type = notification.type else {
            print("❌ 알림 타입 없음")
            return
        }

        switch type {
        case .like, .reply, .retweet:
            let tweetID = notification.tweetID
            guard !tweetID.isEmpty else {
                print("❌ tweetID 없음 — 트윗 관련 알림 아님")
                return
            }

            viewModel.fetchTweet(tweetId: tweetID) { [weak self] tweet in
                let tweetViewModel = TweetViewModel(tweet: tweet)
                let tweetController = TweetController(tweetViewModel: tweetViewModel)
                DispatchQueue.main.async {
                    self?.navigationController?.pushViewController(tweetController, animated: true)
                }
            }

        case .follow, .mention:
            let uid = notification.uid
            UserService.shared.getUser(uid: uid) { [weak self] user in
                guard let self else { return }
                let userViewModel = UserViewModel(user: user)
                let profileController = ProfileController(userViewModel: userViewModel)
                DispatchQueue.main.async {
                    self.navigationController?.pushViewController(profileController, animated: true)
                }
            }
        }
    }

}

#Preview {
    VCPreView {
        UINavigationController(rootViewController: NotificationController())
    }.edgesIgnoringSafeArea(.all)
}
