//
//  NotificationViewModel.swift
//  Twitters
//
//  Created by 이준용 on 4/1/25.
//

import UIKit
import Firebase

class NotificationViewModel {

    private(set) var notification: [NotificationModelProtocol] = [] {
        didSet {
            self.onFetchNotification?()
        }
    }

    private var user: UserModelProtocol?
    private var tweet: TweetModelProtocol?

    var onFetchNotification: (() -> Void)?

    var tweetID: String? 

    var onFetchTweet: ((Tweet) -> Void)?

    var indexPathRow: Int?

   
    private var currentUID: String? {
        return Auth.auth().currentUser?.uid
    }

    static let notificationCached = NSCache<NSString, NSArray>()

    init() {
        guard currentUID != nil else {
            print("❌ currentUID가 아직 설정되지 않았음 – ViewModel 생성을 나중에 해야 함")
            return
        }
        fetchNotification()
    }


     func fetchNotification() {
        guard let uid = currentUID else {
            print("❌ currentUID is nil – fetch 취소")
            return
        }

        print(uid)

        let key = "NotificationKey_\(uid)"

        // ✅ 1. 캐시 확인
        if let cached = NotificationViewModel.notificationCached.object(forKey: key as NSString) as? [NotificationModelProtocol] {
            print("🧠 [캐시 HIT] \(cached.count)개의 알림을 캐시에서 불러옴")
            self.notification = cached
        } else {
            print("🕵️‍♂️ [캐시 MISS] 캐시에 저장된 알림이 없음")
        }

        // ✅ 2. 서버 fetch
        NotificationService.shared.fetchNotification { [weak self] notification in
            guard let self else { return }

            print("📥 [서버 FETCH] 새로운 알림 도착: \(notification)")

            if !self.notification.contains(where: { $0.timestamp == notification.timestamp }) {
                self.notification.append(notification)
            }

            self.notification.sort(by: { $0.timestamp > $1.timestamp })
            print("📊 [정렬 완료] 알림 총 개수: \(self.notification.count)")

            NotificationViewModel.notificationCached.setObject(self.notification as NSArray, forKey: key as NSString)
            print("💾 [캐시 저장 완료] 현재 캐시에 저장된 알림 수: \(self.notification.count)")
        }
    }

    func fetchNotificationAll() {
        guard let uid = currentUID else { return }

        NotificationService.shared.fetchAllNotifications { [weak self] notifications in
            guard let self else { return }

            let sorted = notifications.sorted(by: { $0.timestamp > $1.timestamp })
            self.notification = sorted

            let key = "NotificationKey_\(uid)"
            NotificationViewModel.notificationCached.setObject(sorted as NSArray, forKey: key as NSString)
        }
    }



    func fetchTweet(tweetId: String, completion: @escaping (Tweet) -> Void) {
        TweetService.shared.fetchTWEETs(tweetId: tweetId) { [weak self] tweet in
            guard let self else { return }
            completion(tweet)

        }
    }




    


}
