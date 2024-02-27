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
    // (dirnkID, (drinkData, rating)) 튜플 형태의 선택한 술 Data
    @Published var selectedDrinkTag: DrinkTag?
    // [drinkID: (drinkData, rating)] 딕셔너리 형태의 태그된 모든 술 Data
    @Published var drinkTags: [DrinkTag] = []
    // 라이브러리에서 선택된 모든 사진 Data
    @Published var images: [UIImage] = []
    // 선택된 모든 사진 Data의 ID를 갖는 배열
    var imagesURL: [URL] = []
    // 글 내용을 담는 프로퍼티
    @Published var content: String = ""
    // 음식 태그를 담는 배열
    @Published var foodTags: [String] = []
    // 화면 너비 받아오기
	var windowWidth: CGFloat {
		TagHandler.getScreenWidthWithoutPadding(padding: 20)
	}
    // post 업로드 완료 확인 및 로딩 뷰 출력용 프로퍼티
    @Published var isPostUploadSuccess = false
    
    // Firestore connection
    private let db = Firestore.firestore()
    
    // FireStorage 기본 경로
    private let storage = Storage.storage()
    private let drinkImagesPath = "drinkImages/"
}

// MARK: - FirebaseStorage Image Upload
extension RecordViewModel {
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

	func uploadMultipleImagesToFirebaseStorageAsync(_ imagesData: [Data]) async throws {
		// 여러 이미지 업로드를 동시에 처리하기 위한 비동기 작업 배열
		var uploadTasks: [Task<(Int, URL), Error>] = []
		
		// 각 이미지 데이터에 대해 비동기 업로드 작업 생성 및 배열에 추가
		for (index, imageData) in imagesData.enumerated() {
			let uploadTask = Task { try await uploadImageToFirebaseStorageAsync(imageData, index: index) }
			uploadTasks.append(uploadTask)
		}

		// 모든 업로드 작업이 완료될 때까지 기다린 후 결과 URL 배열 반환
		return try await withThrowingTaskGroup(of: (Int, URL).self, body: { group in
			var downloadURLs: [(Int, URL)] = []
			
			// 각 업로드 작업을 TaskGroup에 추가
			for task in uploadTasks {
				group.addTask {
					// Task의 결과를 반환
					try await task.value
				}
			}
			
			// TaskGroup의 모든 결과를 수집
			for try await downloadURL in group {
				downloadURLs.append(downloadURL)
			}

			downloadURLs.sort(by: { $0.0 < $1.0 })
			self.imagesURL = downloadURLs.map { $0.1 }
		})
	}

	func uploadImageToFirebaseStorageAsync(_ imageData: Data, index: Int) async throws -> (Int, URL) {
		let storageRef = Storage.storage().reference()
		let imageID = UUID().uuidString  // 고유한 이미지 ID 생성
		let imageRef = storageRef.child("postImages/\(imageID).jpg")

		let metadata = StorageMetadata()
		metadata.contentType = "image/jpg"
		
		// 이미지 업로드
		let _ = try await imageRef.putDataAsync(imageData, metadata: metadata)
		
		// 업로드된 이미지의 URL 가져오기
		let downloadURL = try await imageRef.downloadURL()
		
		return (index, downloadURL)
	}
}

// MARK: - Firestore Post Upload & Drink Update
extension RecordViewModel {
    // Firestore post data upload
    func uploadPost() async {
		guard let post = post, let userID = post.userField.userID else {
			print("uploadPost() :: error -> don't get post & post's userID")
			return
		}
        // posts documentID uuid 지정
        let postDocumentPath = UUID().uuidString
        let postRef = db.collection("posts")
		let userPostRef = db.collection("users").document(userID).collection("posts")
//		await firebaseUploadPost(ref: userPostRef, documentPath: postDocumentPath)
        let references: [CollectionReference] = [postRef, userPostRef]
        
        // 동일한 post collection data를 갖는 collection(posts, users/posts)에 data upload
        for reference in references {
            await firebaseUploadPost(ref: reference, documentPath: postDocumentPath)
        }
        
        // 동일한 drink collection data를 갖는 collection(posts/drinkTags/drink, drinks)에 data update
		await updateDrinkDataWithTag(documentPath: postDocumentPath, userID: userID)
    }
    
    // Firestore posts collection upload
    func firebaseUploadPost(ref: CollectionReference, documentPath: String) async {
        guard let post = post else { return }
        do {
            // posts collection field data upload
            try ref.document(documentPath).setData(from: post.postField)
            // drinkTags collection data upload in posts collection
			for drinkTag in drinkTags {
				guard let drinkID = drinkTag.drink.drinkID else {
					print("firebaseUploadPost() :: error -> don't get drinkID")
					continue
				}
				try await ref.document(documentPath).collection("drinkTags").document(drinkID).setData(["rating": drinkTag.rating])
				try ref.document(documentPath).collection("drinkTags").document(drinkID).collection("drink").document(drinkID).setData(from: drinkTag.drink)
			}
            
            // user collection data upload in posts collection
            try ref.document(documentPath)
                .collection("user")
				.document(post.userField.userID ?? "")
                .setData(from: post.userField)
            
        } catch {
            print("error :: post upload fail")
        }
    }
    
    // claculate rating data when user upload post with drinkTag
    func calcDrinkRating(prev: Double, new: Double, count: Int) -> Double {
        return (prev * Double(count) + new) / (Double(count) + 1)
    }
    
    // Firestore drink collection update
	func updateDrinkDataWithTag(documentPath: String, userID: String) async {
        // drinks
        let drinkRef = db.collection("drinks")
        // posts/drinkTags/drink
        let drinkTagRef = db.collection("posts").document(documentPath).collection("drinkTags")
		// users/posts/drinkTags/drink
		let userPostDrinkTagRef = db.collection("users").document(userID).collection("posts").document(documentPath).collection("drinkTags")
        
        do {
            for drinkTag in drinkTags {
				guard let post = post, let drinkID = drinkTag.drink.drinkID else { return }
				var updateData: [String: Any] = [:]
				// drink 정보를 바탕으로 update
				let drinkData = try await drinkRef.document(drinkID).getDocument(as: FBDrink.self)
				// rating이 4보다 큰 경우
				// agePreference, genderPreference
				if drinkTag.rating >= 4 {
					let userAge: Int = post.userField.age / 10 * 10
					let stringUserAge = String(userAge < 20 ? 20 : userAge)
					let userGender = post.userField.gender
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
				let new = drinkTag.rating
				let count = drinkData.taggedPostID.count
				let rating = calcDrinkRating(prev: prev, new: new, count: count)
				
				// taggedPostID
				var taggedPostID = drinkData.taggedPostID
				taggedPostID.append(documentPath)
				
				updateData["rating"] = rating
				updateData["taggedPostID"] = taggedPostID
				
				// drink data(agePreference, genderPreference, rating, taggedPostId) update in drinks, posts collection(posts/drinkTags)
				try await drinkRef.document(drinkID).updateData(updateData)
				try await drinkTagRef.document(drinkID).collection("drink").document(drinkID).updateData(updateData)
				try await userPostDrinkTagRef.document(drinkID).collection("drink").document(drinkID).updateData(updateData)
            }
        } catch {
            print("update error")
        }
    }
	
	func recordPostDataClear() {
		self.post = nil
		self.selectedDrinkTag = nil
		self.drinkTags = []
		self.images = []
		self.imagesURL = []
		self.content = ""
		self.foodTags = []
	}
}

// MARK: Post Modify
extension RecordViewModel {
	
}
