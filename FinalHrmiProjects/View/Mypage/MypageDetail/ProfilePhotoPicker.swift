//
//  PhotoPicker.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/30.
//

import SwiftUI
import PhotosUI

// MARK: - PHPickerViewController 로, 앨범에서 사진 고르기 사용
struct ProfilePhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedPhoto: UIImage?
    @Binding var isLibraryPresented: Bool

    class Coordinator: PHPickerViewControllerDelegate {
        private let parent: ProfilePhotoPicker
        
        init(_ parent: ProfilePhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let result = results.first {
                let itemProvider = result.itemProvider
                guard itemProvider.canLoadObject(ofClass: UIImage.self) else { return }
                _ = itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.parent.selectedPhoto = image
                        }
                    }
                }
            }
            parent.isLibraryPresented = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = PHPickerFilter.any(of: [.images])
        configuration.selectionLimit = 1 // 한 장만 선택 가능하도록 설정
        configuration.preferredAssetRepresentationMode = .current
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // Update logic if needed
    }
}
