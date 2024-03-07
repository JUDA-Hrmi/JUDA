//
//  FirestorageAuthViewModel.swift
//  JUDA
//
//  Created by phang on 3/4/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

// MARK: - Firebase : Auth
@MainActor
final class FirestorageAuthViewModel {
    // Storage
    private let storage = Storage.storage()
    private let userImages = "userImages"
    private let userImageType = "image/jpg"    
}

// MARK: - firestorage
// 유저 가입 시, 프로필 이미지 생성 & 받아오기
extension FirestorageAuthViewModel {
    // storage 에 유저 프로필 이미지 올리기
    func uploadProfileImageToStorage(image: UIImage, uid: String) async throws {
        let storageRef = storage.reference().child("\(userImages)/\(uid)")
        let data = Formatter.compressImage(image)
        let metaData = StorageMetadata()
        metaData.contentType = userImageType
        guard let data = data else { return }
        let _ = try await storageRef.putDataAsync(data, metadata: metaData)
    }
    
    // 유저 프로필 URL 받아오기
    func fetchProfileImageURL(uid: String) async throws -> URL {
        let storageRef = storage.reference().child("\(userImages)/\(uid)")
        let url = try await storageRef.downloadURL()
        return url
    }
}

// MARK: - 회원탈퇴 시, 파이어스토리지에 관련 데이터 삭제 로직
extension FirestorageAuthViewModel {
    // 유저와 관련된 post 이미지 삭제
    func postImagesURLDelete(postRef: CollectionReference, imagesURL: [URL], postID: String) async {
        do {
            // 이미지 storage에서 삭제
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
    
    // fileName 추출
    func getImageFileName(imageURL: URL) -> String? {
        let path = imageURL.path
        // '%' 인코딩된 문자 디코딩
        guard let decodedPath = path.removingPercentEncoding else { return nil }
        // '/'를 기준으로 문자열 분리 후 마지막 요소 추출 후 리턴
        return decodedPath.components(separatedBy: "/").last
    }
}
