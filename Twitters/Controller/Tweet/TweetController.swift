//
//  TweetController.swift
//  Twitters
//
//  Created by 이준용 on 3/6/25.
//

import UIKit
import Then
import SwiftUI

final class TweetController: UIViewController {

    // MARK: - Properties


    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()

    // MARK: - View Models

    let tweetViewModel: TweetViewModel

    // MARK: - UI Components

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureCollectionView()
        bindViewModel()
    }

    init(tweetViewModel: TweetViewModel) {
        self.tweetViewModel = tweetViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("")
    }

    // MARK: - Selectors

    // MARK: - UI Configurations

    private func configureNavigationBar() {
        let apperance = UINavigationBarAppearance()
        self.navigationController?.navigationBar.scrollEdgeAppearance = apperance

        self.navigationItem.title = "Tweet"
    }

    private func configureUI() {
        self.view.backgroundColor = .brown
    }

    private func configureCollectionView() {
        self.view.addSubview(collectionView)

        self.collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.bottomAnchor, paddingTop: 0, paddingLeading: 0, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self

        self.collectionView.register(TweetCell.self, forCellWithReuseIdentifier: Cell.tweetCell)
        self.collectionView.register(TweetHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Cell.tweetHeader)
        
    }



    // MARK: - Functions

    // MARK: - Bind ViewModels

    private func bindViewModel() {
        tweetViewModel.fetchReplies()

        tweetViewModel.onSuccessReplies = { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
        }

        tweetViewModel.onLikeService = { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
        }
    }




}

extension TweetController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweetViewModel.tweetReplies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.tweetCell, for: indexPath) as? TweetCell else { return UICollectionViewCell()
        }
        cell.viewModel = TweetViewModel(tweet: tweetViewModel.tweetReplies[indexPath.row])

        cell.onHandleCommentTapped = { [weak self] type in
            guard let self else { return }
            let userViewModel = UserViewModel(user: tweetViewModel.user)
            let uploadTweetController = UploadTweetController(userViewModel: userViewModel)
            uploadTweetController.viewModel = UploadTweetViewModel(configuration: type)
            let nav = UINavigationController(rootViewController: uploadTweetController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cell.tweetHeader, for: indexPath) as? TweetHeader else {
            return UICollectionReusableView()
        }
        header.viewModel = TweetHeaderViewModel(tweet: tweetViewModel.getTweet())

        guard let headerViewModel = header.viewModel else { return header }

        let userViewModel = UserViewModel(user: headerViewModel.getUser())

        header.onShowAlert = { [weak self] in
            guard let self = self else { return }

            let alertVM = ActionSheetViewModel(userviewModel: userViewModel)
            let alert = CustomAlertController(viewModel: alertVM)
            alert.modalPresentationStyle = .overFullScreen
            alert.modalTransitionStyle = .crossDissolve
            self.present(alert, animated: true)
        }
//
//        header.onShowAlert = { [weak self] in
//            guard let self = self else { return }
//
//            userViewModel.onFollowStatusCheck = { [weak self] in
//                guard let self = self else { return }
//
//                // 옵저버 제거 (중복 방지)
//                userViewModel.onFollowStatusCheck = nil
//
//                let alertVM = ActionSheetViewModel(userviewModel: userViewModel)
//                let alert = CustomAlertController(viewModel: alertVM)
//                alert.modalPresentationStyle = .overFullScreen
//                alert.modalTransitionStyle = .crossDissolve
//                self.present(alert, animated: true)
//            }
//
//            userViewModel.checkingFollow() // 비동기 호출
//        }



        return header
    }
}

extension TweetController: UICollectionViewDelegate {

}

extension TweetController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        let width = collectionView.frame.width

        return CGSize(width: width, height: estimatedHeight(tweet: tweetViewModel.getTweet(), isHeader: true))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width

        let tweet = tweetViewModel.tweetReplies[indexPath.row]




        return CGSize(width: width, height: estimatedHeight(tweet: tweet, isHeader: false))
    }

    private func estimatedHeight(tweet: TweetModelProtocol? = nil, isHeader: Bool) -> CGFloat {
        var dummy: UIView // ✅ 옵셔널이 아닌 기본값 설정

        if isHeader {
            let dummyHeader = TweetHeader()

            if let tweet = tweet {
                dummyHeader.viewModel = TweetHeaderViewModel(tweet: tweet)
            }

            // 🔥 프레임 설정 추가 (필수)
            dummyHeader.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 0)
            dummyHeader.layoutIfNeeded()

            dummy = dummyHeader  // ✅ 이제 여기서 초기화되지 않아도 기본값 설정이 되어 있음

        } else {
            let dummyCell = TweetCell()
            dummyCell.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: 1000)

            if let tweet = tweet {
                dummyCell.viewModel = TweetViewModel(tweet: tweet)
            }


            dummyCell.layoutIfNeeded()
            dummy = dummyCell.contentView
        }

        let targetSize = CGSize(
            width: collectionView.frame.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        var estimatedSize = dummy.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        if isHeader {
            estimatedSize.height = max(estimatedSize.height, 200) // 🔥 최소 높이 설정
        }

        return estimatedSize.height
    }

}

#Preview {
    let user = MockUserModel()

    let mockTweetModel = MockTweetModel(isRely: false, didLike: true, caption: "caption", tweetId: "TweetId", user: User(uid: "uidTest", dictionary: ["d": "d"]), lieks: 1, retweets: 2, timeStamp: .now, uid: "TestUId")


    VCPreView {
        UINavigationController(rootViewController: TweetController(tweetViewModel: TweetViewModel(tweet: mockTweetModel)))
    }.edgesIgnoringSafeArea(.all)
}
