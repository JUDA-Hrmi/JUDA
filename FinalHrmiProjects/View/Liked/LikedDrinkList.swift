//
//  LikedDrinkList.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/26/24.
//

import SwiftUI

struct LikedDrinkList: View {
    @State private var scrollAxis: Axis.Set = .vertical
    @State private var vHeight = 0.0
    
    var body: some View {
        CustomScrollView(scrollAxis: $scrollAxis,
                         vHeight: $vHeight) {
            LazyVStack {
                ForEach(0..<10, id: \.self) { _ in
                    // TODO: 추후에 네비게이션으로 해당 술의 Detail 로 이동 연결
                    DrinkListCell()
                }
            }
        }
    }
}

// MARK: content 가 가 화면 크기를 넘어가야만 scrollView 작동하도록하는 커스텀 스크롤 뷰
struct CustomScrollView<Content: View>: View {
    @Binding var scrollAxis: Axis.Set
    @Binding var vHeight: Double
    let content: () -> Content
    
    var body: some View {
        GeometryReader { scrollGeo in
            ScrollView(scrollAxis) {
                content()
                .background(
                    GeometryReader { contentGeo in
                        Color.clear
                            .onAppear {
                                vHeight = Double(contentGeo.size.height)
                            }
                            .onChange(of: scrollGeo.size.height) {
                                // TODO: 탭바 있을 때도, 잘 작동하는지 확인 필요
                                scrollAxis = contentGeo.size.height > $0 ? .vertical : []
                            }
                    }
                )
            }
            .scrollIndicators(.hidden)
        }
    }
}

#Preview {
    LikedDrinkList()
}
