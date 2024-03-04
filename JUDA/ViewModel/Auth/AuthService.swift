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
import GoogleSignIn
import AuthenticationServices

// MARK: 가입 / 로그인 타입
enum SignInType {
    case apple
    case google
    case none
}

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
	@Published var likedPosts = [String]()
    @Published var likedDrinks = [String]()
    @Published var signInType: SignInType = .none
    // Error
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    // 로딩 중
    @Published var isLoading: Bool = false
    // Nonce : 암호와된 임의의 난수
    private var currentNonce: String?
	// Firestore - db 연결
	private let db = Firestore.firestore()
    private let userCollection = "users"
    // Storage
    private let storage = Storage.storage()
    private let userImages = "userImages"
    private let userImageType = "image/jpg"
    private var listener: ListenerRegistration?
    
    // 로그아웃 및 탈퇴 시, 초기화
    private func reset() {
        self.signInStatus = false
        self.isLoading = false
        self.isNewUser = false
        self.uid = ""
        self.name = ""
        self.age = 0
        self.gender = ""
        self.profileImage = nil
        self.notificationAllowed = false
        self.likedPosts = []
        self.likedDrinks = []
    }
    
    // 로그아웃
    func signOut() {
        do {
			try Auth.auth().signOut()
			reset()
        } catch {
            print("Error signing out: ", error.localizedDescription)
            errorMessage = "로그아웃에 문제가 발생했어요.\n다시 시도해주세요."
            showError = true
        }
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
				
				// TODO: 파이어스토어 데이터 삭제 로직 구현
				await userDataDeleteWithFirestore()
                
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
            
            try await user.delete()
            reset()
            return true
        } catch {
            print("deleteAccount error : \(error.localizedDescription)")
            errorMessage = "회원탈퇴에 문제가 발생했어요.\n다시 시도해주세요."
            showError = true
            isLoading = false
            return false
        }
    }
    
    // 유저 좋아하는 술 리스트에 추가 or 삭제
    func addOrRemoveToLikedDrinks(isLiked: Bool, _ drinkID: String?) {
        guard let drinkID = drinkID else {
            print("addOrRemoveToLikedDrinks - 술 ID 없음")
            return
        }
        if !isLiked { // 좋아요 X -> O
            likedDrinks.removeAll { $0 == drinkID }
        } else { // 좋아요 O -> X
            if !likedDrinks.contains(drinkID) {
                likedDrinks.append(drinkID)
            }
        }
    }
}

// MARK: - 회원탈퇴 시, 파이어스토어에 관련 데이터 삭제 로직
extension AuthService {
	/*
	users - posts -postID를 얻고
	post 관련 이미지 파이어스토리지에서 삭제
	posts 삭제
	전체 drinks - taggedPostID 삭제
	 */
	func userDataDeleteWithFirestore() async {
		do {
            let userPostsRef = self.db.collection(userCollection).document(uid).collection("posts")
			let drinksRef = db.collection("drinks")
			let postsRef = db.collection("posts")
			
			let userPostsDocuments = try await userPostsRef.getDocuments()
			
			// 비동기 작업을 위한 태스크 배열
			var tasks: [Task<Void, Error>] = []
			
			for postDocument in userPostsDocuments.documents {
				tasks.append(Task {
					try await handlePostDeletion(postDocument: postDocument, userPostsRef: userPostsRef, postsRef: postsRef, drinksRef: drinksRef)
				})
			}
			
			// 모든 태스크 완료 대기
			for task in tasks {
				try await task.value
			}
			
		} catch {
			print(error.localizedDescription)
		}
	}

	// 포스트 삭제를 처리하는 함수
	func handlePostDeletion(postDocument: DocumentSnapshot, userPostsRef: CollectionReference, postsRef: CollectionReference, drinksRef: CollectionReference) async throws {
		let postID = postDocument.documentID
		if let postImagesURL = postDocument.data()?["imagesURL"] as? [URL] {
			await postImagesURLDelete(postRef: postsRef, imagesURL: postImagesURL, postID: postID)
		}
		
		var drinkTagsID: [String] = []
		let userPostTagDrinksDocuments = try await userPostsRef.document(postID).collection("drinkTags").getDocuments()
		for userPostTagDrinkDocument in userPostTagDrinksDocuments.documents {
			drinkTagsID.append(userPostTagDrinkDocument.documentID)
		}
		
		await postsCollectionPostDelete(postRef: userPostsRef, postID: postID)
		await postsCollectionPostDelete(postRef: postsRef, postID: postID)
		await postTaggedDrinkRootCollectionUpdate(drinkRef: drinksRef, drinkTagsID: drinkTagsID, postID: postID)
		await allPostsSubCollectionDrinkUpdate(postRef: postsRef, postID: postID)
	}

	
//	func userDataDeleteWithFirestore() async {
//		do {
//			let userPostsRef = self.collectionRef.document(uid).collection("posts")
//			let drinksRef = db.collection("drinks")
//			let postsRef = db.collection("posts")
//			
//			let userPostsDocuments = try await userPostsRef.getDocuments()
//			for postDocument in userPostsDocuments.documents {
//				// postID 얻기
//				let postID = postDocument.documentID
//				// 해당 게시글의 사진 URL들 받아오기
//				let postImagesURL = postDocument.data()["imagesURL"] as! [URL]
//				// 게시글 사진들 firestorage 에서 삭제
//				await postImagesURLDelete(postRef: postsRef, imagesURL: postImagesURL, postID: postID)
//				
//				
//				var drinkTagsID = [String]()
//				let userPostTagDrinksDocuments = try await userPostsRef.document(postID).collection("drinkTags").getDocuments()
//				for userPostTagDrinkDocument in userPostTagDrinksDocuments.documents {
//					drinkTagsID.append(userPostTagDrinkDocument.documentID)
//				}
//				// 유저 컬렉션의 포스트 문서 삭제
//				await postsCollectionPostDelete(postRef: userPostsRef, postID: postID)
//				// 포스트 컬렉션 문서 삭제
//				await postsCollectionPostDelete(postRef: postsRef, postID: postID)
//				// post의 tagDrinks인 root drinks collection taggedPost에서 postID 있으면 제거 후 업데이트
//				await postTaggedDrinkRootCollectionUpdate(drinkRef: drinksRef, drinkTagsID: drinkTagsID, postID: postID)
//				// 전체 posts collection sub collection인 drink 업데이트
//				await allPostsSubCollectionDrinkUpdate(postRef: postsRef, postID: postID)
//			}
//		} catch {
//			print(error.localizedDescription)
//		}
//	}
	
