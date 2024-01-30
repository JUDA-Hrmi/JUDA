//
//  ChangeUserNameView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/30.
//

import SwiftUI

// 네비게이션 이동 버전
struct ChangeUserNameView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    @Binding var userNickName: String // 원래 닉네임(Setting 뷰에서 보이는 닉네임)
    @State var userChangeNickName: String = "" // 바꿀 닉네임
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
            
            // MARK: 배민 기능 참고
            // TODO: - 1. 원래 닉네임과 텍필에 새로 입력한 닉네임이 같으면 '변경완료' 버튼 비활성화
            // TODO: - 2. 텍필 클릭 전에는 "닉네임을 2자~10자 이내로 적어주세요." 문구 안뜨게하기
            // TODO: - 3. 텍필 제외 다른 부분 클릭 시 키보드 내려가게 하기 (View + 파일 -> hideKeyboard() 있음)
            if userChangeNickName.count < 2 {
                Text("닉네임을 2자~10자 이내로 적어주세요.")
                    .font(.light14)
                    .foregroundStyle(.mainAccent01)
            }
            
            Spacer()
            
            // TODO: - 1. 버튼 만들기
            // TODO: - 2. 버튼 클릭 시 자동 dismiss
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
        // TODO: ToolItem으로 변경하기
        .customNavigationBar(
            centerView: {
                Text("닉네임 수정")
            },
            leadingView: {
                Button {
                    dismiss()
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

