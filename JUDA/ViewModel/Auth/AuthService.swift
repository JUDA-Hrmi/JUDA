//
//  AuthService.swift
//  JUDA
//
//  Created by phang on 2/13/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import CryptoKit
import AuthenticationServices

// MARK: - Auth (로그인, 로그아웃, 회원탈퇴) + 로그인 유저 데이터
@MainActor
final class AuthService: ObservableObject {
    // 로그인 유무
    @AppStorage("signInStatus") var signInStatus: Bool = false
    // 신규 유저 or 기존 유저
    @Published var isNewUser: Bool = false
    // User Data
    @Published var uid: String = ""
    @Published var name: String = ""
    @Published var age: Int = 0
    @Published var gender: String = ""
    @Published var profileImage: UIImage?
    @Published var notificationAllowed: Bool = false
    // Error
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    // 로그인 중
    @Published var signInButtonClicked: Bool = false
    // Nonce : 암호와된 임의의 난수
    private var currentNonce: String?
    // Firestore - users 컬렉션
    private let collectionRef = Firestore.firestore().collection("users")
    // Storage
    private let storage = Storage.storage()
    private let userImages = "userImages"
    private let userImageType = "image/jpg"
    private var listener: ListenerRegistration?
    
    // 로그아웃 및 탈퇴 시, 초기화
    func reset() {
        self.signInStatus = false
        self.isNewUser = false
        self.uid = ""
        self.name = ""
        self.age = 0
        self.gender = ""
        self.profileImage = nil
        self.notificationAllowed = false
    }
    
    // 로그아웃
    func signOut() {
        do {
          try Auth.auth().signOut()
        } catch {
            print("Error signing out: ", error.localizedDescription)
            errorMessage = error.localizedDescription
        }
        reset()
    }
    
    // 회원탈퇴 - Apple
    func deleteAccount() async -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        let needsTokenRevocation = user.providerData.contains { $0.providerID == "apple.com" }
        do {
            if needsTokenRevocation {
                let signInWithApple = SignInWithApple()
                let appleIDCredential = try await signInWithApple()
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("ID 토큰 가져오지 못함")
                    return false
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("데이터 -> 토큰 문자열 에러 : \(appleIDToken.debugDescription)")
                    return false
                }
                
                let nonce = randomNonceString()
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                try await user.reauthenticate(with: credential)
                // 애플에서도 앱에 대한 로그인 토큰 삭제
                guard let authorizationCode = appleIDCredential.authorizationCode else { return false }
                guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return false }
                try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
            }
            
            let uid = user.uid
            try await user.delete()
            deleteAccountData(uid: uid) // TODO: - Cloud Functions 을 통해서 지우는게 이상적
            await deleteUserProfileImage()
            reset()
            errorMessage = ""
            return true
        } catch {
            print("deleteAccount error : \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return false
        }
    }
}

// MARK: - 닉네임 수정 버튼 클릭 -> 닉네임 업데이트
extension AuthService {
    func updateUserName(uid: String, userName: String) {
        let docRef = collectionRef.document(uid)

        docRef.updateData(["name": userName]) { error in
            if let error = error {
                print(error)
            } else {
                print("Successed merged in:", uid)
            }
        }
    }
}

// MARK: - 데이터 실시간 업데이트
extension AuthService {
    private func updateUserFromSnapshot(_ documentSnapshot: DocumentSnapshot) {
            // 문서의 데이터를 가져와서 User로 디코딩
            if let user = try? documentSnapshot.data(as: User.self) {
                // 해당 사용자의 데이터를 업데이트
                self.uid = uid
                self.name = user.name
                self.age = user.age
                self.gender = user.gender

                print("User data updated: \(user)")
            }
        }
    
    func startListeningForUser(uid: String) {
            let userRef = Firestore.firestore().collection("users").document(uid)

            // 기존에 활성화된 리스너가 있다면 삭제
            listener?.remove()

            // 새로운 리스너 등록
            listener = userRef.addSnapshotListener { [weak self] documentSnapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching user data: \(error)")
                    return
                }

                // 사용자 데이터 업데이트 메서드 호출
                if let documentSnapshot = documentSnapshot {
                    self.updateUserFromSnapshot(documentSnapshot)
                }
            }
        }

}

// MARK: - firestore : 유저 정보 불러오기 & 유저 저장 & 유저 삭제
extension AuthService {
    // firestore 에 유저 존재 유무 체크
    func checkNewUser(uid: String) async -> Bool {
        do {
            let document = try await collectionRef.document(uid).getDocument()
            return !document.exists
        } catch {
            print("Error getting document: \(error)")
            return true
        }
    }

