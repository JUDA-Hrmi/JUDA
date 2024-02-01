//
//  SearchBar.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct SearchBar: View {
    @Binding var inputText: String
//    @FocusState private var isFocused: Bool
    var body: some View {
        HStack {
            HStack(spacing: 5) {
                Image(systemName: "magnifyingglass")
                    .padding(.leading)

                TextField("검색", text: $inputText)
                    .font(.medium16)
//                    .focused($isFocused)
					.foregroundStyle(.mainBlack)
                    .textInputAutocapitalization(.never) // 자동 대문자 설정 기능 비활성화
                    .onSubmit {
                        // TODO: 리턴 시 수행될 함수 추가하기.
                        print("리턴이 눌러졌어요! <\(inputText)> 입력 됨.")
                    }
            }
            Spacer()
            
            if !inputText.isEmpty {
                Button(action: {
                    inputText = ""
                }, label: {
                    Image(systemName: "xmark")
                })
            }
        }
        .foregroundColor(.gray01)
        .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 20))
        .background(Color(red: 0.46, green: 0.46, blue: 0.50).opacity(0.12))
		.clipShape(.rect(cornerRadius: 10))
		.padding(.horizontal, 20) // 오토레이아웃을 위한 padding
    }
}

//#Preview {
//    SearchBar()
//}
