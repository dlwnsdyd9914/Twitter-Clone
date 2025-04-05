//
//  User.swift
//  Twitters
//
//  Created by 이준용 on 2/1/25.
//

import UIKit
import Firebase
class User: UserModelProtocol {
    var userFollowingCount: Int = 0

    var userFollowerCount: Int = 0
    
    var email: String

    var fullName: String

    var userName: String

    var uid: String

    var profileImageUrl: String

    var didFollow: Bool = false

    var isCurrentUser: Bool {
        return Auth.auth().currentUser?.uid == uid
    }

    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid

        self.email = dictionary["email"] as? String ?? ""
        self.fullName = dictionary["fullName"] as? String ?? ""
        self.userName = dictionary["userName"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }


}

