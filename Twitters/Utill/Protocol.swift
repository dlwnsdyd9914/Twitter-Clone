//
//  Protocol.swift
//  Twitters
//
//  Created by 이준용 on 1/2/25.
//

import UIKit

protocol UserModelProtocol {
    var email: String { get }
    var fullName: String { get }
    var userName: String { get }
    var uid: String { get }
    var profileImageUrl: String { get }
    var didFollow: Bool { get set }
    var isCurrentUser: Bool { get }
    var userFollowingCount: Int { get set }
    var userFollowerCount: Int { get set }
}

protocol UserViewModelProtocol {
    var username: String { get }
    var fullname: String { get }
    var uid: String { get }
    var profileImageUrl: URL? { get }
    var email: String { get }
}

protocol TweetModelProtocol {
    var caption: String { get }
    var lieks: Int { get set }
    var retweets: Int { get }
    var timeStamp: Date { get }
    var tweetId: String { get }
    var uid: String { get }
    var user: User { get }
    var didLike: Bool { get set }
    var replyingTo: String? { get set }
}

protocol TweetViewModelProtocol {
    var caption: String { get }
    var timestamp: String { get }
    var user: User { get }
    var profileImageUrl: URL? { get }
    var tweetId: String { get }
    var infoLabel: NSAttributedString { get }
}

protocol MockTweetModelProtocol {
    var caption: String { get }
    var timestamp: String { get }
    var user: MockUserModel { get }
    var profileImageUrl: URL? { get }
    var tweetId: String { get }
}

protocol ProfileHeaderViewModelProtocol {
    var followerString: NSAttributedString { get }
    var followingString: NSAttributedString { get }
    var profileImageUrl: URL? { get }
    var infoText: NSAttributedString { get }
    var actionButtonTitle: String { get }
    var fullname: String { get }
    var username: String { get }
    var uid: String { get }
    var didFollow: Bool { get  }
}

protocol TweetHeaderViewModelProtocol {
    var fullname: String { get }
    var username: String { get }
    var profileImageUrl: URL? { get }
}

protocol RouterProtocol {
    func navigationToTweetReply(viewController: UIViewController, tweet: Tweet, userViewModel: UserViewModel)
    func navigate(to destination: Destination, from navigationController: UINavigationController)
}

protocol NotificationModelProtocol {
    var timestamp: Date { get }
    var type: NotificationType? { get set }
    var caption: String? { get }
    var tweetID: String { get }
    var uid: String { get }
}
