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
    // TextEditor focus 상태 프로퍼티
    @FocusState private var isFocusedTextEditor: Bool
    // TextField focus 상태 프로퍼티
    @FocusState private var isFocusedTextField: Bool
    // VStack에 id 값을 부여하기 위한 네임스페이스
    @Namespace private var textField
    // Navigation을 위한 환경 프로퍼티
    @Environment(\.dismiss) private var dismiss
    // TextEditor에서 사용되는 placeholder
    private let placeholder = """
                    사진에 대해 설명해주세요.
                    음식과 함께 마신 술은 어땠나요?
                    """
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
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
                                .onTapGesture {
                                    // 오버레이 된 Text를 탭할 시, TextEditor focus 상태 변경
                                    isFocusedTextEditor = true
                                }
                            
                        }
                        .frame(height: 300)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .scrollIndicators(.hidden)
                        .focused($isFocusedTextEditor)
                    
                    CustomDivider()
                        .padding(.vertical, 10)
                    
                    VStack {
                        HStack {
                            Text("음식 태그")
                                .font(.semibold18)
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 5)
                        
                        // 음식 태그 추가 TextField
                        FoodTagAddTextField(foodTags: $foodTags, textField: textField, isFocusedTextField: $isFocusedTextField, proxy: proxy)
                        // 추가된 음식 태그를 보여주는 Scroll View
                        FoodTagVertical(foodTags: $foodTags, windowWidth: windowWidth)
                    }
                    .padding(.bottom, 5)
                    // ScrollView focusing을 위한 VStack에 id 부여
                    .id(textField)
                }
                // 스크롤 했을 때, 키보드 사라지기
                .scrollDismissesKeyboard(.automatic)
                // 탭했을 때, focus 상태 변경
                .onTapGesture {
                    if isFocusedTextEditor {
                        isFocusedTextEditor = false
                    }
                    if isFocusedTextField {
                        isFocusedTextField = false
                    }
                }
            }
            .task {
                let scenes = UIApplication.shared.connectedScenes
                let windowScene = scenes.first as? UIWindowScene
                let window = windowScene?.windows.first
                windowWidth = (window?.screen.bounds.width ?? 0) - 40
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // AddTagView로 돌아가기
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    // TODO: PostDetailView로 이동
                } label : {
                    Text("완료")
                }
            }
        }
        .foregroundStyle(.mainBlack)
    }
}

#Preview {
    WritingView()
}
