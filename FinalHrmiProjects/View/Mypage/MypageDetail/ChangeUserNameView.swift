//
//  ChangeUserNameView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/30.
//

import SwiftUI

// 네비게이션 이동 버전
struct ChangeUserNameView: View {
    @Binding var userNickName: String
    @Environment(\.presentationMode) var presentationMode
    @State var userChangeNickName: String = ""
    @FocusState var isFocused: Bool
    @State var isCompleted: Bool = true
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("수정할 닉네임을 작성해주세요")
            HStack {
                TextField(userNickName, text: $userChangeNickName)
                    .font(.medium16)
                    .focused($isFocused)
                    .textInputAutocapitalization(.never) // 자동 대문자 설정 기능 비활성화
            }
            .foregroundColor(.gray01)
            .padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 20))
            .background(Color(red: 0.46, green: 0.46, blue: 0.50).opacity(0.12))
            .cornerRadius(10)
            if userChangeNickName.count < 2{
                Text("닉네임을 2자~10자 이내로 적어주세요.")
                    .font(.light14)
                    .foregroundStyle(.mainAccent01)
            }
            
            Spacer()
            
            Button(action: {
                userNickName = userChangeNickName
                isCompleted.toggle()
            }, label: {
                Text("변경 완료")
            })
        }
        .padding(.horizontal, 20)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
        .customNavigationBar(
            centerView: {
                Text("닉네임 수정")
            },
            leadingView: {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.mainBlack)
                }
            }, trailingView: [
                .trailing: {
                    Text("")
                }
            ])
    }
}

#Preview {
    ChangeUserNameView(userNickName: .constant("say"))
}

