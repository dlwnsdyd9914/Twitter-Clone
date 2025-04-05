//
//  ActionSheetViewModel.swift
//  Twitters
//
//  Created by 이준용 on 3/28/25.
//

import UIKit

class ActionSheetViewModel {

    private let userViewModel: UserViewModel

    var options: [ActionSheetOptions] {
        var results = [ActionSheetOptions]()
        let user = userViewModel.getUser()

        if user.isCurrentUser {
            results.append(.delete)
        } else {
            let followOptions: ActionSheetOptions = user.didFollow ? .unfollow(getUser()) : .follow(user)
            results.append(followOptions)
        }

        results.append(.report)
        return results
    }

    var user: UserModelProtocol {
        return userViewModel.getUser()
    }

    var onHandleAction: (() -> Void)?


    init(userviewModel: UserViewModel) {
        self.userViewModel = userviewModel
    }

    func getUser() -> UserModelProtocol {
        return userViewModel.getUser()
    }

    func handleFollowAction() {


        if user.didFollow {
            UserService.shared.unfollow(uid: user.uid) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success():
                    print("언팔로우 성공")
                    userViewModel.updateFollowState(false)
                    self.onHandleAction?()
                case .failure(let error):
                    print("언팔로우 에러")
                }
            }
        } else {
            UserService.shared.follow(uid: user.uid) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success():
                    print("팔로우 성공")
                    userViewModel.updateFollowState(true)
                    self.onHandleAction?()
                case .failure(let error):
                    print("팔로우 실패")
                }
            }
        }
    }
}
