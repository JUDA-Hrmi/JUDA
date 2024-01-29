//
//  SuggestSulView.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/29/24.
//

import SwiftUI
// MARK: - 오늘의 추천 술 전체 뷰
struct SuggestSulView: View {
    @Binding var isLoggedIn: Bool
    var body: some View {
        VStack(alignment:.leading, spacing: 10) {
            Text("오늘의 추천 술")
                .font(.semibold18)
            
            TodaysulView(todaySul: TodaysulData)
                .opacity(isLoggedIn ? 1.0 : 0.8)
                .blur(radius: isLoggedIn ? 0 : 3)
        }
        if isLoggedIn {
            VStack {
                Text("여기에 뭐넣지..?")
            }
        } else {
            VStack(alignment: .center, spacing: 10) {
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
            .padding(.top,30)
        }
    }
}
