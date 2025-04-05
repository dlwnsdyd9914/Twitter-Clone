//
//  UserService.swift
//  Twitters
//
//  Created by 이준용 on 2/2/25.
//

import UIKit
import Firebase

class UserService {
    static let shared = UserService()

    private init() {}

    enum UserServiceError: Error {
        case userNotFound
        case dataParsingError
    }

    func getCurrentUser(completion: @escaping (Result<User, UserServiceError>) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else {
            completion(.failure(.userNotFound))
            return
        }

        USER_REF.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                completion(.failure(.userNotFound))
                return
            }

            let key = snapshot.key
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(.dataParsingError))
                return
            }

            let user = User(uid: key, dictionary: value)
            completion(.success(user))
        }
    }

    func getUser(uid: String, completion: @escaping (User) -> Void) {
        USER_REF.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else { return }
            let user = User(uid: uid, dictionary: value)
            completion(user)
        }
    }

    func getAllUserList(completion: @escaping (Result<User, UserServiceError>) -> Void) {
        USER_REF.observe(.childAdded) { snapshot in
            guard snapshot.exists() else {
                completion(.failure(.userNotFound))
                return
            }
            let key = snapshot.key
            guard let value = snapshot.value as? [String: Any] else {
                completion(.failure(.dataParsingError))
                return
            }
            let user = User(uid: key, dictionary: value)
            completion(.success(user))
        }
    }

    func follow(uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1]) { error, ref in
            if let error = error {
                print("팔로우 실패", error.localizedDescription)
                completion(.failure(error))
                return
            }

            // ✅ 현재 사용자를 팔로우한 유저 목록에 추가 (오류 수정)
            USER_FOLLWER_REF.child(uid).updateChildValues([currentUid: 1]) { error, ref in
                if let error = error {
                    print("팔로잉 실패", error.localizedDescription)
                    completion(.failure(error))
                    return
                }
                NotificationService.shared.uploadNotification(type: .follow, toUid: uid)
                completion(.success(())) // ✅ 올바른 성공 처리
            }
        }
    }
    func unfollow(uid: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue { error, ref in
            if let error = error {
                print("팔로우 취소 실패", error.localizedDescription)
                completion(.failure(error))
                return
            }
            // ✅ 올바르게 currentUid를 제거 (오류 수정)
            USER_FOLLWER_REF.child(uid).child(currentUid).removeValue { error, ref in
                if let error = error {
                    print("팔로잉 취소 실패", error.localizedDescription)
                    completion(.failure(error))
                    return
                }
                completion(.success(())) // ✅ 올바른 성공 처리
            }
        }
    }

    func checkingFollow(uid: String, completion: @escaping (Bool) -> Void) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        USER_FOLLOWING_REF.child(currentUid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.hasChild(uid) {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func getFollowCount(uid: String, followCheck: Bool, completion: @escaping (Int) -> Void) {

        let FOLLOW_REF = followCheck ? USER_FOLLOWING_REF : USER_FOLLWER_REF

        FOLLOW_REF.child(uid).observe(.value) { snapshot in
            if let count = snapshot.value as? [String: Any] {
                completion(count.count)
            } else {
                completion(0)
            }
        }
    }

}


