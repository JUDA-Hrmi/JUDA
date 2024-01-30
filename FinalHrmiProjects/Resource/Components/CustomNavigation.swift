//
//  CustomNavBarView.swift
//  Component
//
//  Created by 백대홍 on 1/25/24.
//

import SwiftUI
import UIKit

// MARK: - WillDisappearHandler

// SwiftUI에서 뷰가 사라질 때의 로직을 처리하는 View Modifier.
struct WillDisappearHandler: UIViewControllerRepresentable {
    
    // Coordinator 클래스 정의
    func makeCoordinator() -> WillDisappearHandler.Coordinator {
        Coordinator(onWillDisappear: onWillDisappear)
    }
    
    let onWillDisappear: () -> Void // View가 사라질 때 실행할 클로저
    
    // UIViewControllerRepresentable 프로토콜을 준수하는 Coordinator 생성
    func makeUIViewController(context: UIViewControllerRepresentableContext<WillDisappearHandler>) -> UIViewController {
        context.coordinator
    }
    
    // UIViewController 업데이트 시에 아무 작업도 수행하지 않음
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<WillDisappearHandler>) {}
    
    typealias UIViewControllerType = UIViewController
    
    // Coordinator 클래스 정의
    class Coordinator: UIViewController {
        let onWillDisappear: () -> Void // 뷰가 사라질 때 실행할 클로저
        
        // 초기화 메서드
        init(onWillDisappear: @escaping () -> Void) {
            self.onWillDisappear = onWillDisappear
            super.init(nibName: nil, bundle: nil)
        }
        
        // 인코더를 사용하는 초기화 메서드 비활성화
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // View가 사라질 때 호출되는 메서드
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }
    }
}

// MARK: - WillDisappearModifier

// View가 사라질 때 콜백을 실행하는 View Modifier.
struct WillDisappearModifier: ViewModifier {
    let callback: () -> Void // 뷰가 사라질 때 실행할 클로저
    
    // body 메서드 정의
    func body(content: Content) -> some View {
        content
            .background(WillDisappearHandler(onWillDisappear: callback))
    }
}



// MARK: - CustomNavigationBarModifier
enum NavigationTrailingButtonPostion: Hashable, Comparable {
    case leading, center, trailing
}

// SwiftUI용 커스텀 네비게이션 바 뷰 모디파이어입니다.
struct CustomNavigationBarModifier<C, L, T>: ViewModifier where C: View, L: View, T: View {
    let centerView: (() -> C)? // 중앙 뷰를 나타내는 클로저
    let leadingView: (() -> L)? // 왼쪽 뷰를 나타내는 클로저
    let trailingViews: [NavigationTrailingButtonPostion: (() -> T)?] // 오른쪽 뷰를 나타내는 클로저
    
    init(centerView: (() -> C)? = nil, leadingView: (() -> L)? = nil, trailingViews: [NavigationTrailingButtonPostion: (() -> T)?] = [:]) {
        self.centerView = centerView
        self.leadingView = leadingView
        self.trailingViews = trailingViews
    }
    // 뷰의 외관을 정의하는 body 함수.
    func body(content: Content) -> some View {
        VStack {
            ZStack {
                HStack(alignment: .center) {
                    self.leadingView?()
                    
                    Spacer()
                    
                    self.centerView?()
                    
                    Spacer()
                    
                    HStack {
                        ForEach(trailingViews.keys.sorted(), id: \.self) { key in
                            if let trailingView = self.trailingViews[key] {
                                trailingView?()
                                    .padding(.trailing, 10)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground).ignoresSafeArea(.all, edges: .top))
            }
            Spacer()
            content
        }
        .navigationBarBackButtonHidden(true)
    }
}


struct TestView: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<30, id: \.self) { _ in
                    Text("????")
                }
            }
            .customNavigationBar(
                leadingView: {
                Button {
                    //
                } label: {
                    Image(systemName: "chevron.left")
                }
            }, trailingView: [
                .center : {
                    Button {
                        //
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.left.fill")
                    }
                }, .trailing: {
                    Button {
                        //
                    } label: {
                        Image(systemName: "square.and.arrow.up.circle")
                    }
            }
            ])
        }
    }
}
