//
//  PostReportToolbar.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

struct PostReportToolbar: View {
	
	@Binding var isReportPresented: Bool
	
    var body: some View {
		ZStack(alignment: .trailing) {
			Text("신고하기")
				.font(.medium16)
				.frame(maxWidth: .infinity)
			
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
