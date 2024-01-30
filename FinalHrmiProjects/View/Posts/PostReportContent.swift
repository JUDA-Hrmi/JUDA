//
//  PostReportContent.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

struct PostReportContent: View {
	
	@Binding var reportContents: [ReportContent]
	@Binding var etcReportText: String
	
	@FocusState var isFocused: Bool
	
    var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			ForEach(reportContents.indices, id: \.self) { index in
				HStack(spacing: 5) {
					CheckBox(isCheck: reportContents[index].check)
						.onTapGesture {
							reportContents[index].check.toggle()
						}
					Text(reportContents[index].content)
						.font(.light18)
				}
			}
		}
		.padding(.top, 20)
		.padding(.bottom, 20)
		
		ZStack(alignment: .bottomTrailing) {
			if let check = reportContents.last?.check {
				TextEditor(text: $etcReportText)
					.scrollContentBackground(.hidden)
					.background(.gray06)
					.focused($isFocused)
					.disabled(check ? false : true)
					.clipShape(RoundedRectangle(cornerRadius: 10))
					.frame(height: 180)
			}
			Text("\(etcReportText.count) / 200")
				.font(.light14)
				.foregroundStyle(.gray01)
				.padding(10)
		}
    }
}

//#Preview {
//    PostReportContent()
//}
