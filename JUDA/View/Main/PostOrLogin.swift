//
//  PostOrLogin.swift
//  JUDA
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 추천 술상 보러가기 or 로그인 하러가기
struct PostOrLogin: View {
    @Binding var isLoggedIn: Bool
    @Binding var selectedTabIndex: Int
    
    var body: some View {
        VStack(alignment: isLoggedIn ? .leading : .center, spacing: 10) {
            // 로그인
            if isLoggedIn {
                Text("다른 사람들은 어떻게 먹었을까?")
                    .font(.medium16)
                // 술상 탭 이동
                Button {
                    // 술상 탭뷰로 이동
                    selectedTabIndex = 2
                } label: {
                    Text("추천 술상 보러가기")
                        .font(.medium16)
                        .foregroundStyle(.mainAccent03)
                        .underline()
                }
                // 비로그인
            } else {
                Text("추천 안주와 술을 알고 싶다면?")
                    .font(.semibold18)
                // TODO: NavigationLink - value 로 수정
                NavigationLink {
                    LogInView()
                        .modifier(TabBarHidden())
                } label: {
                    HStack(alignment: .center) {
                        Text("로그인 하러가기")
                            .font(.medium16)
                            .foregroundStyle(.mainAccent03)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 6)
                    .background(.mainAccent03.opacity(0.2))
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: isLoggedIn ? .leading : .center)
    }
}
