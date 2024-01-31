//
//  AppServiceInfoView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/30.
//

import SwiftUI
import SafariServices

// 웹뷰로 넘어가야하는 경우 사용하는 구조체
struct AppServiceInfoView: View {
    let text: String // 항목 이름
    let urlString: String // 해당 항목의 url주소
    
    @State var isShowWebView: Bool = false
    
    var body: some View {
        Button {
            isShowWebView.toggle()
        } label: {
            HStack {
                Text(text)
                Spacer()
                Image(systemName: "chevron.forward")
            }
            .modifier(CustomText())
            .fullScreenCover(isPresented: $isShowWebView) {
                SafariView(url:URL(string: self.urlString)!)
            }
        }
    }
}

// url에 해당하는 Safari 뷰로 연결
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }

}
