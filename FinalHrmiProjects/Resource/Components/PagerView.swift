//
//  PagerView.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/28/24.
//

import SwiftUI

/// 선택 바에 맞춰서 이동하는 TabView(페이지 스타일) 을 사용할 수 있지만,
/// 여러 항목을 한번에 이동하면 간혹 에러가 나는 경우가 발생.
/// -> LazyHStack 을 통해서 해결 (offset 으로 화면을 이동하는 방식)

struct PagerView<Content: View>: View {
    // 전체 뷰 개수
    let pageCount: Int
    // 현재 뷰 인덱스
    @Binding var currentIndex: Int
    // 내용 View
    let content: Content
    init(pageCount: Int, currentIndex: Binding<Int>, @ViewBuilder content: () -> Content) {
        self.pageCount = pageCount
        self._currentIndex = currentIndex
        self.content = content()
    }
    // 제스처 상태 저장
    @GestureState private var translation: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            LazyHStack(spacing: 0) {
                self.content.frame(width: geometry.size.width)
            }
            .frame(width: geometry.size.width, alignment: .leading)
            // 현재에 offset 맞추기
            .offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
            // 드래그 제스처에 따라 offset 변경
            .offset(x: self.translation)
            // 현재 & 드래그 제스처 애니메이션 설정
            .animation(.interpolatingSpring, value: currentIndex)
            .animation(.interpolatingSpring, value: translation)
            // 드래그 제스처
            .gesture(
                DragGesture(minimumDistance: 25).updating(self.$translation) { value, state, _ in
                    state = value.translation.width
                }
                // 드래그 종료 시,
                .onEnded { value in
                    // offset 예측 계산
                    let offset = value.predictedEndTranslation.width / geometry.size.width
                    // 새로운 인덱스 계산
                    var newIndex = max(Int((CGFloat(self.currentIndex) - offset).rounded()), 0)
                    // 계산된 인덱스 값에 따라, 앞 뒤로 화면 이동
                    if newIndex > self.currentIndex {
                        newIndex = self.currentIndex + 1
                    } else if newIndex < self.currentIndex {
                        newIndex = self.currentIndex - 1
                    }
                    // 현재 인덱스 재설정
                    self.currentIndex = min(max(Int(newIndex), 0), self.pageCount - 1)
                }
            )
        }
    }
}
