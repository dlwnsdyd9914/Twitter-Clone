//
//  AuthService.swift
//  Twitters
//
//  Created by 이준용 on 2/1/25.
//

import UIKit
import Firebase

class AuthService {
    static let shared = AuthService()

    private init() {}

    typealias CompletionHandler = (Result<Void, Error>) -> Void

    func createUser(email: String, password: String, profileImage: UIImage, username: String, fullname: String, completion: @escaping CompletionHandler) {
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] result , error in
            guard let self = self else { return }
            if let error = error {
                print("가입 실패", error.localizedDescription)
                completion(.failure(error))
                return
            }

            print("가입 성공")
            self.saveProfileImage(email: email, profileImage: profileImage, username: username, fullname: fullname) {
                completion(.success(()))
            }
        }
    }

    private func saveProfileImage(email: String, profileImage: UIImage, username: String, fullname: String, completion: @escaping () -> Void) {
        let filename = UUID().uuidString
        guard let data = profileImage.jpegData(compressionQuality: 0.3) else { return }

        USER_PROFILE.child(filename).putData(data) { [weak self] metadata, error in
            guard let self = self else { return }
            if let error = error {
                print("프로필 이미지 저장 실패", error.localizedDescription)
                return
            }

            print("프로필 이미지 저장 성공")

            self.downloadProfileImage(email: email, filename: filename, username: username, fullname: fullname) {
                completion()
            }
        }
    }

    private func downloadProfileImage(email: String, filename: String, username: String, fullname: String, completion: @escaping () -> Void) {

        USER_PROFILE.child(filename).downloadURL { [weak self] url, error in
            guard let self = self else { return }

            if let error = error {
                print("프로필 이미지 다운로드 실패", error.localizedDescription)
                return
            }

            guard let profileImageUrl = url?.absoluteString else { return }

            print("프로필 이미지 다운로드 성공 \(profileImageUrl)")
            self.saveDatabase(email: email, profileImageUrl: profileImageUrl, fullname: fullname, username: username) {
                completion()
            }
        }
    }

    private func saveDatabase(email: String, profileImageUrl: String, fullname: String, username: String, completion: @escaping () -> Void) {

        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        let values: [String: Any] = [
            "email": email,
            "uid": currentUid,
            "profileImageUrl": profileImageUrl,
            "userName": username,
            "fullName": fullname
        ]

        USER_REF.child(currentUid).updateChildValues(values) { error, ref in


            if let error = error {
                print("디비 저장 실패", error.localizedDescription)
                return
            }

            print("디비 저장 성공")
            completion()
        }
    }

    func login(email: String, password: String, completion: @escaping CompletionHandler) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ 로그인 실패:", error.localizedDescription)
                completion(.failure(error))
                return
            }
            print("✅ 로그인 성공")
            completion(.success(()))
        }
    }

    func logout(completion: @escaping CompletionHandler) {
        do {
            try Auth.auth().signOut()
            print("✅ 로그아웃 성공")
            completion(.success(()))
        } catch {
            print("❌ 로그아웃 실패:", error.localizedDescription)
            completion(.failure(error))
        }
    }

}
