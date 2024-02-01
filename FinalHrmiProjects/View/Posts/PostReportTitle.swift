//
//  PostReportTitle.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

struct PostReportTitle: View {
    var body: some View {
		VStack {
			HStack {
				Text("게시글을 신고하는")
					.font(.medium18)
				Spacer()
			}
			HStack {
				Text("이유를 알려주세요!")
					.font(.medium18)
				Spacer()
			}
		}
		Text("타당한 근거 없이 신고된 내용은 관리자 확인 후 반영되지 않을 수 있습니다.")
			.font(.thin12)
    }
}

#Preview {
    PostReportTitle()
}
