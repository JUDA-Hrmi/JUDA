//
//  RecordView.swift
//  JUDA
//
//  Created by 정인선 on 1/29/24.
//

import SwiftUI

// MARK: - 술상 기록 타입 : 작성 or 수정
enum RecordType {
    case add, edit
}

// 음식 태그 데이터 모델
struct FoodTag: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
}

// MARK: - 술상 기록 화면
struct RecordView: View {
    // Navigation을 위한 환경 프로퍼티
    @Environment(\.dismiss) private var dismiss
    // 기록 타입 ( 작성 or 수정 )
    let recordType: RecordType
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
    // 글 작성 or 수정 기준 충족 ( 글 내용 필수 )
    @State private var isPostContent: Bool = false
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                // MARK: iOS 16.4 이상
                if #available(iOS 16.4, *) {
                    ScrollView {
                        RecordContent(recordType: recordType, images: $images, content: $content,
                                      foodTags: $foodTags, windowWidth: $windowWidth,
                                      isFocusedTextEditor: $isFocusedTextEditor, isFocusedTextField: $isFocusedTextField,
                                      textField: textField, proxy: proxy)
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                    // 스크롤 했을 때, 키보드 사라지기
                    .scrollDismissesKeyboard(.immediately)
                    .scrollIndicators(.hidden)
                    // 탭했을 때, focus 상태 변경
                    .onTapGesture {
                        if isFocusedTextEditor {
                            isFocusedTextEditor = false
                        }
                        if isFocusedTextField {
                            isFocusedTextField = false
                        }
                    }
                } else {
                    ScrollView {
                        RecordContent(recordType: recordType, images: $images, content: $content,
                                      foodTags: $foodTags, windowWidth: $windowWidth,
                                      isFocusedTextEditor: $isFocusedTextEditor, isFocusedTextField: $isFocusedTextField,
                                      textField: textField, proxy: proxy)
                    }
                    // 스크롤 했을 때, 키보드 사라지기
                    .scrollDismissesKeyboard(.immediately)
                    .scrollIndicators(.hidden)
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
            }
            .task {
                windowWidth = TagHandler.getScreenWidthWithoutPadding(padding: 20)
            }
        }
        // 글 내용 유무 체크
        .onAppear {
            isPostContentNotEmpty()
        }
        // 글 내용 유무 체크
        .onChange(of: content) { _ in
            isPostContentNotEmpty()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .foregroundStyle(.mainBlack)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    // TODO: 술상 저장 후, 작성 or 수정 하기 전에 있었던 화면으로 이동 (path 조절)
                } label: {
                    Text("완료")
                        .font(.regular16)
                }
                .foregroundStyle(isPostContent ? .mainBlack : .gray01)
                .disabled(!isPostContent)
            }
        }
    }
    
    private func isPostContentNotEmpty() {
        let trimmedString = content.trimmingCharacters(in: .whitespacesAndNewlines) // 공백 + 개행문자 제외
        self.isPostContent = !trimmedString.isEmpty
    }
}

// MARK: - 술상 기록 화면에 보여줄 내용
struct RecordContent: View {
    let recordType: RecordType
    // 선택된 사진들을 담은 배열 (더미 데이터는 Assets을 사용하기 위해 작성)
    @Binding var images: [String]
    // TextEditor으로 작성될 글 내용
    @Binding var content: String
    // 음식 태그 배열
    @Binding var foodTags: [FoodTag]
    // 화면 너비
    @Binding var windowWidth: CGFloat
    // TextEditor focus 상태 프로퍼티
    var isFocusedTextEditor: FocusState<Bool>.Binding
    // TextField focus 상태 프로퍼티
    var isFocusedTextField: FocusState<Bool>.Binding
    // VStack에 id 값을 부여하기 위한 네임스페이스
    var textField: Namespace.ID
    // TextEditor에서 사용되는 placeholder
    private let placeholder = """
                             사진에 대해 설명해주세요.
                             음식과 함께 마신 술은 어땠나요?
                             """
    let proxy: ScrollViewProxy
    
    var body: some View {
        LazyVStack {
            // 선택된 사진들을 보여주는 가로 Scroll View
            SelectedPhotoHorizontalScroll(images: $images)
            // 글 작성 TextEditor
            TextEditor(text: $content)
            // TextEditor에 Text를 오버레이하여 placeholder로 보여줌
                .overlay(alignment: .topLeading) {
                    // content가 입력됐을 때, placeholder "" 처리
                    Text(content.isEmpty ? placeholder : "")
                        .font(.regular16)
                        .padding(.leading, 6)
                        .padding(.top, 10)
                        .foregroundStyle(.gray01)
                        .onTapGesture {
                            // 오버레이 된 Text를 탭할 시, TextEditor focus 상태 변경
                            isFocusedTextEditor.wrappedValue = true
                        }
                }
                .font(.regular16)
                .frame(height: 300)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .scrollIndicators(.hidden)
                .focused(isFocusedTextEditor)
                .textInputAutocapitalization(.never) // 자동 대문자 설정 기능 비활성화
                .autocorrectionDisabled() // 자동 수정 비활성화
            //
            CustomDivider()
                .padding(.vertical, 10)
            // 음식 태그
            VStack {
                HStack(alignment: .lastTextBaseline) {
                    Text("음식 태그")
                        .font(.semibold18)
                    Text("(최대 10개)")
                        .font(.medium14)
                        .foregroundStyle(.gray01)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 5)
                // 음식 태그 추가 TextField
                FoodTagAddTextField(foodTags: $foodTags, textField: textField, isFocusedTextField: isFocusedTextField, proxy: proxy)
                // 추가된 음식 태그를 보여주는 하단부
                FoodTagVertical(foodTags: $foodTags, windowWidth: windowWidth)
            }
            .padding(.bottom, 5)
            // ScrollView focusing을 위한 VStack에 id 부여
            .id(textField)
        }
    }
}

#Preview {
    RecordView(recordType: RecordType.add)
}

