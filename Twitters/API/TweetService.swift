//
//  TweetService.swift
//  Twitters
//
//  Created by 이준용 on 2/6/25.
//

import UIKit
import Firebase

final class TweetService {

    static let shared = TweetService()

    typealias CompletionHandler = (Result<Void, Error>) -> Void

    enum TweetServiceError: Error {
        case notFoundTweet
        case notFoundUser
        case dataParsingError

    }

    private init() {}


    func uploadTweet(caption: String, type: UploadTweetConfiguration, completion: @escaping CompletionHandler) {
        let date = Date().timeIntervalSince1970
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "사용자 인증 실패"])))
            return
        }

        var values: [String: Any] = [
            "caption": caption,
            "timestamp": date,
            "likes": 0,
            "retweets": 0,
            "uid": uid
        ]


        switch type {
        case .tweet:
            TWEET_REF.childByAutoId().updateChildValues(values) {[weak self] error, ref in
                guard let self else { return }
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let tweetId = ref.key else {
                    completion(.failure(NSError(domain: "FirebaseError", code: 500, userInfo: [NSLocalizedDescriptionKey: "트윗 ID 생성 실패"])))
                    return
                }
                self.updateUserFeed(tweetId: tweetId)
                self.updateUserTweets(uid: uid, tweetId: tweetId, completion: completion)
            }
        case .reply(let tweet):
            values["replyingTo"] = tweet.user.userName

            TWEET_REPLIES_REF.child(tweet.tweetId).childByAutoId().updateChildValues(values) { error, ref in
                let key = ref.key
                USER_TWEET_REPLIES_REF.child(uid).updateChildValues([tweet.tweetId : key!])
                NotificationService.shared.uploadNotification(type: .reply, tweet: tweet, caption: caption)
                completion(.success(()))
            }
        }
    }

    private func updateUserTweets(uid: String, tweetId: String, completion: @escaping CompletionHandler) {
        USER_TWEET_REF.child(uid).updateChildValues([tweetId: 1]) { error, _ in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
        }
    }

    func fetchAllTweet(completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {

        TWEET_REF.observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            guard let tweetData = snapshot.value as? [String: Any] else {
                completion(.failure(.dataParsingError))
                return
            }
            guard let uid = tweetData["uid"] as? String else { return }
            print(tweetData)

            USER_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    completion(.failure(.notFoundTweet))
                    return
                }
                guard let userData = snapshot.value as? [String: Any] else {
                    completion(.failure(.notFoundUser))
                    return
                }


                let user = User(uid: uid, dictionary: userData)
                let tweet = Tweet(tweetId: tweetId, dictionary: tweetData, user: user)
                

                completion(.success(tweet))
            }
        }
    }

    func fetchFollowTweet(completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        USER_FEED_REF.child(currentUid).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            TWEET_REF.child(tweetId).observeSingleEvent(of: .value) { snapshot in
                guard let tweetValue = snapshot.value as? [String: Any],
                      let uid = tweetValue["uid"] as? String else { return }

                USER_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
                    guard let userValue = snapshot.value as? [String: Any] else { return }
                    let user = User(uid: uid, dictionary: userValue)
                    let tweet = Tweet(tweetId: tweetId, dictionary: tweetValue, user: user)
                    completion(.success(tweet))
                }
            }
        }
    }

    private func updateUserFeed(tweetId: String) {
         guard let currentUid = Auth.auth().currentUser?.uid else { return }

         let values = [tweetId: 1]

        USER_FOLLOWING_REF.child(currentUid).observe(.childAdded) { snapshot in
            let key = snapshot.key
            USER_FEED_REF.child(key).updateChildValues(values)
        }
        


     }

    func selectFetchTweet(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
        USER_TWEET_REF.child(uid).observe(.childAdded) { snapshot in
            let tweetId = snapshot.key
            print("📝 [실시간] 트윗 ID: \(tweetId)")

            TWEET_REF.child(tweetId).observeSingleEvent(of: .value) { tweetSnapshot in
                guard let tweetData = tweetSnapshot.value as? [String: Any] else {
                    completion(.failure(.notFoundTweet))
                    return
                }

                guard let userUid = tweetData["uid"] as? String else {
                    completion(.failure(.notFoundUser))
                    return
                }

                USER_REF.child(userUid).observeSingleEvent(of: .value) { userSnapshot in
                    guard let userData = userSnapshot.value as? [String: Any] else {
                        completion(.failure(.notFoundUser))
                        return
                    }

                    let user = User(uid: userUid, dictionary: userData)
                    let tweet = Tweet(tweetId: tweetId, dictionary: tweetData, user: user)
                    completion(.success(tweet))
                }
            }
        }
    }


