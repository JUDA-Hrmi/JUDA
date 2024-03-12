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
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var recordViewModel: RecordViewModel
    @EnvironmentObject private var drinkViewModel: DrinkViewModel
    @EnvironmentObject private var postViewModel: PostViewModel
	
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
    // post 업로드 완료 확인 및 로딩 뷰 출력용 프로퍼티
    @State private var isPostUploading: Bool = false
    
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
        .loadingView($isPostUploading)
        // 글 내용 유무 체크
        .onAppear {
            isPostContentNotEmpty()
            // TODO: recordType에 따라 recordView에 값 띄워주기
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
                            switch recordType {
                            case .add:
                                // post images upload, post upload
                                await postUploadButtonAction()
                                // TODO: Post ReFetch
//                                await postReFetch()
                                // TODO: User posts ReFetch
    //                            await myPageViewModel.getUsersPosts(userID: authService.currentUser?.userID ?? "", userType: .user)
                                
                                // 업로드 후, post 객체 clear
                                recordViewModel.recordPostDataClear()
                                navigationRouter.clear()

                            case .edit:
                                // TODO: post update
                                // TODO: Post ReFetch
                                // TODO: User posts ReFetch
                                
                                // 업데이트 후, post 객체 clear
                                recordViewModel.recordPostDataClear()
                                navigationRouter.clear()

                            }
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
        // TODO: recordType에 따라 upload, update
        // loadingView 띄우기
        isPostUploading = true
        // writtenUser 모델 객체 생성
        guard let user = authViewModel.currentUser?.userField, let userID = user.userID else { return }
        recordViewModel.writtenUser = WrittenUser(userID: userID,
                                                  userName: user.name,
                                                  userAge: user.age,
                                                  userGender: user.gender,
                                                  userProfileImageURL: user.profileImageURL)
        
        // firestroage에 이미지 업로드 후 url 받아오기
        await recordViewModel.uploadMultipleImagesToFirebaseStorageAsync()
        
        // post 데이터 모델 객체 생성
        if let writtenUser = recordViewModel.writtenUser {
            recordViewModel.post = Post(postField: PostField(user: writtenUser,
                                                             drinkTags: recordViewModel.drinkTags,
                                                             imagesURL: recordViewModel.imagesURL,
                                                             content: recordViewModel.content,
                                                             foodTags: recordViewModel.foodTags,
                                                             postedTime: Date()),
                                        likedUsersID: [])
            
            // post 업로드
            await recordViewModel.uploadPost()
        }
        
        // MARK: - search를 위한 전체 post fetch 필요한가?
        //			await searchPostsViewModel.fetchPosts()
        // loadingView 없애기
        isPostUploading = false
	}
    	
    // EX
//	private func postReFetch() async {
//		postsViewModel.isLoading = true
//		postsViewModel.posts = []
//		postsViewModel.postImagesURL = [:]
//		postsViewModel.postThumbnailImagesURL = [:]
//		let postSortType = postsViewModel.postSortType[postsViewModel.selectedSegmentIndex]
//		let query = postsViewModel.getPostSortType(postSortType: postSortType)
//		await postsViewModel.firstFetchPost(query: query)
//	}
    
    // MARK: - NEW post Refetch
//    private func postReFetch() async {
//        postViewModel.isLoading = true
//        postViewModel.posts = []
//        let postSortType = postViewModel.getPostSortType(postSortType: <#T##PostSortType#>)
//        let query = postViewModel.getPostSortType(postSortType: postSortType)
//        await postViewModel.firstFetchPost(query: query)
//    }
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

//#Preview {
//    RecordView(recordType: RecordType.add)
//}

