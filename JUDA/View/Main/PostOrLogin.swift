//
//  PostOrLogin.swift
//  JUDA
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 추천 술상 보러가기 or 로그인 하러가기
struct PostOrLogin: View {
    @EnvironmentObject private var authService: AuthService

    @Binding var selectedTabIndex: Int
    
    var body: some View {
        VStack(alignment: authService.signInStatus ? .leading : .center, spacing: 10) {
            // 로그인
            if authService.signInStatus {
                
            } else {
                VStack(alignment: .center, spacing: 10) {
                    VStack {
                        Text("오늘의 날씨에 맞는")
                        HStack {
                            Text("술과 안주")
                                .foregroundStyle(.mainAccent03)
                            Text("를 추천 받고 싶다면?")
                        }
                    }
                    .font(.medium18)
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
                        LogInView()
                            .modifier(TabBarHidden())
                    } label: {
                        HStack(alignment: .center) {
                            Text("로그인 하러가기")
                                .font(.semibold16)
                                .foregroundStyle(.mainAccent03)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.mainAccent03.opacity(0.2))
                        .clipShape(.rect(cornerRadius: 10))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: authService.signInStatus ? .leading : .center)
    }
}
