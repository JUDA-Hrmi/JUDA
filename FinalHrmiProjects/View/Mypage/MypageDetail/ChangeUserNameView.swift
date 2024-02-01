//
//  ChangeUserNameView.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

struct MypageView1: View {
    var body: some View {
        NavigationStack {
            HStack {
                UserProfileView1()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
           
        }
        
    }
}

struct UserProfileView1: View {
    @State private var userName: String = "sayHong"
    @State private var isEditing: Bool = false
    
    var body: some View {
        Text(userName)
        Spacer()
        
        NavigationLink {
            ChangeUserNameView(userNickName: $userName, isEditing: $isEditing)
        } label: {
            Text("닉네임 수정")
                .font(.light14)
                .foregroundStyle(.gray01)
            
        }
        .disabled(isEditing)
    }
}


struct ChangeUserNameView: View {
    @Environment(\.dismiss) var dismiss
    @FocusState var isFocused: Bool
    @Binding var userNickName: String
    @State private var userChangeNickName: String = ""
    @State private var isCompleted: Bool = true
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            VStack(alignment: .leading, spacing: 15) {
                Text("수정할 닉네임을 작성해주세요")
                HStack {
                    TextField(userNickName, text: $userChangeNickName)
                        .font(.medium16)
                        .focused($isFocused)
                        .textInputAutocapitalization(.never)
                        .onTapGesture {
                            isEditing = true
                        }
                        .onChange(of: userChangeNickName) { _ in
                            isCompleted = userChangeNickName.count >= 2
                        }
                }
                .padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 20))
                .background(Color(.gray05))
                .cornerRadius(10)
            
                if isEditing && userChangeNickName.isEmpty {
                    Text("닉네임을 2자~10자 이내로 적어주세요.")
                        .font(.light14)
                        .foregroundStyle(.mainAccent01)
                }
                
                Spacer()
                
                Divider()
                VStack(alignment: .center, spacing: 10) {
                    Button(action: {
                        if userChangeNickName.isEmpty {
                            // 텍스트 필드가 비어 있으면 다음 페이지로 이동하지 않음
                            return
                        }
                        if userNickName != userChangeNickName {
                            userNickName = userChangeNickName
                        }
                        isEditing = false
                        dismiss()
                    }, label: {
                        Text("변경 완료")
                            .font(.medium20)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                        
                    })
                    .disabled(userChangeNickName.isEmpty || userNickName == userChangeNickName)
                    .foregroundColor(userChangeNickName.isEmpty || userNickName == userChangeNickName ? .gray01 : .white)
                }
                .buttonStyle(.borderedProminent)
                .tint(.mainAccent03)
                .padding(.bottom, 10)
            }
            
        }
        .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
        .padding(.horizontal, 20)
        .navigationBarHidden(true)
   
        .customNavigationBar(
            centerView: {
                Text("닉네임 수정")
            },
            leadingView: {
                Button {
                    isEditing = false
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.mainBlack)
                }
            },
            trailingView: [
                .trailing: {
                    Text("")
                }
            ]
        )
       
    }
}

#Preview {
    MypageView1()
}
