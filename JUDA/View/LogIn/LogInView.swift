//
//  LogInView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//


import SwiftUI

struct LogInView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // MARK: - 상위 뷰
        ZStack {
            VStack {
                VStack {
                    Image("appIcon")
                        .resizable()
                        .frame(width: 289, height: 250)
                        .cornerRadius(10)
                    
                    Text("HrMi")
                        .font(.regular24)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 70)
                
                // MARK: - 로그인 버튼 나열뷰
                VStack(spacing: 30) {
                    
                    Image("applelogin")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                    
                    Image("Google")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                    
                    Image("Kakao")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                }
                Spacer()
                
                // MARK: - 하위뷰
                Text("2024, HrMi all rights reserved.\nPowered by PJ3T7_HrMi")
                    .font(.thin12)
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