	func postsCollectionPostDelete(postRef: CollectionReference, postID: String) async {
		do {
			try await postRef.document(postID).delete()
		} catch {
			print("postsCollectionPostDelete error \(error.localizedDescription)")
		}
	}
	
	// post의 tagDrinks인 root drinks collection taggedPost에서 postID 있으면 제거 후 업데이트
	func postTaggedDrinkRootCollectionUpdate(drinkRef: CollectionReference, drinkTagsID: [String], postID: String) async {
		do {
			for drinkID in drinkTagsID {
				var taggedPostsID = try await drinkRef.document(drinkID).getDocument().data()?["taggedPostID"] as! [String]
				taggedPostsID.removeAll(where: { $0 == postID })
				try await drinkRef.document(drinkID).updateData(["taggedPostID": taggedPostsID])
			}
		} catch {
			print("postTaggedDataUpdate error \(error.localizedDescription)")
		}
	}
	
	// 전체 posts collection sub collection인 drink 업데이트
	func allPostsSubCollectionDrinkUpdate(postRef: CollectionReference, postID: String) async {
		do {
			let postsDocument = try await postRef.getDocuments()
			for postDocument in postsDocument.documents {
				let postDocumentID = postDocument.documentID
				let drinkTagsDocument = try await postDocument.reference.collection("drinkTags").getDocuments()
				
				for drinkTagDocument in drinkTagsDocument.documents {
					let drinkTagID = drinkTagDocument.documentID
					var taggedPostsID = try await drinkTagDocument
						.reference.collection("drink")
						.document(drinkTagID)
						.getDocument()
						.data()?["taggedPostID"] as! [String]
					
					taggedPostsID.removeAll(where: { $0 == postID })
					
					try await postRef.document(postDocumentID)
						.collection("drinkTags")
						.document(drinkTagID)
						.collection("drink")
						.document(drinkTagID)
						.updateData(["taggedPostID": taggedPostsID])
				}
			}
		} catch {
			print("allPostsSubCollectionDrinkUpdate error \(error.localizedDescription)")
		}
	}
	
	func postImagesURLDelete(postRef: CollectionReference, imagesURL: [URL], postID: String) async {
		do {
			// TODO: 이미지 storage에서 삭제
			let storageRef = Storage.storage().reference()
			
			for imageURL in imagesURL {
				if let fileName = getImageFileName(imageURL: imageURL) {
					let imageRef = storageRef.child("postImages/\(fileName)")
					try await imageRef.delete()
				} else {
					print("postImagesURLDelete() -> error dont't get fileName")
				}
			}
		} catch {
			print("postImagesURLDelete() -> error \(error.localizedDescription)")
		}
	}
	
	// fileName 추추
	func getImageFileName(imageURL: URL) -> String? {
		let path = imageURL.path
		// '%' 인코딩된 문자 디코딩
		guard let decodedPath = path.removingPercentEncoding else { return nil }
		// '/'를 기준으로 문자열 분리 후 마지막 요소 추출 후 리턴
		return decodedPath.components(separatedBy: "/").last
	}
}

// MARK: - 닉네임 수정 버튼 클릭 -> 닉네임 업데이트
extension AuthService {
    func updateUserName(uid: String, userName: String) {
        let docRef = db.collection(userCollection).document(uid)

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
        if let user = try? documentSnapshot.data(as: UserField.self) {
            // 해당 사용자의 데이터를 업데이트
            self.uid = uid
            self.name = user.name
            self.age = user.age
            self.gender = user.gender
            self.likedPosts = user.likedPosts ?? []
            self.likedDrinks = user.likedDrinks ?? []
        }
    }
    
