//
//  PostReportToolbar.swift
//  JUDA
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

// MARK: - 신고하기 화면 상단 바
struct PostReportToolbar: View {
	@Binding var isReportPresented: Bool
	
    var body: some View {
		ZStack(alignment: .trailing) {
			Text("신고하기")
				.font(.regular16)
				.frame(maxWidth: .infinity)
			// 신고하기 화면 닫기 버튼
			Button {
				isReportPresented = false
			} label: {
				Image(systemName: "xmark")
					.font(.medium16)
			}
		}
		.foregroundStyle(.mainBlack)
		.padding(.vertical, 10)
    }
}

#Preview {
	PostReportToolbar(isReportPresented: .constant(true))
}
