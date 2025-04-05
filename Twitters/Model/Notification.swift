//
//  Notification.swift
//  Twitters
//
//  Created by 이준용 on 4/1/25.
//

import UIKit

class Notification: NotificationModelProtocol {

    var uid: String

    var caption: String?
    

    var type: NotificationType?

    var timestamp: Date

    var tweetID: String

    init(dictionary: [String: Any]) {


        self.uid = dictionary["uid"] as? String ?? ""
        self.tweetID = dictionary["tweetID"] as? String ?? ""
        self.caption = dictionary["caption"] as? String ?? ""

        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        } else {
            self.timestamp = Date()
        }
        if let type = dictionary["type"] as? Int {
            self.type = NotificationType(rawValue: type)
        }
    }

}

