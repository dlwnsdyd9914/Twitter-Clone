//
//  FeedViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/24/25.
//

import UIKit

class FeedViewModel {

    var tweets = [Tweet]() {
        didSet {
            self.onDataUpdated?()
        }
    }

    var selectedTweet = [Tweet]()

    var onLogutSuccess: (() -> Void)?
    var onLogoutFail: ((Error) -> Void)?
    var onDataUpdated: (() -> Void)?

    var onRefreshControl: (() -> Void)?

    static var tweetCache = NSCache<NSString, NSArray>()
    static let nsCacheKey = "tweetKeys"


    init() {
        FeedViewModel.tweetCache.countLimit = 1000
    }


    func logout() {
        AuthService.shared.logout { [weak self] result in
            guard let self else { return }

            switch result {
            case .success():
                self.onLogutSuccess?()
            case .failure(let error):
                self.onLogoutFail?(error)
            }
        }
    }


    //
    //    func fetchTweet(completion: @escaping () -> Void) {
    //        // 캐시에서 트윗을 불러오는 부분
    //        if let fetchedTweets = FeedViewModel.tweetCache.object(forKey: "a") as? [Tweet] {
    //            print("✅ 캐시된 트윗을 불러옵니다. 개수: \(fetchedTweets.count)")
    //            self.tweets = fetchedTweets
    //            completion() // 캐시된 트윗을 사용할 경우 UI 업데이트
    //            return
    //        } else {
    //            print("🚨 트윗 캐시가 비어 있습니다.") // 캐시가 없을 경우 로그 출력
    //        }
    //
    //        print("🔄 서버에서 트윗을 가져옵니다.") // 서버에서 데이터를 가져오는 경우
    //        TweetService.shared.fetchTweet { [weak self] tweet in
    //            guard let self = self else { return }
    //
    //            // 트윗이 새로 추가되었을 경우
    //            if !self.tweets.contains(where: { $0.tweetId == tweet.tweetId }) {
    //                print("🆕 새로운 트윗을 추가합니다: \(tweet.tweetId)") // 새로운 트윗 추가 로그
    //                self.tweets.append(tweet)
    //                self.tweets.sort(by: { $0.timeStamp > $1.timeStamp })
    //
    //                // 트윗을 캐시에 저장합니다.
    //                print("💾 트윗을 캐시에 저장합니다. 현재 트윗 개수: \(self.tweets.count)")
    //                FeedViewModel.tweetCache.setObject(self.tweets as NSArray, forKey: "a")
    //
    //                // 캐시 저장 후 한번만 데이터를 불러오도록 처리
    //                DispatchQueue.main.async {
    //                    if let fetchedTweets = FeedViewModel.tweetCache.object(forKey: "a") as? [Tweet] {
    //                        print("캐시에서 불러온 트윗 개수: \(fetchedTweets.count)")
    //                        self.tweets = fetchedTweets // 캐시에서 불러온 트윗을 사용
    //                        completion() // UI 업데이트를 위한 closure 호출
    //                    } else {
    //                        print("🚨 캐시에서 트윗을 불러오지 못했습니다!")
    //                    }
    //                }
    //            } else {
    //                // 이미 트윗이 있는 경우
    //                print("⚠️ 이미 같은 트윗이 존재합니다. 추가하지 않습니다.")
    //                completion()
    //            }
    //        }
    //    }






    func ServiceTweet() {

        self.tweets.removeAll()
//        if let cachedTweets = FeedViewModel.tweetCache.object(forKey: FeedViewModel.nsCacheKey as NSString) as? [Tweet] {
//            self.tweets = cachedTweets
//            print("🗂 캐시된 트윗 사용: \(self.tweets.count)개")
//        }

        // ✅ 항상 서버에서 실시간으로도 가져오기

        TweetService.shared.fetchFollowTweet { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let tweet):
                self.fetchTweet(tweet: tweet)
                DispatchQueue.main.async {
                    self.onRefreshControl?()
                }
            case .failure(let error):
                switch error {
                case .dataParsingError:
                    print("❗️데이터 파싱 에러")
                case .notFoundTweet:
                    print("❗️트윗 없음")
                case .notFoundUser:
                    print("❗️유저 없음")
                }
            }
        }
    }


//        TweetService.shared.fetchAllTweet { [weak self] result in
//            guard let self else { return }
//            switch result {
//            case .success(let tweet):
//                self.fetchTweet(tweet: tweet)
//            case .failure(let error):
//                switch error {
//                case .dataParsingError:
//                    print("❗️데이터 파싱 에러")
//                case .notFoundTweet:
//                    print("❗️트윗 없음")
//                case .notFoundUser:
//                    print("❗️유저 없음")
//                }
//            }
//        }
//    }

    private func fetchTweet(tweet: Tweet) {
        // ✅ 1. 중복되지 않는다면 추가
        if !self.tweets.contains(where: { $0.tweetId == tweet.tweetId }) {
            self.tweets.append(tweet) // ✅ 기존 데이터를 유지하면서 추가
        }

        // ✅ 2. 최신순 정렬
        self.tweets.sort(by: { $0.timeStamp > $1.timeStamp })
        print("🚀 새로운 트윗 추가됨! 총 트윗 개수: \(self.tweets.count)")

//        // ✅ 3. 최신 데이터 캐시에 저장
//        FeedViewModel.tweetCache.setObject(self.tweets as NSArray, forKey: FeedViewModel.nsCacheKey as NSString)
//        print("💾 캐시 업데이트 완료! 현재 트윗 개수: \(self.tweets.count)")
    }

    

}






