//
//  ProfileViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/27/25.
//

import UIKit

class ProfileViewModel {

    var selectedTweet = [Tweet]() {
        didSet {
            onFetchSelectedTweet?()

        }
    }

    var selectedFilter: FilterOption = .tweets

    var likedTweets = [Tweet]() {
        didSet {
            onFetchSelectedTweet?()
        }
    }

    var replies = [Tweet]() {
        didSet {
            onFetchSelectedTweet?()
        }
    }

    var currentDataSource: [Tweet] {
        switch selectedFilter {
        case .tweets:
            return selectedTweet
        case .replies:
            return replies
        case .likes:
            return likedTweets
        }
    }


    static var tweetCaches: [FilterOption: NSCache<NSString, NSArray>] = [
        .tweets: NSCache<NSString, NSArray>(),
        .replies: NSCache<NSString, NSArray>(),
        .likes: NSCache<NSString, NSArray>()
    ]


    static var selectedTweetCache = NSCache<NSString, NSArray>()
    static var selctedTweetRepliesCached = NSCache<NSString, NSArray>()
    static var selectedTweetLikeCache = NSCache<NSString, NSArray>()

    var onFetchSelectedTweet: (() -> Void)?



    func selectedFetchTweet(uid: String){

        self.removeFilter(filterOption: selectedFilter)

        let userCacheKey = "\(selectedFilter.cacheKey)+ \(uid)" as NSString

        if let cachedTweets = ProfileViewModel.selectedTweetCache.object(forKey: userCacheKey) as? [Tweet]  {
            self.selectedTweet = cachedTweets
            print("🗂 캐시된 트윗 사용: \(self.selectedTweet.count)개")

        }

        switch selectedFilter {
        case .tweets:
            TweetService.shared.selectFetchTweet(uid: uid) { [weak self] result  in
                guard let self else { return }

                switch result {
                case .success(let tweet):
                    self.appendSelectedTweet(tweet: tweet, userCacheKey: userCacheKey)
                case .failure(let error):
                    switch error {
                    case .notFoundTweet:
                        print("트윗 정보 없음")
                    case .notFoundUser:
                        print("유저 정보 없음")
                    case .dataParsingError:
                        print("통신 에러")
                    }
                }
            }
        case .replies:
            fetchReplies(uid: uid)
        case .likes:
            fetchLikedTweets(uid: uid, userCacheKey: userCacheKey)
        }


    }

    private func appendSelectedTweet(tweet: Tweet, userCacheKey: NSString) {
        // ✅ 1. 중복 확인 후 추가
        if !self.selectedTweet.contains(where: { $0.tweetId == tweet.tweetId }) {
            self.selectedTweet.append(tweet)

            // ✅ 2. 최신순 정렬
            self.selectedTweet.sort(by: { $0.timeStamp > $1.timeStamp })

            // ✅ 3. 캐시 업데이트
            ProfileViewModel.selectedTweetCache.setObject(self.selectedTweet as NSArray, forKey: userCacheKey)
            print("💾 캐시 업데이트 완료! 현재 선택된 트윗 개수: \(self.selectedTweet.count)")
        } else {
            print("⚠️ 중복된 트윗, 추가하지 않음.")
        }
    }

    func fetchLikedTweets(uid: String, userCacheKey: NSString) {
        TweetService.shared.fetchTweetLikes(uid: uid) {[weak self] tweet in
            guard let self = self else { return }

            if !self.likedTweets.contains(where: {$0.tweetId == tweet.tweetId}) {
                self.likedTweets.append(tweet)

                self.likedTweets.sort(by: {$0.timeStamp > $1.timeStamp})

                ProfileViewModel.selectedTweetLikeCache.setObject(self.likedTweets as NSArray, forKey: userCacheKey)
            }
        }
    }

    func fetchReplies(uid: String) {
        TweetService.shared.fetchReplies(uid: uid) { [weak self] tweet in
            guard let self = self else { return }
            dump(tweet)

            if !self.replies.contains(where: {$0.timeStamp == tweet.timeStamp}) {
                self.replies.append(tweet)

                self.replies.sort(by: {$0.timeStamp > $1.timeStamp})
            }
        }
    }

    func removeFilter(filterOption: FilterOption) {
        switch filterOption {
        case .tweets:
            self.selectedTweet.removeAll()
        case .replies:
            self.replies.removeAll()
        case .likes:
            self.likedTweets.removeAll()
        }
    }
}
