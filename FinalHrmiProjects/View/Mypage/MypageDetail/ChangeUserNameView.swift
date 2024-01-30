//
//  ChangeUserNameView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/30.
//

import SwiftUI

struct ChangeUserNameView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack {
            
        }
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
            },trailingView: [
                .trailing: {
                    Text("")
                }
            ])
        
    }
}

#Preview {
    ChangeUserNameView()
}
