//
//  AppServiceInfoView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/02/01.
//

import SwiftUI
import SafariServices

// MARK: - 웹뷰로 넘어가야하는 경우 사용하는 구조체
struct AppServiceInfoView: View {
    @State var isShowWebView: Bool = false

    let text: String // 항목 이름
    let urlString: String // 해당 항목의 url주소
        
    var body: some View {
        Button {
            isShowWebView.toggle()
        } label: {
            HStack {
                Text(text)
                Spacer()
                Image(systemName: "chevron.forward")
            }
            .font(.regular16)
            .foregroundStyle(.mainBlack)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .fullScreenCover(isPresented: $isShowWebView) {
                SafariView(url: URL(string: self.urlString)!)
            }
        }
    }
}

// MARK: - url에 해당하는 Safari 뷰로 연결
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        //
    }
}