//    func selectFetchTweet(uid: String, completion: @escaping (Result<Tweet, TweetServiceError>) -> Void) {
//        USER_TWEET_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
//            guard snapshot.exists() else {
//                completion(.failure(.notFoundTweet))
//                return
//            }
//
//            guard let tweetKeyDict = snapshot.value as? [String: Any] else { return }
//            let key = Array(tweetKeyDict.keys)
//            for tweetId in key {
//                print("📝 트윗 ID 가져오기: \(tweetId)")
//
//                TWEET_REF.child(tweetId).observeSingleEvent(of: .value) { snapshot in
//                    guard let tweetData = snapshot.value as? [String: Any] else {
//                        completion(.failure(.notFoundTweet))
//                        return
//                    }
//                    guard let userUid = tweetData["uid"] as? String else { return }
//
//                    USER_REF.child(userUid).observeSingleEvent(of: .value) { snapshot in
//                        guard let userData = snapshot.value as? [String: Any] else { return }
//
//                        let user = User(uid: userUid, dictionary: userData)
//                        let tweet = Tweet(tweetId: tweetId, dictionary: tweetData, user: user)
//                        completion(.success(tweet))
//                    }
//                }
//            }
//        }
//    }

    func fetchTWEETs(tweetId: String, completion: @escaping (Tweet) -> Void) {
        TWEET_REF.child(tweetId).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any],
                  let uid = value["uid"] as? String else { return }

            USER_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
                guard let userValue = snapshot.value as? [String: Any] else { return }
                let user = User(uid: uid, dictionary: userValue)
                let tweet = Tweet(tweetId: tweetId, dictionary: value, user: user)
                completion(tweet)
            }
        }
    }

    func fetchTweetReplies(tweetId: String, completion: @escaping(Tweet) -> Void) {
        TWEET_REPLIES_REF.child(tweetId).observe(.childAdded) { snapshot in
            let key = snapshot.key
            guard let value = snapshot.value as? [String: Any],
                  let uid = value["uid"] as? String else { return }

            USER_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
                guard let userValue = snapshot.value as? [String: Any] else { return }
                let user = User(uid: uid, dictionary: userValue)
                let tweet = Tweet(tweetId: key, dictionary: value, user: user)
                completion(tweet)
            }
        }
    }

    func likesTweet(tweet: TweetModelProtocol, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        let tweetId = tweet.tweetId

        TWEET_REF.child(tweetId).child("likes").runTransactionBlock { currentData in
            var value = currentData.value as? Int ?? 0
            value = tweet.didLike ? max(value - 1, 0) : value + 1
            currentData.value = value
            return .success(withValue: currentData)
        } andCompletionBlock: { error, _, snapshot in
            if let error = error {
                print("트랜잭션 실패", error.localizedDescription)
                completion(false)
                return
            }

            if tweet.didLike {
                TWEET_LIKES_REF.child(tweetId).child(currentUid).removeValue()
                USER_TWEET_LIKES_REF.child(currentUid).child(tweetId).removeValue()
                completion(false)
            } else {
                TWEET_LIKES_REF.child(tweetId).updateChildValues([currentUid: 1])
                USER_TWEET_LIKES_REF.child(currentUid).updateChildValues([tweetId: 1])
                completion(true)
            }
        }
    }


//        tweetLikesRef.setValue(likes) { error, _ in
//            if let error = error {
//                print("❌ Failed to update likes count: \(error.localizedDescription)")
//                completion(false)
//                return
//
//            }
//
//            if tweet.didLike == true {
//                // 좋아요 제거
//                TWEET_LIKES_REF.child(tweetId).child(currentUid).removeValue { _, _ in
//                    USER_TWEET_LIKES_REF.child(currentUid).child(tweetId).removeValue { _, _ in
//                        completion(false)
//                    }
//                }
//            } else {
//                // 좋아요 추가
//                TWEET_LIKES_REF.child(tweetId).updateChildValues([currentUid: 1]) { _, _ in
//                    USER_TWEET_LIKES_REF.child(currentUid).updateChildValues([tweetId: 1]) { _, _ in
//                        completion(true)
//                    }
//                }
//            }
//        }
//    }

    func likesStatus(tweet: TweetModelProtocol, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }

        TWEET_LIKES_REF.child(tweet.tweetId).child(currentUid).observe(.value) { snapshot in
            completion(snapshot.exists())
        }
    }

    func fetchTweetLikes(uid: String, completion: @escaping ((Tweet) -> Void)) {
        USER_TWEET_LIKES_REF.child(uid).observe(.childAdded) { snapshot in
            let tweetID = snapshot.key
            TWEET_REF.child(tweetID).observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any],
                      let tweetUid = value["uid"] as? String else { return }

                USER_REF.child(tweetUid).observeSingleEvent(of: .value) { snapshot in
                    guard let userValue = snapshot.value as? [String: Any] else { return }
                    let user = User(uid: tweetUid, dictionary: userValue)
                    let tweet = Tweet(tweetId: tweetID, dictionary: value, user: user)
                    completion(tweet)
                }
            }
        }
    }

    func fetchReplies(uid: String, completion: @escaping ((Tweet) -> Void)) {
        USER_TWEET_REPLIES_REF.child(uid).observe(.childAdded) { snapshot in
            let key = snapshot.key
            guard let value = snapshot.value as? String else { return }

            TWEET_REPLIES_REF.child(key).child(value).observeSingleEvent(of: .value) { snapshot in
                dump(snapshot.value)
                guard let tweetValue = snapshot.value as? [String: Any],
                      let userUid = tweetValue["uid"] as? String else { return }

                USER_REF.child(userUid).observeSingleEvent(of: .value) { snapshot in
                    guard let userValue = snapshot.value as? [String: Any] else { return }

                    let user = User(uid: userUid, dictionary: userValue)
                    let tweet = Tweet(tweetId: key, dictionary: tweetValue, user: user)
                    completion(tweet)
                }
            }
        }
    }
}

