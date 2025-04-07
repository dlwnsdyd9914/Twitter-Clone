//
//  TweetViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/25/25.
//

import UIKit

protocol TweetViewModelDelegate: AnyObject {
    func didTapProfileImage(userViewModel: UserViewModel)
}

class TweetViewModel: TweetViewModelProtocol {
    


    private var tweet: TweetModelProtocol

    weak var delegate: TweetViewModelDelegate?

    static var reliesCacnhe = NSCache<NSString, NSArray>()



    var caption: String {
        return tweet.caption
    }

    var onSuccessReplies: (() -> Void)?
    var onTweetLikes: ((Bool) -> Void)?
    var onLikeService: (() -> Void)?

    var tweetReplies = [Tweet]()

    var timestamp: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        formatter.maximumUnitCount = 1
        formatter.unitsStyle = .abbreviated
        let now = Date()
        return formatter.string(from: tweet.timeStamp, to: now) ?? "2m"
    }

    var user: User {
        return tweet.user
    }

    var profileImageUrl: URL? {
        return URL(string: tweet.user.profileImageUrl)
    }

    var tweetId: String {
        return tweet.tweetId
    }

    var likeButtonImage: UIImage {
        return tweet.didLike ? UIImage.likeFilled : UIImage.like
    }

    var shouldHideReplyLabel: Bool {
        return !tweet.isRely
    }

    var replyingTo: String {
        return tweet.replyingTo ?? ""
    }

    var replyText: String {
        return "→ replying to @\(replyingTo)"
    }

    

    lazy var cacheyKey = "keys\(tweetId)" as NSString

    var infoLabel: NSAttributedString {
        let title = NSMutableAttributedString(string: tweet.user.fullName , attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)])
        title.append(NSAttributedString(string: " @\(tweet.user.userName )", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12),
                                                                                          NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        title.append(NSAttributedString(string: " . \(timestamp)", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),
                                                                                NSAttributedString.Key.foregroundColor : UIColor.lightGray]))
        return title
    }


    var onHandleCommentButton: ((UploadTweetConfiguration) -> Void)?




    init(tweet: TweetModelProtocol, delegate: TweetViewModelDelegate? = nil) {
        self.tweet = tweet
        self.delegate = delegate
        likeStatus()
    }

    func handleProfileImageTapped() {
        let userViewModel = UserViewModel(user: tweet.user)
        delegate?.didTapProfileImage(userViewModel: userViewModel)
    }

    func handleLikeButton() {
        likesService()
    }


    func handleRetweetButton() {

        print("Tweet retweeted: \(tweet.tweetId)")
    }

    func handleCommentButton() {
        print("Comment button tapped for: \(tweet.tweetId)")
        let type: UploadTweetConfiguration = .reply(tweet)
        onHandleCommentButton?(type)
        print(type)
    }

    func handleShareButton() {
        print("Share button tapped for: \(tweet.tweetId)")
    }

    func getTweet() -> TweetModelProtocol {
        return tweet
    }

    func fetchReplies() {

        if let repliesCached = TweetViewModel.reliesCacnhe.object(forKey: cacheyKey) as? [Tweet]{
            self.tweetReplies = repliesCached
        }

        TweetService.shared.fetchTweetReplies(tweetId: tweetId) {[weak self] tweet in
            guard let self else { return }

            if !self.tweetReplies.contains(where: {$0.tweetId == tweet.tweetId}) {
                self.tweetReplies.append(tweet)
            }

            if self.tweetReplies.count > 1 {
                self.tweetReplies.sort(by: { $0.timeStamp > $1.timeStamp })
            }

            TweetViewModel.reliesCacnhe.setObject(self.tweetReplies as NSArray, forKey: cacheyKey)

            self.onSuccessReplies?()
        }

    }

    func likesService() {
        TweetService.shared.likesTweet(tweet: tweet) {[weak self] didLikes in
            guard let self else { return }
            self.tweet.didLike = didLikes
            self.tweet.lieks += didLikes ? 1 : -1
            self.onTweetLikes?(didLikes)
            self.onLikeService?()
            NotificationService.shared.uploadNotification(type: .like, tweet: self.tweet)
        }
    }

    func likeStatus() {
        TweetService.shared.likesStatus(tweet: tweet) { [weak self] didLikes in
            guard let self else { return }
            self.tweet.didLike = didLikes
            self.onLikeService?()
            self.onTweetLikes?(didLikes)
        }
    }


   
}



struct MockTweetModel: TweetModelProtocol {
    var isRely: Bool
    
    var replyingTo: String?
    
    var didLike: Bool
    
    var caption: String
    
    var tweetId: String
    
    var user: User
    
    var lieks: Int
    
    var retweets: Int
    
    var timeStamp: Date
    
    var uid: String
    

    
   

}



