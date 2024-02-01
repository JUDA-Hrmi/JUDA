//
//  SuggestDrinkView.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 하단 로그인 OR 비로그인 상태에 따른 뷰 전환
struct SuggestDrinkView: View {
    @Binding var isLoggedIn: Bool
    var body: some View {
        if isLoggedIn {
            VStack(alignment: .leading, spacing: 10) {
                SuggestDrinkCell(isLoggedIn: $isLoggedIn)
                Text("다른 사람들은 어떻게 먹었을까?")
                    .font(.medium16)
                NavigationLink {
                    DrinkInfoView()
                } label: {
                    Text("추천 술상 보러가기")
                        .font(.medium16)
                        .foregroundStyle(.mainAccent03)
                        .underline()
                }
            }
            .padding(.top, 20)
        } else {
            VStack(alignment: .center, spacing: 10) {
                SuggestDrinkCell(isLoggedIn: $isLoggedIn)
                Text("추천 안주와 술을 알고 싶다면?")
                    .font(.medium16)
                NavigationLink {
                    LogInView()
                } label: {
                    HStack(alignment: .center) {
                        Text("로그인 하러가기")
                            .font(.medium16)
                            .foregroundStyle(.mainAccent03)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.mainAccent03.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            .padding(.top, 20)
        }
    }
}
