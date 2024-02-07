//
//  Errors.swift
//  FinalHrmiProjects
//
//  Created by phang on 2/7/24.
//

import Foundation

// MARK: - PhotosPicker 에서 이미지 로드 실패 에러
enum PhotosPickerImageLoadingError: Error {
    case invalidImageData
}
