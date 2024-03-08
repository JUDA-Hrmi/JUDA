//
//  FireStorageService.swift
//  JUDA
//
//  Created by 정인선 on 3/7/24.
//

import SwiftUI
import FirebaseStorage

// MARK: - Fire Storage 의 폴더 타입 / 폴더 명
enum FireStorageFolderType: String {
    case user = "userImages"
    case post = "postImages"
    case drink = "drinkImages"
}

// MARK: - Fire Storage 에 접근하는 함수를 갖는 Service
@MainActor
final class FireStorageService {
    private let storageRef = Storage.storage().reference()
    private let imageType = "image/jpg"

    // FireStorage 에 이미지 올리기
    func uploadImageToStorage(folder: FireStorageFolderType, image: UIImage, fileName: String) async throws {
        do {
            let storageRoute = storageRef.child("\(folder.rawValue)/\(fileName)")
            let data = Formatter.compressImage(image)
            let metaData = StorageMetadata()
            metaData.contentType = imageType
            guard let data = data else { return }
            let _ = try await storageRoute.putDataAsync(data, metadata: metaData)
        } catch {
            throw FireStorageError.uploadImage
        }
    }
    
    // URL 받아오기
    func fetchImageURL(folder: FireStorageFolderType, fileName: String) async throws -> URL {
        do {
            let storageRoute = storageRef.child("\(folder.rawValue)/\(fileName)")
            let url = try await storageRoute.downloadURL()
            return url
        } catch {
            throw FireStorageError.fetchImageURL
        }
    }
}

// MARK: - 파이어스토리지에 관련 이미지 데이터 삭제 로직
extension FireStorageService {
    // firestorage에서 이미지 삭제
    func deleteFireStorageImage(folder: FireStorageFolderType, imageURL: URL) async {
        do {
            // 이미지 storage에서 삭제
            let fileName = try getImageFileName(imageURL: imageURL)
            let storageRoute = storageRef.child("\(folder.rawValue)/\(fileName)")
            try await storageRoute.delete()
        } catch FireStorageError.getFileName {
            print("error :: getImageFileName() -> get image file name failure")
        } catch {
            print("error :: deleteFireStorageImage() -> delete image in fireStorage failure")
            print(error.localizedDescription)
        }
    }
    
    // fileName 추출
    private func getImageFileName(imageURL: URL) throws -> String {
        let path = imageURL.path
        // '%' 인코딩된 문자 디코딩
        // 디코딩 실패 시, error throw
        guard let decodedPath = path.removingPercentEncoding else {
            throw FireStorageError.getFileName
        }
        // '/'를 기준으로 문자열 분리 후 마지막 요소 추출 후 리턴
        // fileName 추출 실패 시, error throw
        guard let fileName = decodedPath.components(separatedBy: "/").last else {
            throw FireStorageError.getFileName
        }
        return fileName
    }
}