    func startListeningForUser() {
		guard !uid.isEmpty else { return }
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

// MARK: - firestore : 유저 정보 불러오기 & 유저 저장 & 유저 업데이트
extension AuthService {
    // firestore 에 유저 존재 유무 체크
    func checkNewUser(uid: String) async -> Bool {
        do {
            let document = try await db.collection(userCollection).document(uid).getDocument()
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
            let document = try await db.collection(userCollection).document(uid).getDocument(source: .cache)
            if document.exists {
                let userData = try document.data(as: UserField.self)
                self.uid = uid
                self.name = userData.name
                self.age = userData.age
                fetchProfileImage()
                self.gender = userData.gender
                self.notificationAllowed = userData.notificationAllowed
                self.likedDrinks = userData.likedDrinks ?? []
                self.likedPosts = userData.likedPosts ?? []
            } else {
                print("Document does not exist")
            }
        } catch {
            print("Error getting document: \(error)")
        }
    }
    
    // firestore 에 유저 저장
    func addUserDataToStore(userData: UserField) {
        do {
            try db.collection(userCollection).document(self.uid).setData(from: userData)
            print("Success - 유저 정보 저장")
        } catch {
            print("유저 정보 저장 에러 : \(error.localizedDescription)")
        }
    }
    
    // 유저 정보 업데이트 - post
    func userLikedPostsUpdate() {
        db.collection(userCollection).document(self.uid).updateData(["likedPosts": self.likedPosts]) { error in
            if let error = error {
                print("update error \(error.localizedDescription)")
            }
        }
    }
    
    // 유저 정보 업데이트 - drink
    func userLikedDrinksUpdate() {
        db.collection(userCollection).document(self.uid).updateData(["likedDrinks": self.likedDrinks]) { error in
            if let error = error {
                print("update error \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - firestorage
// 유저 가입 시, 프로필 이미지 생성 & 받아오기
extension AuthService {
    func compressImage(_ image: UIImage) -> Data? {
        let maxHeight: CGFloat = 1024.0
        let maxWidth: CGFloat = 1024.0
        let compressionQuality: CGFloat = 0.2

        var actualHeight: CGFloat = image.size.height
        var actualWidth: CGFloat = image.size.width
        var imgRatio: CGFloat = actualWidth / actualHeight
        let maxRatio: CGFloat = maxWidth / maxHeight

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                // 세로 길이를 기준으로 크기 조정
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                // 가로 길이를 기준으로 크기 조정
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: actualWidth, height: actualHeight), false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: actualWidth, height: actualHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let resizedImageData = resizedImage?.jpegData(compressionQuality: compressionQuality) else { return nil }
        return resizedImageData
    }
    
    // storage 에 유저 프로필 이미지 올리기
    func uploadProfileImageToStorage(image: UIImage?) {
        guard let image = image else { 
            print("error - uploadProfileImageToStorage : image X")
            return
        }
        let storageRef = storage.reference().child("\(userImages)/\(self.uid)")
        let data = compressImage(image)
        let metaData = StorageMetadata()
        metaData.contentType = userImageType
        if let data = data {
            storageRef.putData(data, metadata: metaData) { (metaData, error) in
                guard let _ = metaData, error == nil else {
                    print("Error Profile Image Upload -> \(String(describing: error?.localizedDescription))")
                    return
                }
            }
            print("uploadProfileImageToStorage : \(self.uid)-profileImage)")
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
}

// MARK: - SignInWithAppleButton : request & result
extension AuthService {
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                print("error: appleIDCredential")
                return
            }
            let fullName = appleIDCredential.fullName
            self.name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
            Task {
                // 로그인 중 -
                isLoading = true
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
                signInType = .apple
            }
        case .failure(let failure):
            reset()
            errorMessage = "로그인에 문제가 발생했어요.\n다시 시도해주세요."
            showError = true
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

// MARK: - Sign in With Google
extension AuthService {
    func signInWithGoogle() async {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No Firebase Client ID")
        }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        //get rootView
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController else {
            fatalError("There is no root view controller!")
        }
        do {
            //google sign in authentication response
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            )
            let user = result.user
            guard let idToken = user.idToken?.tokenString else {
                print("Unexpected error occurred, please retry")
                errorMessage = "Unexpected error occurred, please retry"
                return
            }
            //Firebase auth
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken, accessToken: user.accessToken.tokenString
            )
            // 로그인 중 -
            isLoading = true
            // sign in
            try await Auth.auth().signIn(with: credential)
            // 신규 유저 체크
            isNewUser = await checkNewUser(uid: Auth.auth().currentUser?.uid ?? "")
            // 신규 유저
            if isNewUser {
                self.isNewUser = true
                print("Fisrt ✨ - Google Sign Up 🤖")
            } else {
                print("Google Sign In 🤖")
                await fetchUserData()
                self.signInStatus = true
            }
            signInType = .google
        } catch {
            print("error - \(error.localizedDescription)")
            errorMessage = "로그인에 문제가 발생했어요.\n다시 시도해주세요."
            showError = true
            reset()
        }
    }
}