    // firestore 에서 유저 정보 가져오기
    func fetchUserData() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            reset()
            print("currentUser 없음")
            return
        }
        do {
            let document = try await collectionRef.document(uid).getDocument(source: .cache)
            if document.exists {
                let userData = try document.data(as: User.self)
                self.uid = uid
                self.name = userData.name
                self.age = userData.age
                fetchProfileImage()
                self.gender = userData.gender
                self.notificationAllowed = userData.notificationAllowed
                print("Data:", userData)
            } else {
                print("Document does not exist in cache")
            }
        } catch {
            print("Error getting document: \(error)")
        }
    }
    
    // firestore 에 유저 저장
    func addUserDataToStore(userData: User) {
        do {
            try collectionRef.document(self.uid).setData(from: userData)
            print("Success - 유저 정보 저장")
        } catch {
            print("유저 정보 저장 에러 : \(error.localizedDescription)")
        }
    }
    
    // firestore 에서 유저 데이터 삭제
    func deleteAccountData(uid: String) {
        collectionRef.document(uid).delete { error in
            if let error = error {
                print("deleteAccountData - firestore : \(error.localizedDescription)")
                return
            }
        }
    }
}

// MARK: - firestorage
// 유저 가입 시, 프로필 이미지 생성 & 받아오기
// 유저 탈퇴 시, 프로필 이미지 삭제
extension AuthService {
    // storage 에 유저 프로필 이미지 올리기
    func uploadProfileImageToStorage(image: UIImage?) {
        guard let image = image else { 
            print("error - uploadProfileImageToStorage : image X")
            return
        }
        let storageRef = storage.reference().child("\(userImages)/\(self.uid)")
        let data = image.jpegData(compressionQuality: 0.2)
        let metaData = StorageMetadata()
        metaData.contentType = userImageType
        if let data = data {
            storageRef.putData(data, metadata: metaData) { (metaData, error) in
                guard let _ = metaData, error == nil else {
                    print("Error Profile Image Upload -> \(String(describing: error?.localizedDescription))")
                    return
                }
            }
            print("uploadProfileImageToStorage : \(self.uid)-profileImag)")
            self.profileImage = image
        } else {
            print("error - uploadProfileImageToStorage : data X")
        }
    }
    
    // 유저 프로필 받아오기
    func fetchProfileImage() {
        let storageRef = storage.reference().child("\(userImages)/\(self.uid)")
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  error == nil else {
                print("Error getData -> \(String(describing: error))")
                return
            }
            self.profileImage = image
        }
    }
    
    // 프로필 이미지 삭제
    func deleteUserProfileImage() async {
        let storageRef = storage.reference().child("\(userImages)/\(self.uid)")
        do {
            try await storageRef.delete()
        } catch {
            print("프로필 이미미 삭제 에러 - \(error.localizedDescription)")
        }
    }
}

// MARK: - SignInWithAppleButton : request & result
extension AuthService {
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        signInButtonClicked = true
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>, appViewModel: AppViewModel) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                print("error: appleIDCredential")
                return
            }
            let fullName = appleIDCredential.fullName
            self.name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
            Task {
                // 로그인
                await singInApple(appleIDCredential: appleIDCredential)
                // 신규 유저 체크
                isNewUser = await checkNewUser(uid: Auth.auth().currentUser?.uid ?? "")
                // 신규 유저
                if isNewUser {
                    signOut()
                    self.isNewUser = true
                    print("Fisrt ✨ - Apple Sign Up 🍎")
                } else {
                    print("Apple Sign In 🍎")
                    await fetchUserData()
                    self.signInStatus = true
                }
            }
        case .failure(let failure):
            reset()
            errorMessage = failure.localizedDescription
        }
    }
    
    func singInApple(appleIDCredential: ASAuthorizationAppleIDCredential) async {
        guard let nonce = currentNonce else {
            fatalError("Invalid state: a login callback was received, but no login request was sent.")
        }
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("Unable to fetdch identify token.")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
            return
        }
        let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                       rawNonce: nonce,
                                                       fullName: appleIDCredential.fullName)
        do {
            let _ = try await Auth.auth().signIn(with: credential)
            guard let uid = Auth.auth().currentUser?.uid else {
                print("currentUser 없음")
                return
            }
            self.uid = uid
        } catch {
            print("Error authenticating: \(error.localizedDescription)")
        }
    }
}

// MARK: - Apple Sign In Helper
extension AuthService {
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("nonce 생성 에러 : \(errorCode)")
                }
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData
            .compactMap { String(format: "%02x", $0) }
            .joined()
      return hashString
    }
}

// MARK: - Sign in with Apple (reauth)
final class SignInWithApple: NSObject, ASAuthorizationControllerDelegate {
    private var continuation : CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?
    
    func callAsFunction() async throws -> ASAuthorizationAppleIDCredential {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
            continuation?.resume(returning: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}
