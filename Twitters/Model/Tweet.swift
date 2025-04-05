//
//  Tweet.swift
//  Twitters
//
//  Created by 이준용 on 2/6/25.
//

import UIKit

class Tweet: TweetModelProtocol {

    var replyingTo: String?
    
    
    var user: User

    var caption: String

    var lieks: Int

    var retweets: Int

    var timeStamp: Date

    var tweetId: String

    var uid: String

    var didLike = false

    init(tweetId: String, dictionary: [String: Any], user: User) {
        self.user = user
        self.tweetId = tweetId

        self.uid = dictionary["uid"] as? String ?? ""
        self.lieks = dictionary["likes"] as? Int ?? 0
        self.retweets = dictionary["retweets"] as? Int ?? 0
        self.caption = dictionary["caption"] as? String ?? ""
        self.replyingTo = dictionary["replyingTo"] as? String ?? ""

        if let timestamp = dictionary["timestamp"] as? Double {
            self.timeStamp = Date(timeIntervalSince1970: timestamp)
        } else {
            self.timeStamp = Date()
        }
    }


}
