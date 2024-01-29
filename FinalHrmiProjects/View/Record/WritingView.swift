//
//  WritingView.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/29/24.
//

import SwiftUI

struct WritingView: View {
    var body: some View {
        NavigationStack {
            
        }
        .customNavigationBar(
            leadingView: {
                Button {
                    //
                } label: {
                    Image(systemName: "chevron.left")
                }
            }, trailingView: [.trailing: {
                Button {
                    // TODO: 데이터 저장
                } label: {
                    Text("완료")
                        .font(.semibold18)
                }
            }
            ])
        .foregroundStyle(.mainBlack)
    }
}

#Preview {
    WritingView()
}
