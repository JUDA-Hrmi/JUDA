//
//  RecordViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

final class RecordViewModel: ObservableObject { 
    // post 업로드용 Post 모델 객체
    @Published var post: Post?
    // searchTagView에서 drink liked를 표시해주기 위한 drinkID를 갖는 배열
    @Published var userLikedDrinksID: [String] = []
    // [drinkID: drinkData] 딕셔너리 형태의 술 전체 Data
    private var drinks: [String: FBDrink] = [:]
    // [drinkID: drinkData] 딕셔너리 형태의 검색된 술 결과 Data
    @Published var searchDrinks: [String: FBDrink] = [:]
    // (dirnkID, (drinkData, rating)) 튜플 형태의 선택한 술 Data
    @Published var selectedDrinkTag: (String, DrinkTag)?
    // [drinkID: (drinkData, rating)] 딕셔너리 형태의 태그된 모든 술 Data
    @Published var drinkTags: [String: DrinkTag] = [:]
    // 라이브러리에서 선택된 모든 사진 Data
    @Published var images: [UIImage] = []
    // 선택된 모든 사진 Data의 ID를 갖는 배열
    var imagesID: [String] = []
    // 글 내용을 담는 프로퍼티
    @Published var content: String = ""
    // 음식 태그를 담는 배열
    @Published var foodTags: [String] = []
    // 화면 가로 길이를 담는 프로퍼티
    var windowWidth: CGFloat = 0
    // post 업로드 완료 확인 및 로딩 뷰 출력용 프로퍼티
    @Published var isPostUploadSuccess = false
    
    // Firestore connection
    private let db = Firestore.firestore()
}

// MARK: - User Data Fetch
extension RecordViewModel {
    // users likedDrinks drink ID fetch
    @MainActor
    func fetchUserLikedDrinksID(uid: String) async {
        do {
            let userRef = db.collection("users")
            userLikedDrinksID = try await userRef.document(uid).getDocument(as: UserField.self).likedDrinks ?? []
        } catch {
            print("fetch UserLikedDrinksID error")
        }
    }
}

// MARK: - Search Drink
extension RecordViewModel {
    // drinks collection all data fetch
    @MainActor
    func fetchDrinkData() async {
        do {
            let drinkSnapshot = try await db.collection("drinks").getDocuments()
            
            for document in drinkSnapshot.documents {
                let drinkData = try document.data(as: FBDrink.self)
                self.drinks[document.documentID] = drinkData
            }
        } catch {
            print("Drink Fetch Error")
        }
    }
    
    // all drink data filtering with search
    @MainActor
    func searchDrinkTags(text: String) async {
        searchDrinks = [:]
        for drink in drinks {
            if drink.value.name.contains(text) {
                searchDrinks[drink.key] = drink.value
            }
        }
    }
}

// MARK: - FirebaseStorage Image Upload
extension RecordViewModel {
    // get imageID & FirebaseStorage multiple image data upload
    func multipleImageUpload() async {
        for image in images {
            let imagesID = UUID().uuidString
            self.imagesID.append(imagesID)
            await imageUpload(image: image, imageID: imagesID)
        }
    }
    
    // FirebaseStorage single image data upload
    func imageUpload(image: UIImage, imageID: String) async {
        // 생성한 uuid를 image 파일명으로 설정
        let storageRef = Storage.storage().reference().child("postImages/\(imageID).jpg")
        // 이미지 압축
        let data = image.jpegData(compressionQuality: 0.2)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        
        if let data = data {
            let uploadTask = storageRef.putData(data, metadata: metadata) { (metadata, error) in
                guard let metadata = metadata, error == nil else {
                    print("Error while uploading fule:", error!)
                    return
                }
                print("Metadata:", metadata)
            }
            uploadTask.observe(.failure) { _ in
                print("upload failure :: \(imageID)")
            }
            uploadTask.observe(.success) { _ in
                print("upload success :: \(imageID)")
            }
        }
    }
}

