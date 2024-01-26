//
//  CustomNavBarView.swift
//  Component
//
//  Created by 백대홍 on 1/25/24.
//

import SwiftUI
import UIKit

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

// View가 사라질 때 콜백을 실행하는 View Modifier.
struct WillDisappearModifier: ViewModifier {
    let callback: () -> Void // 뷰가 사라질 때 실행할 클로저
    
    // body 메서드 정의
    func body(content: Content) -> some View {
        content
            .background(WillDisappearHandler(onWillDisappear: callback))
    }
}

extension View {
    
    // 뷰가 사라질 때 실행할 클로저를 받아 "onWillDisappear" 모디파이어를 추가하는 메서드
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        self.modifier(WillDisappearModifier(callback: perform))
    }
    
    //사용자 지정 네비게이션 바를 처리하는 커스텀 네비게이션바 Modifier
    func customNavigationBar<C, L> (                        // 왼쪽 + 가운데
        centerView: @escaping (() -> C),
        leftView: @escaping (() -> L)
    ) -> some View where C: View, L: View {
        modifier(
            CustomNavigationBarModifier(
                centerView: centerView,
                leftView: leftView,
                rightView: {
                    EmptyView()
                },
                right2View: {
                    EmptyView()
                },
                right3View: {
                    EmptyView()
                }
            )
        )
    }
    
    func customNavigationBar<L, R3> (                       // 왼쪽 + 오른쪽 끝(1개)
        leftview: @escaping (() -> L),
        right3view: @escaping (() -> R3)
    ) -> some View where L: View, R3: View {
        modifier(CustomNavigationBarModifier(
            centerView: {
                EmptyView()
            },
            leftView: leftview,
            rightView: {
                EmptyView()
            },
            right2View: {
                EmptyView()
            },
            right3View: right3view
        ))
    }
    
    func customNavigationBar<L, R2, R3>(                    // 왼쪽 + 오른쪽 끝(2개)
        leftView: @escaping (() -> L),
        right2View: @escaping (() -> R2),
        right3View: @escaping (() -> R3)
    ) -> some View where L: View, R2: View, R3: View {
        modifier(
            CustomNavigationBarModifier(
                centerView: {
                    EmptyView()
                },
                leftView: leftView,
                rightView: {
                    EmptyView()
                },
                right2View: right2View,
                right3View: right3View
            )
        )
    }
    
    func customNavigationBar<L, R, R2, R3>(                 // 왼쪽 + 오른쪽 끝(3)개
        leftView: @escaping (() -> L),
        rightView: @escaping (() -> R),
        right2View: @escaping (() -> R2),
        right3View: @escaping (() -> R3)
    ) -> some View where L: View, R: View, R2: View, R3: View {
        modifier(
            CustomNavigationBarModifier(
                centerView: {
                    EmptyView()
                },
                leftView: leftView,
                rightView: rightView,
                right2View: right2View,
                right3View: right3View
            )
        )
    }
}

// SwiftUI용 커스텀 네비게이션 바 뷰 모디파이어입니다.
struct CustomNavigationBarModifier<C, L, R, R2, R3>: ViewModifier where C: View, L: View, R: View, R2: View, R3: View {
    let centerView: (() -> C)? // 중앙 뷰를 나타내는 클로저
    let leftView: (() -> L)? // 왼쪽 뷰를 나타내는 클로저
    let rightView: (() -> R)? // 오른쪽 뷰를 나타내는 클로저
    let right2View: (() -> R2)? // 두 번째 오른쪽 뷰를 나타내는 클로저
    let right3View: (() -> R3)? // 세 번째 오른쪽 뷰를 나타내는 클로저
    
    init(centerView: (() -> C)? = nil, leftView: (() -> L)? = nil, rightView: (() -> R)? = nil, right2View: (() -> R2)? = nil, right3View: (() -> R3)? = nil) {
        self.centerView = centerView
        self.leftView = leftView
        self.rightView = rightView
        self.right2View = right2View
        self.right3View = right3View
    }
    // 뷰의 외관을 정의하는 body 함수입니다.
    func body(content: Content) -> some View {
        VStack {
            ZStack {
                HStack {
                    self.leftView?()
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        self.centerView?()
                        
                        Spacer()
                    }
                    
                    self.rightView?()
                        .padding(.trailing, 10)
                    
                    if let right2View = right2View { // 두 번째 오른쪽 뷰가 nil이 아닌 경우에만 추가
                        right2View()
                            .padding(.trailing, 10)
                    }
                    
                    if let right3View = right3View { // 세 번째 오른쪽 뷰가 nil이 아닌 경우에만 추가
                        right3View()
                            .padding(.trailing, 10)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground).ignoresSafeArea(.all, edges: .top))
            }
            Spacer()
                content
                
                
            }
            .navigationBarBackButtonHidden(true)
        }
    }



