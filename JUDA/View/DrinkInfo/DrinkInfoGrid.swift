//
//  DrinkInfoGrid.swift
//  JUDA
//
//  Created by phang on 1/28/24.
//

import SwiftUI

// MARK: - 술장 그리드 뷰
struct DrinkInfoGrid: View {
    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView() {
                DrinkGridContent()
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.immediately)
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
                DrinkGridContent()
                    .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
                    DrinkGridContent()
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.immediately)
            }
        }
    }
}

// MARK: - 술장 그리드 뷰 내용
struct DrinkGridContent: View {
    // 술 그리드 셀 2개 column
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        // 그리드
        LazyVGrid(columns: columns, spacing: 10) {
            // TODO: 데이터 들어온 리스트로 ForEach 
            ForEach(0..<10, id: \.self) { _ in
                // TODO: NavigationLink - value 로 수정
                NavigationLink {
                    DrinkDetailView()
                        .modifier(TabBarHidden())
                } label: {
                    DrinkGridCell()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

#Preview {
    DrinkInfoGrid()
}
