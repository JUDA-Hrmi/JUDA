//
//  FirebaseAuthViewModel.swift
//  JUDA
//
//  Created by phang on 3/4/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import AuthenticationServices

// MARK: - Firebase : Auth
@MainActor
final class FirebaseAuthViewModel {
    // Firestore - db 연결
    private let db = Firestore.firestore()
    private let userCollection = "users"
    // 실시간 반영을 위한 리스너
    private var listener: ListenerRegistration?
    
    // firestore 에서 UserField 정보 가져오기
    func fetchUserFieldData(uid: String) async throws -> UserField {
        let document = try await db.collection(userCollection).document(uid).getDocument(source: .cache)
        let userData = try document.data(as: UserField.self)
        return userData
    }
    
    // firestore 에 유저 존재 유무 체크
    func isNewUser(uid: String) async -> Bool {
        do {
            let document = try await db.collection(userCollection).document(uid).getDocument()
            return !document.exists
        } catch {
            print("Error getting document: \(error)")
            return true
        }
    }
    
    // firestore 에서 유저 이름 변경
    func updateUserName(uid: String, userName: String) async throws {
        let docRef = db.collection(userCollection).document(uid)
        try await docRef.updateData(["name": userName])
    }
    
    // firestore 에 유저 저장
    func addUserDataToStore(userData: UserField, uid: String) {
        do {
            try db.collection(userCollection).document(uid).setData(from: userData)
            print("Success - 유저 정보 저장")
        } catch {
            print("유저 정보 저장 에러 : \(error.localizedDescription)")
        }
    }
    
    // 유저 정보 업데이트 - LikedPosts / LikedDrinks
    func userLikedListUpdate(uid: String, documentName: String, list: [Any]) {
        db.collection(userCollection).document(uid).updateData([documentName: list]) { error in
            if let error = error {
                print("update error \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - 데이터 실시간 업데이트
extension FirebaseAuthViewModel {
    //
    func startListeningForUser(uid: String, 
                               completion: @escaping (UserField?) -> Void) {
        let userRef = db.collection(userCollection).document(uid)
        // 기존에 활성화된 리스너가 있다면 삭제
        listener?.remove()
        // 새로운 리스너 등록
        listener = userRef.addSnapshotListener { [weak self] documentSnapshot, error in
            guard self != nil else { return }
            if let error = error {
                print("Error fetching user data: \(error)")
                completion(nil)
                return
            }
            if let documentSnapshot = documentSnapshot,
               let user = try? documentSnapshot.data(as: UserField.self) {
                completion(user)
            } else {
                completion(nil)
            }
        }
    }
}

// MARK: - 회원탈퇴 시, 파이어스토어에 관련 데이터 삭제 로직
extension FirebaseAuthViewModel {
    /*
    users - posts -postID를 얻고
    post 관련 이미지 파이어스토리지에서 삭제
    posts 삭제
    전체 drinks - taggedPostID 삭제
     */
    func userDataDeleteWithFirestore(uid: String) async {
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
        let firestoreAuthViewModel = FirestorageAuthViewModel()
        let postID = postDocument.documentID
        if let postImagesURL = postDocument.data()?["imagesURL"] as? [URL] {
            await firestoreAuthViewModel.postImagesURLDelete(postRef: postsRef, imagesURL: postImagesURL, postID: postID)
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

//    func userDataDeleteWithFirestore() async {
//        do {
//            let userPostsRef = self.collectionRef.document(uid).collection("posts")
//            let drinksRef = db.collection("drinks")
//            let postsRef = db.collection("posts")
//
//            let userPostsDocuments = try await userPostsRef.getDocuments()
//            for postDocument in userPostsDocuments.documents {
//                // postID 얻기
//                let postID = postDocument.documentID
//                // 해당 게시글의 사진 URL들 받아오기
//                let postImagesURL = postDocument.data()["imagesURL"] as! [URL]
//                // 게시글 사진들 firestorage 에서 삭제
//                await postImagesURLDelete(postRef: postsRef, imagesURL: postImagesURL, postID: postID)
//
//
//                var drinkTagsID = [String]()
//                let userPostTagDrinksDocuments = try await userPostsRef.document(postID).collection("drinkTags").getDocuments()
//                for userPostTagDrinkDocument in userPostTagDrinksDocuments.documents {
//                    drinkTagsID.append(userPostTagDrinkDocument.documentID)
//                }
//                // 유저 컬렉션의 포스트 문서 삭제
//                await postsCollectionPostDelete(postRef: userPostsRef, postID: postID)
//                // 포스트 컬렉션 문서 삭제
//                await postsCollectionPostDelete(postRef: postsRef, postID: postID)
//                // post의 tagDrinks인 root drinks collection taggedPost에서 postID 있으면 제거 후 업데이트
//                await postTaggedDrinkRootCollectionUpdate(drinkRef: drinksRef, drinkTagsID: drinkTagsID, postID: postID)
//                // 전체 posts collection sub collection인 drink 업데이트
//                await allPostsSubCollectionDrinkUpdate(postRef: postsRef, postID: postID)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
    
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
}


// MARK: - Apple
extension FirebaseAuthViewModel {
    // 로그인
    func signInApple(appleIDCredential: ASAuthorizationAppleIDCredential,
                     currentNonce: String?) async {
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
        } catch {
            print("Error authenticating: \(error.localizedDescription)")
        }
    }
    
    // 회원탈퇴 - Apple
    func deleteAccountWithApple() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthManagerError.noUser
        }
        let signInWithAppleHelper = SignInWithAppleHelper()
        let appleIDCredential = try await signInWithAppleHelper()
        
        guard let appleIDToken = appleIDCredential.identityToken else {
            print("ID 토큰 가져오지 못함")
            return
        }
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("데이터 -> 토큰 문자열 에러 : \(appleIDToken.debugDescription)")
            return
        }
        
        // TODO: 파이어스토어 데이터 삭제 로직 구현
        await userDataDeleteWithFirestore(uid: user.uid)
        
        let nonce = signInWithAppleHelper.randomNonceString()
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: idTokenString,
                                                  rawNonce: nonce)
        try await user.reauthenticate(with: credential)
        // 애플에서도 앱에 대한 로그인 토큰 삭제
        guard let authorizationCode = appleIDCredential.authorizationCode else { return }
        guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return }
        try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
        // 삭제
        try await user.delete()
    }
}

// MARK: - Google
extension FirebaseAuthViewModel { }
