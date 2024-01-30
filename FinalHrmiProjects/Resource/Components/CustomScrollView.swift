//
//  CustomScrollView.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/30/24.
//

import SwiftUI

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
