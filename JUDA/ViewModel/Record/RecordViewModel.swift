//
//  RecordViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

final class RecordViewModel: ObservableObject { 
    //
    @Published var post: Post
    
    private var drinks: [String: FBDrink] = [:]
    @Published var searchDrinks: [String: FBDrink] = [:]
    
    @Published var images: [UIImage] = []
    private var imagesID: [String] = []
    
    @Published var isPostUploadSuccess: Bool?
    
    init(post: Post) {
        self.post = post
    }
}

// MARK: - Search Drink
extension RecordViewModel {
    @MainActor
    func fetchDrinkData() async {
        let db = Firestore.firestore()
        
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
    
    @MainActor
    func searchTagDrinks(keyword: String) async {
        searchDrinks = [:]
        for drink in drinks {
            if drink.value.name.contains(keyword) {
                searchDrinks[drink.key] = drink.value
            }
        }
    }
}

// MARK: - FirebaseStorage Image Upload
extension RecordViewModel {
    func multipleImageUpload() async {
        for image in images {
            let imagesID = UUID().uuidString
            self.imagesID.append(imagesID)
            await imageUpload(image: image, imageID: imagesID)
        }
    }
    
    func imageUpload(image: UIImage, imageID: String) async {
        let storageRef = Storage.storage().reference().child("postImages/\(imageID).jpg")
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

// MARK: - Firestore Post Upload
extension RecordViewModel {
    func uploadPost() async {
        let db = Firestore.firestore()
        let postDocumentPath = UUID().uuidString
        let postRef = db.collection("posts")
        let userPostRef = db.collection("users").document(post.user.0).collection("posts")
        let references: [CollectionReference] = [postRef, userPostRef]
        
        for reference in references {
            await firebaseUploadPost(ref: reference, documentPath: postDocumentPath)
        }
    }
    
    func firebaseUploadPost(ref: CollectionReference, documentPath: String) async {
        do {
            try ref.document(documentPath).setData(from: post.postField)
            print(post.tagDrinks)
            for tagDrink in post.tagDrinks.map({ ($0.key, $0.value) }) {
                print(tagDrink)
                try await ref.document(documentPath).collection("tagDrinks").document(tagDrink.0).setData(["rating": tagDrink.1.rating])
                try ref.document(documentPath).collection("tagDrinks").document(tagDrink.0).collection("drink").document(tagDrink.0).setData(from: tagDrink.1.tagDrink)
            }
            
            try ref.document(documentPath)
                .collection("user")
                .document(post.user.0)
                .setData(from: post.user.1)

        } catch {
            print("error :: post upload fail")
        }
    }
    
}
