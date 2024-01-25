//
//  rmsidvkdlf.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/25.
//

//import SwiftUI
///// Custom Navigation Bar
//extension View {
//    func customNavigationBar<C, L, R, R2, R3>(
//        centerView: (() -> C)? = nil,
//        leftView: (() -> L)? = nil,
//        rightView: (() -> R)? = nil,
//        right2View: (() -> R2)? = nil,
//        right3View: (() -> R3)? = nil
//    ) -> some View where C: View, L: View, R: View, R2: View, R3: View {
//        self.modifier(
//            CustomNavigationBarModifier(
//                centerView: centerView,
//                leftView: leftView,
//                rightView: rightView,
//                right2View: right2View,
//                right3View: right3View
//            )
//        )
//    }
//}
//
//struct CustomNavigationBarModifier<C, L, R, R2, R3>: ViewModifier where C: View, L: View, R: View, R2: View, R3: View {
//    let centerView: (() -> C)? // 중앙 뷰를 나타내는 클로저
//    let leftView: (() -> L)? // 왼쪽 뷰를 나타내는 클로저
//    let rightView: (() -> R)? // 오른쪽 뷰를 나타내는 클로저
//    let right2View: (() -> R2)? // 두 번째 오른쪽 뷰를 나타내는 클로저
//    let right3View: (() -> R3)? // 세 번째 오른쪽 뷰를 나타내는 클로저
//    
//    init(centerView: (() -> C)? = nil, leftView: (() -> L)? = nil, rightView: (() -> R)? = nil, right2View: (() -> R2)? = nil, right3View: (() -> R3)? = nil) {
//        self.centerView = centerView
//        self.leftView = leftView
//        self.rightView = rightView
//        self.right2View = right2View
//        self.right3View = right3View
//    }
//    
//    func body(content: Content) -> some View {
//        VStack {
//            ZStack {
//                HStack {
//                    if let leftView = leftView { // 왼쪽 뷰가 nil이 아닌 경우에만 추가
//                        leftView()
//                    }
//                    
//                    Spacer()
//                    
//                    HStack {
//                        Spacer()
//                        
//                        if let centerView = centerView { // 중앙 뷰가 nil이 아닌 경우에만 추가
//                            centerView()
//                        }
//                        
//                        Spacer()
//                    }
//                    
//                    if let rightView = rightView { // 오른쪽 뷰가 nil이 아닌 경우에만 추가
//                        rightView()
//                    }
//                    
//                    if let right2View = right2View { // 두 번째 오른쪽 뷰가 nil이 아닌 경우에만 추가
//                        right2View()
//                    }
//                    
//                    if let right3View = right3View { // 세 번째 오른쪽 뷰가 nil이 아닌 경우에만 추가
//                        right3View()
//                    }
//                }
//                .padding()
//                .background(Color(UIColor.systemBackground).ignoresSafeArea(.all, edges: .top))
//                
//                content
//                
//                Spacer()
//            }
//            .navigationBarBackButtonHidden(true)
//        }
//    }
//}
//
//#Preview {
//    CustomNavigationBarModifier {
//        <#code#>
//    }
//}
