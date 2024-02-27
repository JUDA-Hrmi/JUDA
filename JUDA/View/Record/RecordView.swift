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

// MARK: - 술상 기록 화면
struct RecordView: View {
    // Navigation을 위한 환경 프로퍼티
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var auth: AuthService
    @EnvironmentObject private var recordViewModel: RecordViewModel
	@EnvironmentObject private var postsViewModel: PostsViewModel
	@EnvironmentObject private var searchPostsViewModel: SearchPostsViewModel
    // 기록 타입 ( 작성 or 수정 )
    let recordType: RecordType
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
                        RecordContent(recordType: recordType, isFocusedTextEditor: $isFocusedTextEditor,
                                      isFocusedTextField: $isFocusedTextField,
                                      textField: textField, proxy: proxy)
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                    // 스크롤 했을 때, 키보드 사라지기
                    .scrollDismissesKeyboard(.immediately)
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
                        RecordContent(recordType: recordType, isFocusedTextEditor: $isFocusedTextEditor,
                                      isFocusedTextField: $isFocusedTextField,
                                      textField: textField, proxy: proxy)
                    }
                    // 스크롤 했을 때, 키보드 사라지기
                    .scrollDismissesKeyboard(.immediately)
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
        }
        // post upload 여부에 따라 loadingView 표시
        .loadingView($recordViewModel.isPostUploadSuccess)
        // 글 내용 유무 체크
        .onAppear {
            isPostContentNotEmpty()
        }
        // 글 내용 유무 체크
        .onChange(of: recordViewModel.content) { _ in
            isPostContentNotEmpty()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    navigationRouter.back()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .foregroundStyle(.mainBlack)
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if isFocusedTextEditor {
                        isFocusedTextEditor = false
                    }
                    if isFocusedTextField {
                        isFocusedTextField = false
                    }
					DispatchQueue.main.async {
						Task {
							await postUploadButtonAction()
							await postReFetch()
                            navigationRouter.clear()
						}
					}
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
        let trimmedString = recordViewModel.content.trimmingCharacters(in: .whitespacesAndNewlines) // 공백 + 개행문자 제외
        self.isPostContent = !trimmedString.isEmpty
    }
	
	private func postUploadButtonAction() async {
		do {
			// loadingView 띄우기
			recordViewModel.isPostUploadSuccess = true
			// FirevaseStorage multiple image upload
			let imagesData = recordViewModel.images.compactMap { recordViewModel.compressImage($0) }  // 압축된 이미지 데이터 배열
			
			// 여러 이미지 업로드
			try await recordViewModel.uploadMultipleImagesToFirebaseStorageAsync(imagesData)
			// 다운로드 URL 사용
			print("Download URLs: \(recordViewModel.imagesURL)")
			
			// post 데이터 모델 객체 생성
			recordViewModel.post = Post(userField: UserField(userID: auth.uid ,name: auth.name, age: auth.age, gender: auth.gender, notificationAllowed: auth.notificationAllowed),
										drinkTags: recordViewModel.drinkTags,
										postField: PostField(imagesURL: recordViewModel.imagesURL, content: recordViewModel.content,
															 likedCount: 0, postedTimeStamp: Date(), foodTags: recordViewModel.foodTags))
			// post upload
			await recordViewModel.uploadPost()
			
			await searchPostsViewModel.fetchPosts()
			// loadingView 없애기
			recordViewModel.isPostUploadSuccess = false
		} catch {
			print("Error uploading images: \(error)")
		}
	}
	
	private func postReFetch() async {
		postsViewModel.isLoading = true
		postsViewModel.posts = []
		postsViewModel.postImagesURL = [:]
		postsViewModel.postThumbnailImagesURL = [:]
		let postSortType = postsViewModel.postSortType[postsViewModel.selectedSegmentIndex]
		let query = postsViewModel.getPostSortType(postSortType: postSortType)
		await postsViewModel.firstFetchPost(query: query)
	}
}

// MARK: - 술상 기록 화면에 보여줄 내용
struct RecordContent: View {
    @EnvironmentObject private var recordViewModel: RecordViewModel
    // post add/edit
    let recordType: RecordType
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
            SelectedPhotoHorizontalScroll()
            // 글 작성 TextEditor
            TextEditor(text: $recordViewModel.content)
            // TextEditor에 Text를 오버레이하여 placeholder로 보여줌
                .overlay(alignment: .topLeading) {
                    // content가 입력됐을 때, placeholder "" 처리
                    Text(recordViewModel.content.isEmpty ? placeholder : "")
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
                FoodTagAddTextField(textField: textField, isFocusedTextField: isFocusedTextField, proxy: proxy)
                // 추가된 음식 태그를 보여주는 하단부
                FoodTagVertical()
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

