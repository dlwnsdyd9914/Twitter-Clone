//
//  Enum.swift
//  Twitters
//
//  Created by 이준용 on 1/2/25.
//

import UIKit

enum FieldType: String {
    case email = "Email"
    case password = "Password"
    case fullname = "Fullname"
    case username = "Username"
}

enum Destination {
    case tweetReply(tweet: Tweet, userViewModel: UserViewModel)
    case profile(user: User)
    case settings
}

enum UploadTweetConfiguration {
    case tweet
    case reply(TweetModelProtocol)
}

enum ActionSheetOptions: CustomStringConvertible {


    case follow(UserModelProtocol)
    case unfollow(UserModelProtocol)
    case report
    case delete

    var description: String {
        switch self {
        case .follow(let user):
            return "Follow @\(user.userName)"
        case .unfollow(let user):
            return "Unfollow @\(user.userName)"
        case .report:
            return "Report Tweet"
        case .delete:
            return "Delete Tweet"
        }
    }
}

enum NotificationType: Int, CustomStringConvertible {

    case follow
    case like
    case reply
    case retweet
    case mention

    var description: String {
        switch self {
        case .follow:
            return "Follow"
        case .like:
            return "like"
        case .reply:
            return "reply"
        case .retweet:
            return "retwet"
        case .mention:
            return "mention"
        }
    }

}

enum FilterOption: Int, CaseIterable, CustomStringConvertible {

    case tweets
    case replies
    case likes

    var description: String {
        get {
            switch self {
            case .tweets:
                return "Tweets"
            case .replies:
                return "Tweets & Replies"
            case .likes:
                return "Likes"
            }
        }
    }

    

}

