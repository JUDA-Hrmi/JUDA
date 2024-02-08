//
//  PostReportContent.swift
//  JUDA
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

struct PostReportContent: View {
	@Binding var reportContents: [ReportContent]
	@Binding var etcReportText: String
	
	// FocusState 바인딩
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
						.font(.regular16)
				}
			}
		}
		.padding(.top, 20)
		.padding(.bottom, 20)
		
		ZStack(alignment: .bottomTrailing) {
			// 마지막 순서의 체크박스에 체크가 돼있지않다면 textEditor 비활성화
			// 마지막 순서의 체크박스에 체크가 돼있다면 textEditor 활성화
			if let check = reportContents.last?.check {
				TextEditor(text: $etcReportText)
					.scrollContentBackground(.hidden)
					.background(.gray06)
					.font(.regular16)
					.focused($isFocused)
					.disabled(check ? false : true)
					.clipShape(RoundedRectangle(cornerRadius: 10))
					.frame(height: 180)
					.textInputAutocapitalization(.never) // 자동 대문자 설정 기능 비활성화
			}
			Text("\(etcReportText.count) / 200")
				.font(.light14)
				.foregroundStyle(.gray01)
				.padding(10)
		}
		.onChange(of: reportContents.last?.check) { newValue in
			if let newValue = newValue {
				// 마지막 체크박스를 체크했을 시 TextEditor에 Focusing
				if newValue {
					isFocused = true
				} else {
					// 체크박스 해제 시 Focusing 해제
					isFocused = false
				}
			}
		}
		.onChange(of: etcReportText) { newValue in
			// 입력된 텍스트 수 200자 제한
			if etcReportText.count > 200 {
				etcReportText = String(etcReportText.prefix(200))
			}
		}
    }
}
