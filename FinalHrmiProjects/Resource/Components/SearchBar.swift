//
//  SearchBar.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct SearchBar: View {
    var body: some View {
        HStack {
            HStack(spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .padding(.leading)
                Text("검색")
                    .font(.medium16)
                    .lineSpacing(22)
            }
            Spacer()
            Image(systemName: "xmark")
        }
        .foregroundColor(.gray01)
        .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 20))
        .background(Color(red: 0.46, green: 0.46, blue: 0.50).opacity(0.12))
        .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
    }
}

#Preview {
    SearchBar()
}
