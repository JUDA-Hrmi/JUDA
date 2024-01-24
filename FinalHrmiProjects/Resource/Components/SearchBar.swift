//
//  SearchBar.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct SearchBar: View {
    @State private var inputText: String = ""
    var body: some View {
        HStack {
            HStack(spacing: 5) {
                Image(systemName: "magnifyingglass")
                    .padding(.leading)

                TextField("검색", text: $inputText)
                    .font(.medium16)
                    .textInputAutocapitalization(.never)
            }
            Spacer()
            // TODO: xmark 기능 구현
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "xmark")
            })
        }
        .foregroundColor(.gray01)
        .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 20))
        .background(Color(red: 0.46, green: 0.46, blue: 0.50).opacity(0.12))
        .cornerRadius(10)
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20)) // 오토레이아웃을 위한 padding
    }
}

#Preview {
    SearchBar()
}
