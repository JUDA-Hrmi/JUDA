//
//  LibraryPhotosPicker.swift
//  JUDA
//
//  Created by phang on 2/6/24.
//

import SwiftUI
import PhotosUI

// MARK: - SwiftUI PhotosPicker 사용, 앨범에서 사진 고르기
struct LibraryPhotosPicker<Content: View>: View {
    @Binding var selectedPhotos: [PhotosPickerItem]
    var maxSelectionCount: Int = 1 // default: 1
    let content: () -> Content
    
    var body: some View {
        PhotosPicker(selection: $selectedPhotos,
                     maxSelectionCount: maxSelectionCount,
                     selectionBehavior: .default,
                     matching: .images,
                     photoLibrary: .shared()) {
            content()
        }
    }
}

// MARK: - UIKit PHPickerViewController사용, 앨범에서 사진 고르기
//struct LibraryPhotosPicker: UIViewControllerRepresentable {
//    @Binding var selectedPhotos: [UIImage?]
//    @Binding var isLibraryPresented: Bool
//    let selectionLimit: Int
//    var remainingSpaces: Int = 1 // default: 1
//
//
//    class Coordinator: PHPickerViewControllerDelegate {
//        private let parent: LibraryPhotoPicker
//
//        init(_ parent: LibraryPhotoPicker) {
//            self.parent = parent
//        }
//
//        // TODO: 선택된 사진 체크표시
//        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
//            for (idx, result) in results.enumerated() {
//                let itemProvider = result.itemProvider
//                guard itemProvider.canLoadObject(ofClass: UIImage.self) else { continue }
//                _ = itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
//                    if let image = image as? UIImage {
//                        DispatchQueue.main.async {
//                            self.parent.selectedPhotos[self.parent.selectionLimit - self.parent.remainingSpaces + idx] = image
//                        }
//                    }
//                }
//            }
//            parent.isLibraryPresented = false
//        }
//    }
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    func makeUIViewController(context: Context) -> PHPickerViewController {
//        var configuration = PHPickerConfiguration(photoLibrary: .shared())
//        configuration.filter = PHPickerFilter.any(of: [.images])
//        configuration.selectionLimit = remainingSpaces
//        configuration.preferredAssetRepresentationMode = .current
//        let controller = PHPickerViewController(configuration: configuration)
//        controller.delegate = context.coordinator
//        return controller
//    }
//
//    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
//        //
//    }
//}
