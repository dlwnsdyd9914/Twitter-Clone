//
//  ExplorerViewModel.swift
//  Twitters
//
//  Created by 이준용 on 2/28/25.
//

import UIKit

class ExplorerViewModel {

    var userList = [User]() {
        didSet {
            onFetchUserList?()
        }
    }

    var filterUserList = [User]() {
        didSet {
            onFilterUserList?()
        }
    }

    var searchText: String? {
        didSet {
            guard let searchText else { return }
            onSearchText?(searchText)
            filterUser()
            print(inSeaerchMode)
        }
    }

    var isActive = false

    var inSeaerchMode: Bool {
        return isActive && !(searchText?.isEmpty ?? true)
    }


    static var userListCache = NSCache<NSString, NSArray>()

    static var userListkey = "UserListKey" as NSString

    var onFetchUserList: (() -> Void)?
    var onFilterUserList: (() -> Void)?
    var onSearchText: ((String) -> Void)?

    func fetchList() {
        if let cacheUserList = ExplorerViewModel.userListCache.object(forKey: ExplorerViewModel.userListkey) as? [User] , !cacheUserList.isEmpty {
            self.userList = cacheUserList
            print("🗂 캐시된 트윗 사용: \(self.userList.count)개")
            return
        }

        UserService.shared.getAllUserList { [weak self] result in
            guard let self else { return }

            switch result {
            case .success(let user):
                self.configureUserList(user: user)
            case .failure(let error):
                switch error {
                case .dataParsingError:
                    print("❗️데이터 파싱 오류")
                case .userNotFound:
                    print("❗️유저 정보 없음")
                }
            }
        }
    }

    private func configureUserList(user: User) {

        if !userList.contains(where: {$0.uid == user.uid}) {
            self.userList.append(user)

            ExplorerViewModel.userListCache.setObject(self.userList as NSArray, forKey: ExplorerViewModel.userListkey)
            print("🗂 캐시 업데이트 현재 유저 정보 갯수: \(self.userList.count)개")

        }
    }

    func bindText(text: String) {
        searchText = text
    }

    func filterUser() {
        guard let searchText = searchText?.lowercased(),
              !searchText.isEmpty else {
            filterUserList = []
            return
        }

        filterUserList = userList.filter({$0.userName.lowercased().contains(searchText) || $0.fullName.lowercased().contains(searchText)})
        print("🔎 검색 결과: \(filterUserList.count)명")
    }
}
