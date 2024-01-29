//
//  ConditionsUseView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/29.
//

import SwiftUI
import SafariServices

struct TermsofServiceView: View {
    var text: String
    var urlString: String
    
    @Binding var isShowWebView: Bool
    
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


struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {

    }

}
