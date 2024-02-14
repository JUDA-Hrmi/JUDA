//
//  LogInView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//


import SwiftUI

// MARK: - 로그인 화면
struct LogInView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            VStack {
                VStack {
                    // 앱 아이콘
                    Image("appIcon")
                        .resizable()
                        .frame(width: 289, height: 250)
                        .cornerRadius(10)
                    // 앱 이름
                    Text("주다 - JUDA")
                        .font(.semibold24)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 70)
                // 로그인 버튼
                VStack(spacing: 30) {
                    // 애플 로그인
                    Image("applelogin")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                    // 구글 로그인
                    Image("Google")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                    // 카카오 로그인
                    Image("Kakao")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                }
                Spacer()
                //
                Text("2024, 주다 - JUDA all rights reserved.\nPowered by PJ4T7_HrMi")
                    .font(.light12)
                    .multilineTextAlignment(.center)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .foregroundStyle(.mainBlack)
            }
        }
    }
}

#Preview {
    LogInView()
}
