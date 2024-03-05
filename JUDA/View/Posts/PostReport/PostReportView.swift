//
//  PostReportView.swift
//  JUDA
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

struct ReportContent: Hashable {
	let id = UUID()
	var content: String
	var check: Bool
}


// MARK: - 술상 신고 화면
struct PostReportView: View {
	@EnvironmentObject private var postsViewModel: PostsViewModel
	@EnvironmentObject private var authService: AuthService
	
	let post: Post
	
    @State private var reportContents: [ReportContent] = [
        ReportContent(content: "욕설 및 비하", check: false),
        ReportContent(content: "장난 및 도배", check: false),
        ReportContent(content: "상업적 광고 및 판매", check: false),
        ReportContent(content: "선정적인 게시물", check: false),
        ReportContent(content: "게시판 성격에 부적절함", check: false),
        ReportContent(content: "기타 (하단 내용 작성)", check: false)
    ]
    @State private var etcReportText = ""
    @State private var isReportDialogPresented = false
    
    @Namespace var textCount
    
    @Binding var isReportPresented: Bool
	
	@FocusState var isFocused: Bool
		
	var body: some View {
		ZStack {
			VStack {
				VStack {
					// Title과 X버튼을 보여주는 toolbar
					PostReportToolbar(isReportPresented: $isReportPresented)
					// 타이틀 + 내용
					ScrollView {
						VStack(alignment: .leading, spacing: 5) {
                            // 신고 타이틀
							PostReportTitle()
							// 신고하기 뷰에서의 메인 내용 보여주는 뷰
							PostReportContent(reportContents: $reportContents,
											  etcReportText: $etcReportText,
											  isFocused: _isFocused)
						}
					}
					.scrollIndicators(.hidden)
					.scrollDismissesKeyboard(.immediately)
					.onTapGesture {
						// 다른 뷰를 탭했을 경우 Focusing 해제
						isFocused = false
					}
				}
				// 신고하기 버튼
				PostReportButton(reportContents: $reportContents, isReportDialogPresented: $isReportDialogPresented)
			}
			.padding(.horizontal, 20)
			.onAppear {
				// TextEditor에 기본적으로 들어가있는 백그라운드 컬러를 .clear로 변경
				// TextEditor에 내가 원하는 백그라운드 컬러를 주기 위함.
				UITextView.appearance().backgroundColor = .clear
			}
			.onDisappear() {
				postsViewModel.report = nil
			}
			// 신고 다이얼로그
			if isReportDialogPresented {
                CustomDialog(type: .twoButton(
                    message: "신고하시겠습니까?",
                    leftButtonLabel: "취소",
                    leftButtonAction: {
                        isReportDialogPresented = false},
                    rightButtonLabel: "신고",
                    rightButtonAction: {
						// TODO: report upload
						guard let postID = post.postField.postID else {
							print("ReportDialog:: rightButtonAction() error -> dot't get postID")
							return
						}
						let contents: [String] = reportContents.filter { $0.check }.map { $0.content }
						
						postsViewModel.report = Report(postID: postID, contents: contents,
													   etcReportText: etcReportText,
                                                       reportedUserID: authService.currentUser?.userID ?? "", reportedTime: Date())
						
						postsViewModel.postReportUpload()
                        isReportDialogPresented = false
                        isReportPresented = false
                    })
                 )
			}
		}
	}
}

//#Preview {
//	PostReportView(isReportPresented: .constant(false))
//}
