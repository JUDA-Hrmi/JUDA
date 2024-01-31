//
//  NoticeView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/02/01.
//

import SwiftUI

struct NoticeView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            Text("공지사항 뷰입니다. ")
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // TODO: 뒤로가기
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .tint(.mainBlack)
            }
            ToolbarItem(placement: .principal) {
                Text("공지사항")
                    .font(.medium18)
                    .foregroundStyle(.mainBlack)
            }
        }
    }
}

#Preview {
    NoticeView()
}
