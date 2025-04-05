//
//  UserViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/24/25.
//

import UIKit

class UserViewModel: UserViewModelProtocol {

    private var user: UserModelProtocol

    var username: String {
        return user.userName

    }

    var fullname: String {
        return user.fullName

    }

    var uid: String {
        return user.uid

    }

    var profileImageUrl: URL? {
        return URL(string: user.profileImageUrl)

    }

    var email: String {
        return user.email
    }

    var didFollow: Bool {
        return user.didFollow
    }

    func getUser() -> UserModelProtocol {
        return user
    }

    init(user: UserModelProtocol) {
        self.user = user
    }

    var onFollowStatusCheck: (() -> Void)?

    func checkingFollow() {
        UserService.shared.checkingFollow(uid: uid) {[weak self] check in
            guard let self else { return }
            self.user.didFollow = check
            DispatchQueue.main.async {
                print(check)
                self.onFollowStatusCheck?()
            }
        }
    }

    func updateFollowState(_ followed: Bool) {
            user.didFollow = followed
        }



}
struct MockUserModel: UserModelProtocol {
    var userFollowingCount: Int = 0

    var userFollowerCount: Int = 1

    var isCurrentUser: Bool = true
    
    var didFollow: Bool = false
    var email: String = "preview@example.com"
    var userName: String = "PreviewUser"
    var fullName: String = "Preview Full Name"
    var profileImageUrl: String = "https://via.placeholder.com/150"
    var uid: String = "previewUID"
}

