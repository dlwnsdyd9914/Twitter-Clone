//
//  NotificationCellViewModel.swift
//  Twitters
//
//  Created by 이준용 on 4/2/25.
//

import UIKit

class NotificationCellViewModel {

    private var notification: NotificationModelProtocol

    var user: User? {
        didSet {
            onUserFetched?()
        }
    }
    var tweet: Tweet? {
        didSet {
            onTweetFetched?()
        }
    }

     var tweetID: String {
        return notification.tweetID
    }

     var uid: String {
        return notification.uid
    }

    var profileImageUrl: String {
        return user?.profileImageUrl ?? ""
    }

    var caption: String {
        return notification.caption ?? ""
    }



    private var type: NotificationType? {
        return notification.type
    }
    var notificationText: String {
        guard let type = type, let user = user else { return "" }

        switch type {
        case .follow:
            return "\(user.userName)님이 회원님을 팔로우했습니다."

        case .mention:
            return "\(user.userName)님이 회원님을 멘션했습니다."

        case .like:
            return "\(user.userName)님이 회원님의 트윗에 좋아요를 눌렀습니다."

        case .reply:
            return "\(user.userName)님이 회원님의 트윗 \"\(caption)\"에 댓글을 남겼습니다."

        case .retweet:
            return "\(user.userName)님이 회원님의 트윗 \"\(caption)\"을 리트윗했습니다."
        }
    }



    var onUserFetched: (() -> Void)?
    var onTweetFetched: (() -> Void)?
    var onFollowStatusChagned: (() -> Void)?
    var onFollowSuccess: (() -> Void)?
    var onUnFollowSuccess: (() -> Void)?
    var onUnFollowFail: ((Error) -> Void)?
    var onFollowFail: ((Error) -> Void)?
    var onFollowButtonStatusUpadted: ((String) -> Void)?

    var shuoldHideFollowButton: Bool {
        return type != .follow
    }

    var followButtonText: String {
        return user?.didFollow ?? false ? "Following" : "Follow"
    }

    private func currentFollowButtonText(bool: Bool) -> String {
        return bool ? "Following" : "Follow"
    }



    init(notification: NotificationModelProtocol) {
        self.notification = notification
        fetchUser()
        fetchTweet()
        getFollowStatus()
    }

    private func fetchUser() {
        UserService.shared.getUser(uid: uid) { [weak self] user in
            guard let self else { return }
            self.user = user
        }
    }

    private func fetchTweet() {
        guard type != .follow, !tweetID.isEmpty else {
            print("⚠️ 트윗 없는 알림 타입입니다. fetchTweet 건너뜀.")
            return
        }

        TweetService.shared.fetchTWEETs(tweetId: tweetID) { [weak self] tweet in
            guard let self else { return }
            self.tweet = tweet
        }
    }

    func followButtonTapped() {
        guard let user else { return }

        if user.didFollow == false {
            UserService.shared.follow(uid: uid) { [weak self] result in
                guard let self else { return }

                switch result {
                case .success():
                    self.onFollowSuccess?()
                    self.user?.didFollow = true
                    self.onFollowButtonStatusUpadted?(currentFollowButtonText(bool: self.user?.didFollow ?? false))
                case .failure(let error):
                    self.onFollowFail?(error)
                }
            }
        } else {
            UserService.shared.unfollow(uid: uid) { [weak self] result in
                guard let self else { return }

                switch result {
                case .success():
                    self.onUnFollowSuccess?()
                    self.user?.didFollow = false
                    self.onFollowButtonStatusUpadted?(currentFollowButtonText(bool: self.user?.didFollow ?? false))
                case .failure(let error):
                    self.onUnFollowFail?(error)
                }
            }
        }
    }

    func getFollowStatus() {
        UserService.shared.checkingFollow(uid: uid) {[weak self] check in
            guard let self else { return }
            self.user?.didFollow = check
            self.tweet?.user.didFollow = check
            self.onFollowButtonStatusUpadted?(currentFollowButtonText(bool: check))
        }
    }



}
