//
//  PostTopView.swift
//  JUDA
//
//  Created by 백대홍 on 2/26/24.
//

import SwiftUI

struct PostTopView: View {
    @State private var postSearchText = ""
    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Text("술장 TOP3")
                    .font(.semibold18)
                
                Spacer()
                
                NavigationLink {
                    PostsView(postSearchText: $postSearchText)
                } label: {
                    Text("더보기")
                        .foregroundStyle(.gray01)
                        .font(.semibold14)
                }
            }
            Rectangle()
                .frame(height: 138)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    PostTopView()
}
