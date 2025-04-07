//
//  FeedController.swift
//  Twitters
//
//  Created by 이준용 on 2/24/25.
//

import UIKit
import SwiftUI
import Then
import SDWebImage

final class FeedController: UIViewController {

    // MARK: - Properties

    private let refreshControl = UIRefreshControl()

    // MARK: - View Models

    private let feedViewModel = FeedViewModel()
    private let userViewModel: UserViewModel

    // MARK: - UI Components

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    private let logoImageView = UIImageView().then {
        $0.image = .twitterLogoBlue
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private lazy var logoImageContainerView = UIView().then {
        $0.addSubview(logoImageView)
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    private let profileImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
    }

    private lazy var logoutButton = UIButton(type: .custom).then {
        $0.setTitle("Logout", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = .twitterBlue
        $0.titleLabel?.font = .boldSystemFont(ofSize: 14)
        $0.addTarget(self, action: #selector(handleLogoutButton), for: .touchUpInside)
    }



    // MARK: - Life Cycles

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    //    override func viewWillDisappear(_ animated: Bool) {
    //        super.viewWillDisappear(animated)
    //
    //        // 🔹 화면이 사라질 때 `collectionView`를 숨겨서 잔상 방지
    //        self.view.isHidden = true
    //    }
    //    override func viewDidDisappear(_ animated: Bool) {
    //        super.viewDidDisappear(animated)
    //
    //        // 🔹 화면이 완전히 사라지고 다시 돌아오면 `collectionView` 다시 보이게 설정
    //        self.view.isHidden = false
    //    }



    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefershControl()
        configureUI()
        configureNavigationBar()
        configureCollectionView()
        configureProfileImage()
        bindingViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        logoutButton.clipsToBounds = true
        logoutButton.layer.cornerRadius = logoutButton.frame.height / 2
    }

    init(userViewModel: UserViewModel) {
        self.userViewModel = userViewModel

        super.init(nibName: nil, bundle: nil)

    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Selectors

    @objc private func handleLogoutButton() {
        self.showLogoutAlert()
    }

    @objc private func handleRefresh() {
        collectionView.refreshControl?.beginRefreshing()
        feedViewModel.ServiceTweet()
    }

    // MARK: - UI Configurations
    private func configureUI() {
        self.view.backgroundColor = .brown
    }

    private func configureNavigationBar() {
        let apperance = UINavigationBarAppearance()
        self.navigationController?.navigationBar.scrollEdgeAppearance = apperance

        NSLayoutConstraint.activate([
            logoImageView.centerYAnchor.constraint(equalTo: logoImageContainerView.centerYAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: logoImageContainerView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 60),
            logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor),

            profileImageView.widthAnchor.constraint(equalToConstant: 32),
            profileImageView.heightAnchor.constraint(equalToConstant: 32),

            logoutButton.widthAnchor.constraint(equalToConstant: 64),
            logoutButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        self.navigationItem.titleView = logoImageContainerView
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: profileImageView)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: logoutButton)
    }

    private func configureCollectionView() {
        self.view.addSubview(collectionView)

        self.collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.collectionView.register(TweetCell.self, forCellWithReuseIdentifier: Cell.tweetCell)

    }

    private func configureProfileImage() {
        profileImageView.sd_setImage(with: self.userViewModel.profileImageUrl)
    }



    // MARK: - Functions

    private func configureRefershControl() {
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
    }

    private func showLogoutAlert() {
        let alertController = UIAlertController(title: "Logut", message: "로그아웃 하시겠습니까?", preferredStyle: .alert)
        let logout = UIAlertAction(title: "Logout", style: .destructive) {[weak self] _ in
            guard let self else { return }

            self.feedViewModel.logout()
        }
        let cancle = UIAlertAction(title: "Cancle", style: .cancel)
        alertController.addAction(logout)
        alertController.addAction(cancle)
        self.present(alertController, animated: true)
    }

    private func logoutSuccess() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let loginViewController = UINavigationController(rootViewController: LoginViewController())
            loginViewController.modalPresentationStyle = .fullScreen
            self.present(loginViewController, animated: true)
        }

    }

    // MARK: - Bind ViewModels

    private func bindingViewModel() {
        feedViewModel.onLogutSuccess = { [weak self]  in
            guard let self else { return }
            self.logoutSuccess()
        }

        feedViewModel.onDataUpdated = { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
        }
        feedViewModel.onRefreshControl = { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.collectionView.refreshControl?.endRefreshing()
            }
        }

        feedViewModel.ServiceTweet()


    }


}

extension FeedController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedViewModel.tweets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.tweetCell, for: indexPath) as? TweetCell else { return UICollectionViewCell() }

        let tweetViewModel = TweetViewModel(tweet: feedViewModel.tweets[indexPath.row], delegate: self)
        cell.viewModel = tweetViewModel

        cell.onHandleCommentTapped = { [weak self] type in
             guard let self else { return }

             let uploadTweetController = UploadTweetController(userViewModel: self.userViewModel)
             let nav = UINavigationController(rootViewController: uploadTweetController)

             // ✅ 중복 제거: UINavigationController만 설정하면 충분
             nav.modalPresentationStyle = .fullScreen
             uploadTweetController.viewModel = UploadTweetViewModel(configuration: type)

             self.present(nav, animated: true)
         }

        return cell
    }


}

extension FeedController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tweetController = TweetController(tweetViewModel: TweetViewModel(tweet: feedViewModel.tweets[indexPath.row]))

        self.navigationController?.pushViewController(tweetController, animated: true)
    }

}

extension FeedController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let tweet = feedViewModel.tweets[indexPath.row]
        let estimatedHeight = estimateCellHeight(for: tweet)
        return CGSize(width: collectionView.frame.width, height: estimatedHeight)
    }

    private func estimateCellHeight(for tweet: Tweet) -> CGFloat {
        let dummyCell = TweetCell()
        dummyCell.viewModel = TweetViewModel(tweet: tweet, delegate: self)
        dummyCell.layoutIfNeeded()

        let targetSize = CGSize(width: collectionView.frame.width, height: UIView.layoutFittingCompressedSize.height)

        let estimatedSize = dummyCell.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        return estimatedSize.height
    }




}

extension FeedController: TweetViewModelDelegate {
    func didTapProfileImage(userViewModel: UserViewModel) {
        let profileController = ProfileController(userViewModel: userViewModel)

        self.navigationController?.pushViewController(profileController, animated: true)
    }


}

#Preview {

    let userMockModel = UserViewModel(user: MockUserModel())


    VCPreView {
        UINavigationController(rootViewController: FeedController(userViewModel: userMockModel))
    }.edgesIgnoringSafeArea(.all)
}
