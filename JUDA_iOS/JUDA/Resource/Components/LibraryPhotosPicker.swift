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