// MARK: - Firestore Post Upload & Drink Update
extension RecordViewModel {
    // Firestore post data upload
    func uploadPost() async {
        guard let post = post else { return }
        // posts documentID uuid 지정
        let postDocumentPath = UUID().uuidString
        let postRef = db.collection("posts")
        let userPostRef = db.collection("users").document(post.user.0).collection("posts")
        let references: [CollectionReference] = [postRef, userPostRef]
        
        // 동일한 post collection data를 갖는 collection(posts, users/posts)에 data upload
        for reference in references {
            await firebaseUploadPost(ref: reference, documentPath: postDocumentPath)
        }
        
        // 동일한 drink collection data를 갖는 collection(posts/drinkTags/drink, drinks)에 data update
        await updateDrinkDataWithTag(documentPath: postDocumentPath)
    }
    
    // Firestore posts collection upload
    func firebaseUploadPost(ref: CollectionReference, documentPath: String) async {
        guard let post = post else { return }
        do {
            // posts collection field data upload
            try ref.document(documentPath).setData(from: post.postField)
            // drinkTags collection data upload in posts collection
            for drinkTag in post.drinkTags.map({ ($0.key, $0.value) }) {
                try await ref.document(documentPath).collection("drinkTags").document(drinkTag.0).setData(["rating": drinkTag.1.rating])
                try ref.document(documentPath).collection("drinkTags").document(drinkTag.0).collection("drink").document(drinkTag.0).setData(from: drinkTag.1.drinkTag)
            }
            
            // user collection data upload in posts collection
            try ref.document(documentPath)
                .collection("user")
                .document(post.user.0)
                .setData(from: post.user.1)
            
        } catch {
            print("error :: post upload fail")
        }
    }
    
    // claculate rating data when user upload post with drinkTag
    func calcDrinkRating(prev: Double, new: Double, count: Int) async -> Double {
        return (prev * Double(count) + new) / (Double(count) + 1)
    }
    
    // Firestore drink collection update
    func updateDrinkDataWithTag(documentPath: String) async {
        // drinks
        let drinkRef = db.collection("drinks")
        // posts/drinkTags/drink
        let drinkTagRef = db.collection("posts").document(documentPath).collection("drinkTags")
        
        do {
            for drink in drinkTags.map({ ($0.0, $0.1) }) {
                if let post = post {
                    var updateData: [String: Any] = [:]
                    // drink 정보를 바탕으로 update
                    let drinkData = try await drinkRef.document(drink.0).getDocument(as: FBDrink.self)
                    // rating이 4보다 큰 경우
                    // agePreference, genderPreference
                    if drink.1.rating >= 4 {
                        let userAge: Int = post.user.1.age / 10 * 10
                        let stringUserAge = String(userAge < 20 ? 20 : userAge)
                        let userGender = post.user.1.gender
                        // agePreference + 1
                        var agePreference = drinkData.agePreference
                        agePreference[stringUserAge] = (agePreference[stringUserAge] ?? 0) + 1
                        // genderPreference + 1
                        var genderPreference = drinkData.genderPreference
                        genderPreference[userGender] = (genderPreference[userGender] ?? 0) + 1

                        updateData["agePreference"] = agePreference
                        updateData["genderPreference"] = genderPreference
                    }
                    // rating
                    let prev = drinkData.rating
                    let new = drink.1.rating
                    let count = drinkData.taggedPostID.count
                    let rating = await calcDrinkRating(prev: prev, new: new, count: count)
                    
                    // taggedPostID
                    var taggedPostID = drinkData.taggedPostID
                    taggedPostID.append(documentPath)
                    
                    updateData["rating"] = rating
                    updateData["taggedPostID"] = taggedPostID
                    
                    // drink data(agePreference, genderPreference, rating, taggedPostId) update in drinks, posts collection(posts/drinkTags)
                    try await drinkRef.document(drink.0).updateData(updateData)
                    try await drinkTagRef.document(drink.0).collection("drink").document(drink.0).updateData(updateData)
                }
            }
        } catch {
            print("update error")
        }
    }
}
