//
//  PostReportView.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

struct ReportContent: Hashable {
	let id = UUID()
	var content: String
	var check: Bool
}
// TODO: Firebase 데이터 연결
struct PostReportView: View {
	
	@Binding var isReportPresented: Bool
	
	@State private var reportContents: [ReportContent] = [
		ReportContent(content: "욕설 및 비하", check: false),
		ReportContent(content: "장난 및 도배", check: false),
		ReportContent(content: "상업적 광고 및 판매", check: false),
		ReportContent(content: "선정적인 게시물", check: false),
		ReportContent(content: "게시판 성격에 부적절함", check: false),
		ReportContent(content: "기타(하단 내용 작성)", check: false)
	]
	
	@State private var etcReportText = ""
	@State private var isReportDialogPresented = false
	
	@Namespace var textCount
	
	@FocusState var isFocused: Bool
	
	var body: some View {
		ZStack {
			VStack {
				VStack {
					// Title과 X버튼을 보여주는 toolbar
					PostReportToolbar(isReportPresented: $isReportPresented)
					
					ScrollView {
						VStack(alignment: .leading, spacing: 5) {
							PostReportTitle()
							
							// 신고하기 뷰에서의 메인 내용 보여주는 뷰
							PostReportContent(reportContents: $reportContents,
											  etcReportText: $etcReportText,
											  isFocused: _isFocused)
						}
						.onTapGesture {
							// 다른 뷰를 탭했을 경우 Focusing 해제
							isFocused = false
						}
					}
					.scrollIndicators(.hidden)
					.scrollDismissesKeyboard(.immediately)
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
			
			// 신고버튼을 탭 했을 시, 신고에 대한 다이얼로그 출력
			if isReportDialogPresented {
				CustomAlert(message: "신고하시겠습니까?", 
							leftButtonLabel: "취소",
							leftButtonAction: {
					isReportDialogPresented = false
				}, rightButtonLabel: "신고") {
					isReportDialogPresented = false
					isReportPresented = false
				}
			}
		}
	}
}

struct CheckBox: View {
	let isCheck: Bool
	var body: some View {
		Image(systemName: "checkmark.square.fill")
			.font(.medium36)
			.foregroundStyle(isCheck ? .mainAccent03 : .gray04)
	}
}

#Preview {
	PostReportView(isReportPresented: .constant(false))
}
