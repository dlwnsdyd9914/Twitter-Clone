//
//  NotificationService.swift
//  Twitters
//
//  Created by 이준용 on 4/1/25.
//

import UIKit
import Firebase

class NotificationService {
    static let shared = NotificationService()

    private init () {}

    func uploadNotification(type: NotificationType, tweet: TweetModelProtocol? = nil, caption: String? = nil, toUid: String? = nil) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let timestamp = Date().timeIntervalSince1970

        var values: [String: Any] = [
            "uid" : uid,
            "timestamp" : timestamp,
            "type" : type.rawValue
        ]

        if let caption = caption {
            values["caption"] = caption
        }

        if let tweet = tweet {
            values["tweetID"] = tweet.tweetId
            NOTIFICATION_REF.child(tweet.user.uid).childByAutoId().updateChildValues(values)
        } else if let toUid = toUid{
            NOTIFICATION_REF.child(toUid).childByAutoId().updateChildValues(values)
        }
    }

    func fetchNotification(completion: @escaping (Notification) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        NOTIFICATION_REF.child(uid).observe(.childAdded) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }

            let notification = Notification(dictionary: value)
            completion(notification)
        }
    }

    func fetchAllNotifications(completion: @escaping ([Notification]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        NOTIFICATION_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
            var notifications: [Notification] = []

            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any] {
                    let notification = Notification(dictionary: dict)
                    notifications.append(notification)
                }
            }

            completion(notifications)
        }
    }

}
