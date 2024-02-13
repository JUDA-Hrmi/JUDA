//
//  PostReportButton.swift
//  JUDA
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

// MARK: - 신고하기 버튼
struct PostReportButton: View {
	@Binding var reportContents: [ReportContent]
	@Binding var isReportDialogPresented: Bool
	
    var body: some View {
		Button {
            // TODO: - 신고 데이터 서버에 보내기
			isReportDialogPresented = true
		} label: {
			Text("신고하기")
				.font(.medium20)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 5)
		}
		.buttonStyle(.borderedProminent)
		.tint(.mainAccent03)
		// 체크박스가 하나라도 체크가 돼있지 않다면 버튼 비활성화
		.disabled(reportContents.filter { $0.check }.count > 0 ? false : true)
		.padding(.bottom, 10)
    }
}
