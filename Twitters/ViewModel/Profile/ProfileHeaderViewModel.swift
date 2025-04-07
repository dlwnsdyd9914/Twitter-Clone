//
//  ProfileHeaderViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/26/25.
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func handleBackButton()
    func handleEditFollowButton(viewModel: ProfileHeaderViewModel)
    func handleFollowing(viewModel: ProfileHeaderViewModel)
    func handleFollwer(viewModel: ProfileHeaderViewModel)
}

class ProfileHeaderViewModel: ProfileHeaderViewModelProtocol {

    private var user: UserModelProtocol


    var followerString: NSAttributedString {
        return followAttributedText(value: user.userFollowerCount, text: "follwer")
    }

    var followingString: NSAttributedString {
        return followAttributedText(value: user.userFollowingCount, text: "following")
    }

    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)
    }

    var infoText: NSAttributedString {
        let title = NSMutableAttributedString(string: user.fullName , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(user.userName )", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                                                                                          NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return title
    }

    var actionButtonTitle: String {
        if user.isCurrentUser {
            return "Edit Profile"
        } else {
            return didFollow ? "Following" : "Follow"
        }
    }

    var fullname: String {
        return user.fullName
    }

    var username: String {
        return user.userName
    }

    var uid: String {
        return user.uid
    }

    var didFollow: Bool {
        get {
            return user.didFollow
        }
        set {
            user.didFollow = newValue
        }
    }

    func getUser() -> UserModelProtocol {
        return user
    }

    func followAttributedText(value: Int, text: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value) ", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: text, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return attributedText
    }

    var onBackButton: (() -> Void)?
    var onEditFollowButton: (() -> Void)?
    var onFollowing: (() -> Void)?
    var onFollower: (() -> Void)?


    weak var delegate: ProfileHeaderDelegate?

    init(user: UserModelProtocol, delegate: ProfileHeaderDelegate? = nil) {
        self.user = user
        self.delegate = delegate
        
    }

    func handleBackButton() {
        onBackButton?()
    }

    func handleEditFollowButton() {
        followToggle()
    }

    func handleFollowing() {
        onFollowing?()
    }

    func handleFollower() {
        onFollower?()
    }


    var onFollowSuccess: (() -> Void)?
    var onFollowFail: ((Error) -> Void)?
    var onUnFollowSuccess: ((String) -> Void)?
    var onUnFollowFail: ((Error) -> Void)?
    var onEditProfile: (() -> Void)?

    var onFollowStateChagned: ((String) -> Void)?

    var onFollowStatusCheck: ((String) -> Void)?
    var onFollowLabelStatus: (() -> Void)?

    func followToggle() {
        if user.isCurrentUser {
            self.onEditProfile?()
            return
        }

        if didFollow {
            unFollow()
        } else {
            follow()
        }
    }

    func follow() {
        UserService.shared.follow(uid: uid) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success():
                self.user.didFollow = true
                self.onFollowStateChagned?(self.user.didFollow ? "Following" : "Follow")
                self.onFollowSuccess?()
            case .failure(let error):
                self.onFollowFail?(error)
            }
        }
    }

    func unFollow() {

        UserService.shared.unfollow(uid: uid) { [weak self] result in
            guard let self else { return }

            switch result {
            case .success():
                self.user.didFollow = false
                self.onFollowStateChagned?(self.user.didFollow ? "Following" : "Follow")
                self.onFollowSuccess?()

            case .failure(let error):
                self.onUnFollowFail?(error)
            }
        }
    }

    func checkingFollow() {
        UserService.shared.checkingFollow(uid: uid) {[weak self] check in
            guard let self else { return }
            self.user.didFollow = check
            DispatchQueue.main.async {
                print(check)
                self.onFollowStatusCheck?(check ? "Following" : "Follow")
            }
        }
    }

    func getFollowCount() {
        UserService.shared.getFollowCount(uid: uid, followCheck: true) {[weak self] counting in
            guard let self  else { return }
            self.user.userFollowingCount = counting
            DispatchQueue.main.async {
                self.onFollowLabelStatus?()
            }

        }

        UserService.shared.getFollowCount(uid: uid, followCheck: false) { [weak self] counting in
            guard let self else { return }
            self.user.userFollowerCount = counting
            DispatchQueue.main.async {
                self.onFollowLabelStatus?()
            }
        }
    }


}
