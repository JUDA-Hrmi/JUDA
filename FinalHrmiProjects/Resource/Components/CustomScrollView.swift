//
//  CustomScrollView.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/31/24.
//

import SwiftUI

// MARK: content 가 가 화면 크기를 넘어가야만 scrollView 작동하도록하는 커스텀 스크롤 뷰
struct CustomScrollView<Content: View>: View {
    @State private var scrollAxis: Axis.Set = .vertical
    let content: () -> Content
    
    var body: some View {
        GeometryReader { scrollGeo in
            ScrollView(scrollAxis) {
                content()
                .background(
                    GeometryReader { contentGeo in
                        Color.clear
                            .task {
                                if contentGeo.size.height <= scrollGeo.size.height {
                                    scrollAxis = []
                                }
                            }
                    }
                )
            }
            .scrollIndicators(.hidden)
			.scrollDismissesKeyboard(.immediately)
        }
    }
}
