//
//  ProfileController.swift
//  Twitters
//
//  Created by 이준용 on 2/26/25.
//

import UIKit
import Then
import SwiftUI

final class ProfileController: UIViewController {

    // MARK: - Properties

    // MARK: - View Models

    private let userViewModel: UserViewModel
    private let viewModel = ProfileViewModel()
    private var profileHeaderViewModel: ProfileHeaderViewModel?





    // MARK: - UI Components

//    private let collectionView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.sectionHeadersPinToVisibleBounds = true
//        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        return collectionView
//    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0


        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isPagingEnabled = true   // ✅ 페이징 활성화
        collectionView.showsHorizontalScrollIndicator = false

        return collectionView
    }()



    // MARK: - Life Cycles

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        self.navigationController?.navigationBar.isHidden = true

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()  // ✅ 강제 레이아웃 갱신
    }

    


    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileHeaderViewModel = ProfileHeaderViewModel(user: userViewModel.getUser(), delegate: nil)
        configureUI()
        configureCollectionView()
        bindViewModel()


    }


    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        self.view.backgroundColor = .white
    }



    private func configureCollectionView() {
        self.view.addSubview(collectionView)

        self.collectionView.anchor(top: view.topAnchor, leading: view.leadingAnchor, trailing: view.trailingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingTop: 0, paddingLeading: 00, paddingTrailing: 0, paddingBottom: 0, width: 0, height: 0, centerX: nil, centerY: nil)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)




        self.collectionView.register(TweetCell.self, forCellWithReuseIdentifier: Cell.tweetCell)
        self.collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Cell.profileHeader)

    }

    // MARK: - Functions

    // MARK: - Bind ViewModels

    private func bindViewModel() {
        viewModel.onFetchSelectedTweet = { [weak self] in
            guard let self else { return }
            self.collectionView.reloadData()
        }

        print(userViewModel.uid)

        viewModel.selectedFetchTweet(uid: userViewModel.uid)

        profileHeaderViewModel?.onBackButton = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        profileHeaderViewModel?.onEditFollowButton = {
            print("Edit Follow Button Clicked") // ✅ UI 업데이트 로직 추가 가능
        }

        profileHeaderViewModel?.onFollowSuccess = { [weak self] in
            guard let self else { return }
            print("✅ 팔로우/언팔로우 성공 컬렉션뷰 리로드")
            self.collectionView.reloadData()
        }
        // ✅ Follow/Unfollow 성공 및 실패 클로저 설정


        profileHeaderViewModel?.onFollowFail = { error in
            print("❌ Follow 실패: \(error.localizedDescription)")
        }


        profileHeaderViewModel?.onUnFollowFail = { error in
            print("❌ UnFollow 실패: \(error.localizedDescription)")
        }
    }
}



extension ProfileController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(viewModel.currentDataSource.count)
        return viewModel.currentDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.tweetCell, for: indexPath) as? TweetCell else { return UICollectionViewCell()}
        cell.viewModel = TweetViewModel(tweet: viewModel.currentDataSource[indexPath.row], delegate: self)

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

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Cell.profileHeader, for: indexPath) as? ProfileHeader else {
            return UICollectionReusableView()
        }
        // ✅ 기존 ViewModel이 있으면 재사용, 없으면 새로 생성
        guard let profileHeaderViewModel else { return UICollectionReusableView()}
        header.delegate = self
        header.viewModel = profileHeaderViewModel
        header.onEditProfileButtonTap = {[weak self] in
            guard let self else { return }
            let editProfileController = EditProfileController()
            self.navigationController?.pushViewController(editProfileController, animated: true)
        }


        return header
    }






}


extension ProfileController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {


        let tweetViewModel = TweetViewModel(tweet: viewModel.currentDataSource[indexPath.row])

        let tweetController = TweetController(tweetViewModel: tweetViewModel)
        self.navigationController?.pushViewController(tweetController, animated: true)
    }
}

extension ProfileController: UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = collectionView.frame.width
        return CGSize(width: width, height: estimatedHeight(isHeader: true))
    }

    

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = collectionView.frame.width
        let tweet = viewModel.currentDataSource[indexPath.row]

        print(estimatedHeight(tweet: tweet, isHeader: false))

        return CGSize(width: width, height: estimatedHeight(tweet: tweet, isHeader: false))
    }

    private func estimatedHeight(tweet: Tweet? = nil, isHeader: Bool) -> CGFloat {
        let dummy: UIView

        if isHeader {
            let dummyHeader = ProfileHeader()
            dummyHeader.viewModel = profileHeaderViewModel

            dummyHeader.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
            dummyHeader.layoutIfNeeded()
            dummy = dummyHeader
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

extension ProfileController: ProfileFilterViewDelegate {
    func filterView(view: ProfileFilterView, indexPath: Int) {

    }
    
    func filterView(view: ProfileFilterView, didSelect filter: FilterOption) {
        viewModel.selectedFilter = filter
        viewModel.selectedFetchTweet(uid: userViewModel.uid)
        print("DD \(viewModel.selectedFilter)")
    }
    

}

extension ProfileController: TweetViewModelDelegate {
    func didTapProfileImage(userViewModel: UserViewModel) {
        let profileController = ProfileController(userViewModel: userViewModel)
        self.navigationController?.pushViewController(profileController, animated: true)
    }
    

}



#Preview {

    let mockUserModel = UserViewModel(user: MockUserModel())

    VCPreView {
        UINavigationController(rootViewController: ProfileController(userViewModel: mockUserModel))
    }.edgesIgnoringSafeArea(.all)
}
