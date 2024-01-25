//
//  CustomNavigation.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/25/24.
//


import SwiftUI
import UIKit


struct WillDisappearHandler: UIViewControllerRepresentable {
    func makeCoordinator() -> WillDisappearHandler.Coordinator {
        Coordinator(onWillDisappear: onWillDisappear)
    }
    
    let onWillDisappear: () -> Void
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<WillDisappearHandler>) -> UIViewController {
        context.coordinator
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<WillDisappearHandler>) {}
    
    typealias UIViewControllerType = UIViewController
    
    class Coordinator: UIViewController {
        let onWillDisappear: () -> Void
        
        init(onWillDisappear: @escaping () -> Void) {
            self.onWillDisappear = onWillDisappear
            super.init(nibName: nil, bundle: nil)
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            onWillDisappear()
        }
    }
}

struct WillDisappearModifier: ViewModifier {
    let callback: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(WillDisappearHandler(onWillDisappear: callback))
    }
}

extension View {
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        self.modifier(WillDisappearModifier(callback: perform))
    }
    
    func customNavigationBar<C, L> (             ///왼쪽 + 가운데
        centerView: @escaping (() -> C),
        leftView: @escaping (() -> L)
        
    ) ->some View where C: View, L: View {
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
    
    func customNavigationBar<L, R3> (    ///왼쪽 + 끝에 하나
        leftview: @escaping (() -> L),
        right3view: @escaping (() -> R3)
    ) ->some View where L: View, R3: View {
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
    
    func customNavigationBar<L, R2, R3>(        ///왼쪽 + 끝에 2개
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
    
    func customNavigationBar<L, R, R2, R3>(        ///왼쪽 + 끝에 3개
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
                    
                    if let right2View = right2View { // 두 번째 오른쪽 뷰가 nil이 아닌 경우에만 추가
                        right2View()
                    }
                    
                    if let right3View = right3View { // 세 번째 오른쪽 뷰가 nil이 아닌 경우에만 추가
                        right3View()
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



