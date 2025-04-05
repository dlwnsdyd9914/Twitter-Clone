//
//  MainTabViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/24/25.
//

import UIKit

class MainTabViewModel {

    private(set) var user: User? {
        didSet {
            guard let user, oldValue?.uid != user.uid else { return }
            onFetchUser?(user)
        }
    }

    var onFetchUser: ((User) -> Void)?
    var onFetchUserFail: ((String) -> Void)?


    func fetchUser() {
        UserService.shared.getCurrentUser { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    self.user = user
                }
            case .failure(let error):
                let errorMessage: String
                switch error {
                case .dataParsingError:
                    errorMessage = "❗️데이터를 불러올 수 없습니다."
                case .userNotFound:
                    errorMessage = "❗️유저 정보를 찾을 수 없습니다."
                }

                DispatchQueue.main.async {
                    self.onFetchUserFail?(errorMessage)
                }
            }
        }
    }

}
