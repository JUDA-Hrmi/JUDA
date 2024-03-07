//
//  FirebaseUserViewModel.swift
//  JUDA
//
//  Created by phang on 3/6/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

// MARK: - Firebase : User
@MainActor
final class FirebaseUserViewModel {
    // Firestore - db 연결
    private let db = Firestore.firestore()
    private let userCollection = "users"
    private let postCollection = "posts"
    

    // 해당 유저가 작성한 posts 받아오기
    func fetchUserWrittenPosts(uid: String) async throws -> [Post] {
        let userWrittenPostRef = db.collection(userCollection).document(uid).collection(postCollection)
        var result = [Post]()
        let postDocuments = try await userWrittenPostRef.getDocuments()
        for postDocument in postDocuments.documents {
            let postFieldData = try postDocument.data(as: PostField.self)
            let postID = postFieldData.postID
        }
        // TODO: -
        return result
    }
    /*
     
     문제
     - User 에서 필요한 데이터 Post 를 가지려고 한다.
     - Post 를 기자려고 했더니, Post 는 User 가 필요하다.
     -> collection 의 순환 참조 발생
     
     해결 방안 ( User 가 Post 를 가질 것 인가 / Post 가 user 를 가질 것 인가 )
     
     1. User 가 Post 를 가질 때
     - Post 는 User 가 아닌 
        userID, profileURL, userName ( cell 에서 보여주는 최소한의 데이터 ) 를 갖게 됨
     - PostDetail 에서, MyPage( 유저 페이지 ) 로 이동 할 때, User 의 정보를 불러와야 함.
     
     2. Post 가 User 를 가질 때
     - User 는 Post 가 아닌
        postField + ( drinkTags, likedUsersID ) 를 갖게 됨.
     - MyPage( 유저 페이지 )에서 PostDetail 로 이동했을 때, Post 의 정보를 불러와야 함.
     
     그 외에도 Post 와 Drink 의 관계 / User 와 Drink 의 관계 등 정리를 해야하지 않을까 싶다.
     
     -> Phang's 생각
     User 가 Post 를 소유
     Post 가 Drink 를 소유
     이게 좀 뭔가 흐름에 맞지 않을까...?
     
     */
    
}
