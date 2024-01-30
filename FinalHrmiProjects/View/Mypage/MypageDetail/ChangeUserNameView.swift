//
//  ChangeUserNameView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/30.
//

import SwiftUI

// 텍스트 필드 버전
struct ChangeUserNameView: View {
    @State var userNickName: String = "User010303"
    @State var isEditingNickName: Bool = false
    var body: some View {
        // 닉네임 수정 버튼 누르지 않음
        if isEditingNickName {
            HStack {
                // TODO: 닉네임 겹치는지 확인하는 코드
                TextField("닉네임을 입력하세요", text: $userNickName)
                    .font(.light18)
                    .textFieldStyle(.plain)
                    
                // '확인' 버튼
                Button("수정 완료") {
                    isEditingNickName.toggle()
                }
                .foregroundStyle(.gray01)
            }
        } else {
            HStack {
                Text(userNickName)
                    .font(.medium18)
                Spacer()
                Button(action: {
                    isEditingNickName.toggle()
                }, label: {
                    Text("닉네임 수정")
                        .font(.light14)
                        .foregroundStyle(.gray01)
                })
                
            }
        }
    }
}


#Preview {
    ChangeUserNameView()
}
