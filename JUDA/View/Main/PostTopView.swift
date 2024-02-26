//
//  PostTopView.swift
//  JUDA
//
//  Created by 백대홍 on 2/26/24.
//

import SwiftUI

struct PostTopView: View {
    @State private var postSearchText = ""
    @Binding var selectedTabIndex: Int
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("인기 술상")
                    .font(.semibold20)
                
                Spacer()
                
                Button {
                    selectedTabIndex = 2
                } label: {
                    Text("더보기")
                        .foregroundStyle(.gray01)
                        .font(.semibold16)
                }
            }
            .padding(20)

            Rectangle()
                .frame(height: 138)
                .foregroundStyle(.gray)
        }
    }
}
