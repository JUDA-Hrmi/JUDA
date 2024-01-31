//
//  DrinkInfoList.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/28/24.
//

import SwiftUI

struct DrinkInfoList: View {
    var body: some View {
        ScrollView {
            // 리스트
            LazyVStack(spacing: 0) {
                // TODO: 현재 더미데이터 10개를 보여주지만, 데이터 들어온 리스트로 ForEach 돌릴 예정
                ForEach(0..<10, id: \.self) { _ in
                    // TODO: 추후에 네비게이션으로 해당 술의 Detail 로 이동 연결
                    NavigationLink(value: "") {
                        DrinkGridCell()
                    }
                }
            }
            .navigationDestination(for: String.self) { _ in
                DrinkDetailView()
            }
        }
        // 스크롤 인디케이터 X
        .scrollIndicators(.hidden)
    }
}

#Preview {
    DrinkInfoList()
}
