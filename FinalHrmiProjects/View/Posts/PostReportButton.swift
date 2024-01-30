//
//  PostReportButton.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

struct PostReportButton: View {
	
	@Binding var reportContents: [ReportContent]
	@Binding var isReportDialogPresented: Bool
	
    var body: some View {
		Button {
			isReportDialogPresented = true
		} label: {
			Text("신고하기")
				.font(.medium20)
				.frame(maxWidth: .infinity)
				.padding(.vertical, 5)
		}
		.buttonStyle(.borderedProminent)
		.tint(.mainAccent03)
		.disabled(reportContents.filter { $0.check }.count > 0 ? false : true)
		.padding(.bottom, 10)
    }
}

//#Preview {
//    PostReportButton()
//}
