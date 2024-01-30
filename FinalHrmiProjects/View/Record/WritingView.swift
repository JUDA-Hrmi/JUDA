//
//  WritingView.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/29/24.
//

import SwiftUI

// 음식 태그 데이터 모델
struct FoodTag: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
}

struct WritingView: View {
    // 선택된 사진들을 담은 배열 (더미 데이터는 Assets을 사용하기 위해 작성)
    @State private var images: [String] = ["foodEx1", "foodEx2", "foodEx3", "foodEx4", "foodEx5"]
    // TextEditor으로 작성될 글 내용
    @State private var content: String = ""
    // 음식 태그 배열
    @State private var foodTags: [FoodTag] = []
    // 화면 너비
    @State private var windowWidth: CGFloat = 0
    // TextEditor에서 사용되는 placeholder
    private let placeholder = """
                    사진에 대해 설명해주세요.
                    음식과 함께 마신 술은 어땠나요?
                    """
    
    var body: some View {
        NavigationStack {
            // 선택된 사진들을 보여주는 Scroll View
            SelectedPhotoHorizontalScroll(images: $images)
            
            // 글 작성 TextEditor
            TextEditor(text: $content)
                // TextEditor에 Text를 오버레이하여 placeholder로 보여줌
                .overlay(alignment: .topLeading) {
                    // content가 입력됐을 때, placeholder "" 처리
                    Text(content.isEmpty ? placeholder : "")
                        .padding(.leading, 6)
                        .padding(.top, 10)
                        .foregroundStyle(.gray01)
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .scrollIndicators(.hidden)
            
            CustomDivider()
                .padding(.vertical, 10)
            
            HStack {
                Text("음식 태그")
                    .font(.semibold18)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 5)
            
            // 음식 태그 추가 TextField
            FoodTagAddTextField(foodTags: $foodTags)
            // 추가된 음식 태그를 보여주는 Scroll View
            FoodTagVerticalScroll(foodTags: $foodTags, windowWidth: windowWidth)

        }
        .task {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            windowWidth = (window?.screen.bounds.width ?? 0) - 40
        }
        .customNavigationBar(
            leadingView: {
                Button {
                    // TODO: AddTagView로 돌아가기
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.semibold18)
                }
            }, trailingView: [.trailing: {
                Button {
                    // TODO: 데이터 저장
                } label: {
                    Text("완료")
                        .font(.semibold18)
                }
            }
            ])
        .foregroundStyle(.mainBlack)
    }
}

#Preview {
    WritingView()
}
